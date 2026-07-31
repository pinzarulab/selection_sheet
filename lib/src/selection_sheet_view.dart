import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'selection_sheet_theme.dart';
import 'selection_sheet_types.dart';

/// Controls a remote selection sheet or embedded selection view.
class SelectionSheetController {
  Future<void> Function()? _refreshCallback;

  /// Whether this controller is attached to an open remote sheet.
  bool get isAttached => _refreshCallback != null;

  /// Reloads page one for the current debounced query.
  ///
  /// This preserves the draft selection, invalidates older in-flight requests,
  /// and resets both page-number and cursor pagination. It completes
  /// immediately when no remote sheet is attached.
  Future<void> refresh() async {
    await _refreshCallback?.call();
  }

  void _attach(Future<void> Function() callback) {
    _refreshCallback = callback;
  }

  void _detach(Future<void> Function() callback) {
    if (identical(_refreshCallback, callback)) {
      _refreshCallback = null;
    }
  }
}

/// An embeddable single- or multi-selection workflow.
///
/// Unlike the modal helpers, this widget does not create or close a route.
/// Use [onSelected], [onSelectionChanged], and [onConfirmed] to receive
/// changes. The modal helpers use the same widget internally.
class SelectionSheetView<T> extends StatefulWidget {
  /// Creates an embeddable single-selection workflow.
  const SelectionSheetView.single({
    required this.itemLabelBuilder,
    this.items,
    this.loadItems,
    this.pageSize = 20,
    this.title,
    this.initialValue,
    this.searchable = false,
    this.searchDebounceDuration,
    this.searchHintText,
    this.searchFieldBuilder,
    this.itemBuilder,
    this.isItemEnabled,
    this.itemEquals,
    this.itemKeyBuilder,
    this.sectionBuilder,
    this.sectionLabelBuilder,
    this.sectionHeaderBuilder,
    this.stickySectionHeaders = true,
    this.showDragHandle,
    this.dragHandleBuilder,
    this.layout,
    this.gridDelegate,
    this.enablePullToRefresh = true,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.loadingMoreBuilder,
    this.loadMoreErrorBuilder,
    this.controller,
    this.theme,
    this.scrollController,
    this.onSelected,
    this.onDragHandleUpdate,
    this.onDragHandleEnd,
    this.popOnComplete = false,
    super.key,
  })  : assert((items == null) != (loadItems == null)),
        assert(pageSize > 0),
        isMulti = false,
        initialSelection = const [],
        doneLabel = null,
        showSelectedChips = false,
        selectedChipBuilder = null,
        onSelectionChanged = null,
        onConfirmed = null;

  /// Creates an embeddable multi-selection workflow.
  const SelectionSheetView.multi({
    required this.itemLabelBuilder,
    this.items,
    this.loadItems,
    this.pageSize = 20,
    this.title,
    this.initialSelection = const [],
    this.searchable = false,
    this.searchDebounceDuration,
    this.searchHintText,
    this.searchFieldBuilder,
    this.doneLabel,
    this.itemBuilder,
    this.isItemEnabled,
    this.itemEquals,
    this.itemKeyBuilder,
    this.sectionBuilder,
    this.sectionLabelBuilder,
    this.sectionHeaderBuilder,
    this.stickySectionHeaders = true,
    this.showDragHandle,
    this.dragHandleBuilder,
    this.layout,
    this.gridDelegate,
    this.showSelectedChips,
    this.enablePullToRefresh = true,
    this.selectedChipBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.loadingMoreBuilder,
    this.loadMoreErrorBuilder,
    this.controller,
    this.theme,
    this.scrollController,
    this.onSelectionChanged,
    this.onConfirmed,
    this.onDragHandleUpdate,
    this.onDragHandleEnd,
    this.popOnComplete = false,
    super.key,
  })  : assert((items == null) != (loadItems == null)),
        assert(pageSize > 0),
        isMulti = true,
        initialValue = null,
        onSelected = null;

  final List<T>? items;
  final SelectionSheetPageLoader<T>? loadItems;
  final int pageSize;
  final SelectionItemLabelBuilder<T> itemLabelBuilder;
  final String? title;
  final T? initialValue;
  final Iterable<T> initialSelection;
  final bool searchable;
  final String? searchHintText;
  final SelectionSheetSearchFieldBuilder? searchFieldBuilder;
  final Duration? searchDebounceDuration;
  final String? doneLabel;
  final SelectionSheetItemBuilder<T>? itemBuilder;
  final bool Function(T item)? isItemEnabled;
  final SelectionItemEquality<T>? itemEquals;
  final SelectionItemKeyBuilder<T>? itemKeyBuilder;
  final SelectionSheetSectionBuilder<T>? sectionBuilder;
  final SelectionSheetSectionLabelBuilder? sectionLabelBuilder;
  final SelectionSheetSectionHeaderBuilder? sectionHeaderBuilder;
  final bool stickySectionHeaders;
  final bool? showDragHandle;
  final SelectionSheetDragHandleBuilder? dragHandleBuilder;
  final SelectionSheetLayout? layout;
  final SliverGridDelegate? gridDelegate;
  final bool? showSelectedChips;
  final SelectionSheetSelectedChipBuilder<T>? selectedChipBuilder;
  final SelectionSheetLoadingBuilder? loadingBuilder;
  final SelectionSheetEmptyBuilder? emptyBuilder;
  final SelectionSheetErrorBuilder? errorBuilder;
  final SelectionSheetLoadingBuilder? loadingMoreBuilder;
  final SelectionSheetErrorBuilder? loadMoreErrorBuilder;
  final SelectionSheetController? controller;
  final bool enablePullToRefresh;
  final SelectionSheetThemeData? theme;
  final ScrollController? scrollController;
  final bool isMulti;
  final ValueChanged<T>? onSelected;
  final ValueChanged<List<T>>? onSelectionChanged;
  final ValueChanged<List<T>>? onConfirmed;
  final GestureDragUpdateCallback? onDragHandleUpdate;
  final GestureDragEndCallback? onDragHandleEnd;
  final bool popOnComplete;

  bool get isRemote => loadItems != null;

  @override
  State<SelectionSheetView<T>> createState() => _SelectionSheetViewState<T>();
}

class _SelectionSheetViewState<T> extends State<SelectionSheetView<T>> {
  late SelectionSheetThemeData _theme;
  late final ScrollController _scrollController;
  late final bool _ownsScrollController;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late List<T> _selection;
  Set<Object>? _selectionKeys;
  late List<T> _items;
  Set<Object>? _itemKeys;
  Timer? _searchDebounceTimer;
  String _query = '';

  int _requestGeneration = 0;
  int _nextPage = 1;
  Object? _nextCursor;
  bool _hasMore = false;
  bool _loadingInitial = false;
  bool _loadingMore = false;
  Object? _initialError;
  Object? _loadMoreError;
  Future<void> Function()? _attachedRefresh;
  final Set<SelectionSheetCancellationToken> _activeRequestTokens = {};

  bool get _isCupertino {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  Duration get _searchDebounceDuration =>
      widget.searchDebounceDuration ?? _theme.searchDebounceDuration;

  SelectionSheetLayout get _layout => widget.layout ?? _theme.layout;

  SliverGridDelegate get _gridDelegate =>
      widget.gridDelegate ?? _theme.gridDelegate;

  bool get _showSelectedChips =>
      widget.showSelectedChips ?? _theme.showSelectedChips;

  bool get _showDragHandle =>
      widget.showDragHandle ??
      widget.dragHandleBuilder != null ||
          (widget.popOnComplete ? _theme.showDragHandle : false);

  @override
  void initState() {
    super.initState();
    _ownsScrollController = widget.scrollController == null;
    _scrollController = widget.scrollController ?? ScrollController();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _selection = _deduplicateByKey(
      widget.isMulti
          ? List<T>.of(widget.initialSelection)
          : <T>[if (widget.initialValue case final value?) value],
    );
    if (widget.itemKeyBuilder != null) {
      _selectionKeys = {
        for (final item in _selection) widget.itemKeyBuilder!(item),
      };
    }
    _items = _deduplicateByKey(widget.items ?? const []);
    if (widget.itemKeyBuilder != null) {
      _itemKeys = {
        for (final item in _items) widget.itemKeyBuilder!(item),
      };
    }
    _scrollController.addListener(_handleScroll);

    if (widget.isRemote) {
      Future<void> refresh() => _reloadRemote();
      _attachedRefresh = refresh;
      widget.controller?._attach(refresh);
      _loadingInitial = true;
      final generation = ++_requestGeneration;
      unawaited(_performInitialLoad(generation));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = widget.theme ?? SelectionSheetTheme.of(context);
  }

  @override
  void dispose() {
    _requestGeneration++;
    _cancelActiveRequests();
    _searchDebounceTimer?.cancel();
    if (_attachedRefresh case final refresh?) {
      widget.controller?._detach(refresh);
    }
    _scrollController.removeListener(_handleScroll);
    if (_ownsScrollController) _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  bool _equals(T first, T second) {
    if (widget.itemKeyBuilder case final keyBuilder?) {
      return keyBuilder(first) == keyBuilder(second);
    }
    return widget.itemEquals?.call(first, second) ?? first == second;
  }

  bool _isSelected(T item) {
    if (_selectionKeys case final keys?) {
      return keys.contains(widget.itemKeyBuilder!(item));
    }
    return _selection.any((selected) => _equals(selected, item));
  }

  List<T> _deduplicateByKey(Iterable<T> items) {
    if (widget.itemKeyBuilder == null) return List<T>.of(items);
    final keys = <Object>{};
    return [
      for (final item in items)
        if (keys.add(widget.itemKeyBuilder!(item))) item,
    ];
  }

  List<T> get _visibleItems {
    if (widget.isRemote || _query.isEmpty) return _items;
    final normalizedQuery = _query.toLowerCase();
    return _items.where((item) {
      return widget
          .itemLabelBuilder(item)
          .toLowerCase()
          .contains(normalizedQuery);
    }).toList(growable: false);
  }

  Future<void> _performInitialLoad(int generation) async {
    final cancellationToken = _createRequestToken();
    try {
      final page = await widget.loadItems!(
        SelectionSheetLoadRequest(
          query: _query,
          page: 1,
          pageSize: widget.pageSize,
          cancellationToken: cancellationToken,
        ),
      );
      if (!mounted ||
          cancellationToken.isCancelled ||
          generation != _requestGeneration) {
        return;
      }
      setState(() {
        _items = _deduplicateByKey(page.items);
        if (_itemKeys case final keys?) {
          keys
            ..clear()
            ..addAll(_items.map(widget.itemKeyBuilder!));
        }
        _nextPage = 2;
        _nextCursor = page.nextCursor;
        _hasMore = page.hasMore;
        _loadingInitial = false;
        _initialError = null;
      });
      _schedulePaginationCheck();
    } catch (error) {
      if (!mounted ||
          cancellationToken.isCancelled ||
          generation != _requestGeneration) {
        return;
      }
      setState(() {
        _loadingInitial = false;
        _initialError = error;
      });
    } finally {
      _activeRequestTokens.remove(cancellationToken);
    }
  }

  Future<void> _reloadRemote() {
    if (!widget.isRemote || !mounted) return Future<void>.value();
    _cancelActiveRequests();
    final generation = ++_requestGeneration;
    setState(() {
      _items = [];
      _nextPage = 1;
      _nextCursor = null;
      _hasMore = false;
      _loadingInitial = true;
      _loadingMore = false;
      _initialError = null;
      _loadMoreError = null;
    });
    return _performInitialLoad(generation);
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 240) {
      _loadNextPage();
    }
  }

  void _schedulePaginationCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _handleScroll();
    });
  }

  void _loadNextPage() {
    if (!widget.isRemote ||
        !_hasMore ||
        _loadingInitial ||
        _loadingMore ||
        _loadMoreError != null) {
      return;
    }

    final generation = _requestGeneration;
    final requestedPage = _nextPage;
    final requestedCursor = _nextCursor;
    setState(() => _loadingMore = true);
    unawaited(
      _performNextPage(generation, requestedPage, requestedCursor),
    );
  }

  Future<void> _performNextPage(
    int generation,
    int requestedPage,
    Object? requestedCursor,
  ) async {
    final cancellationToken = _createRequestToken();
    try {
      final page = await widget.loadItems!(
        SelectionSheetLoadRequest(
          query: _query,
          page: requestedPage,
          pageSize: widget.pageSize,
          cursor: requestedCursor,
          cancellationToken: cancellationToken,
        ),
      );
      if (!mounted ||
          cancellationToken.isCancelled ||
          generation != _requestGeneration) {
        return;
      }
      setState(() {
        if (_itemKeys case final keys?) {
          for (final item in page.items) {
            if (keys.add(widget.itemKeyBuilder!(item))) _items.add(item);
          }
        } else {
          _items.addAll(page.items);
        }
        _nextPage = requestedPage + 1;
        _nextCursor = page.nextCursor;
        _hasMore = page.hasMore;
        _loadingMore = false;
        _loadMoreError = null;
      });
      _schedulePaginationCheck();
    } catch (error) {
      if (!mounted ||
          cancellationToken.isCancelled ||
          generation != _requestGeneration) {
        return;
      }
      setState(() {
        _loadingMore = false;
        _loadMoreError = error;
      });
    } finally {
      _activeRequestTokens.remove(cancellationToken);
    }
  }

  SelectionSheetCancellationToken _createRequestToken() {
    final token = SelectionSheetCancellationToken();
    _activeRequestTokens.add(token);
    return token;
  }

  void _cancelActiveRequests() {
    final tokens = List<SelectionSheetCancellationToken>.of(
      _activeRequestTokens,
    );
    _activeRequestTokens.clear();
    for (final token in tokens) {
      token.cancel();
    }
  }

  void _retryNextPage() {
    setState(() => _loadMoreError = null);
    _loadNextPage();
  }

  void _select(T item) {
    if (widget.isItemEnabled?.call(item) == false) return;

    if (!widget.isMulti) {
      setState(() {
        _selection = [item];
        if (_selectionKeys case final keys?) {
          keys
            ..clear()
            ..add(widget.itemKeyBuilder!(item));
        }
      });
      widget.onSelected?.call(item);
      if (widget.popOnComplete) {
        Navigator.of(context).pop<T>(item);
      }
      return;
    }

    setState(() {
      final key = widget.itemKeyBuilder?.call(item);
      final isSelected =
          key == null ? _isSelected(item) : _selectionKeys!.contains(key);
      if (!isSelected) {
        _selection.add(item);
        if (key != null) _selectionKeys!.add(key);
      } else {
        _selection.removeWhere((selected) => _equals(selected, item));
        if (key != null) _selectionKeys!.remove(key);
      }
    });
    widget.onSelectionChanged?.call(List<T>.unmodifiable(_selection));
  }

  void _removeSelection(T item) {
    setState(() {
      _selection.removeWhere((selected) => _equals(selected, item));
      if (_selectionKeys case final keys?) {
        keys.remove(widget.itemKeyBuilder!(item));
      }
    });
    widget.onSelectionChanged?.call(List<T>.unmodifiable(_selection));
  }

  @override
  Widget build(BuildContext context) {
    final theme = _theme;
    final mediaQuery = MediaQuery.of(context);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: Material(
        color: theme.backgroundColor,
        surfaceTintColor: theme.surfaceTintColor,
        shape: theme.shape,
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              if (_showDragHandle) _buildDragHandle(context),
              _buildHeader(context),
              if (widget.searchable || widget.searchFieldBuilder != null)
                _buildSearch(context),
              if (widget.isMulti && _showSelectedChips && _selection.isNotEmpty)
                _buildSelectedChips(context),
              Expanded(child: _buildBody(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    final handle =
        (widget.dragHandleBuilder ?? _theme.dragHandleBuilder)?.call(context) ??
            _DragHandle(color: _theme.dragHandleColor);
    if (widget.onDragHandleUpdate == null) return handle;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: widget.onDragHandleUpdate,
      onVerticalDragEnd: widget.onDragHandleEnd,
      child: SizedBox(
        width: double.infinity,
        child: Center(child: handle),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (widget.title == null && !widget.isMulti) {
      return const SizedBox(height: 4);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 8, 4),
      child: Row(
        children: [
          if (widget.title case final title?)
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            )
          else
            const Spacer(),
          if (widget.isMulti)
            _AdaptiveTextButton(
              onPressed: () {
                final result = List<T>.unmodifiable(_selection);
                widget.onConfirmed?.call(result);
                if (widget.popOnComplete) {
                  Navigator.of(context).pop<List<T>>(result);
                }
              },
              label: widget.doneLabel ?? _theme.doneLabel,
              cupertino: _isCupertino,
            ),
        ],
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    final hint = widget.searchHintText ?? _theme.searchHintText;
    final customBuilder =
        widget.searchFieldBuilder ?? _theme.searchFieldBuilder;
    return Padding(
      padding: _theme.searchPadding,
      child: customBuilder?.call(
            context,
            SelectionSheetSearchFieldData(
              controller: _searchController,
              focusNode: _searchFocusNode,
              hintText: hint,
              query: _query,
              onChanged: _scheduleQueryUpdate,
              onClear: _clearSearch,
            ),
          ) ??
          (_isCupertino
              ? CupertinoSearchTextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  placeholder: hint,
                  onChanged: _scheduleQueryUpdate,
                )
              : TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: _scheduleQueryUpdate,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: hint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.clear),
                          ),
                    border: const OutlineInputBorder(),
                  ),
                )),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    _searchDebounceTimer?.cancel();
    _applyQuery('');
  }

  Widget _buildSelectedChips(BuildContext context) {
    return Padding(
      padding: _theme.selectedChipsPadding,
      child: SizedBox(
        height: _theme.selectedChipsHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _selection.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final item = _selection[index];
            final label = widget.itemLabelBuilder(item);
            void onDeleted() => _removeSelection(item);
            return widget.selectedChipBuilder?.call(
                  context,
                  item,
                  label,
                  onDeleted,
                ) ??
                InputChip(
                  label: Text(label),
                  onDeleted: onDeleted,
                );
          },
        ),
      ),
    );
  }

  void _scheduleQueryUpdate(String value) {
    _searchDebounceTimer?.cancel();
    if (_searchDebounceDuration == Duration.zero) {
      _applyQuery(value);
      return;
    }
    _searchDebounceTimer = Timer(
      _searchDebounceDuration,
      () => _applyQuery(value),
    );
  }

  void _applyQuery(String value) {
    if (!mounted) return;
    final query = value.trim();
    if (query == _query) return;
    if (widget.isRemote) {
      _query = query;
      unawaited(_reloadRemote());
    } else {
      setState(() => _query = query);
    }
  }

  Widget _buildBody(BuildContext context) {
    if (_loadingInitial) {
      final custom = widget.loadingBuilder?.call(context) ??
          _theme.loadingBuilder?.call(context);
      return custom == null
          ? const Center(child: CircularProgressIndicator())
          : Center(child: custom);
    }

    if (_initialError case final error?) {
      final retry = _reloadRemote;
      final custom = widget.errorBuilder?.call(context, error, retry) ??
          _theme.errorBuilder?.call(context, error, retry);
      return custom == null
          ? _DefaultErrorState(
              message: _theme.errorLabel,
              retryLabel: _theme.retryLabel,
              onRetry: retry,
            )
          : Center(child: custom);
    }

    final items = _visibleItems;
    if (items.isEmpty) {
      final custom = widget.emptyBuilder?.call(context, _query) ??
          _theme.emptyBuilder?.call(context, _query);
      return custom == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _theme.emptyLabel,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            )
          : Center(child: custom);
    }

    return _buildItems(context, items);
  }

  Widget _buildItems(BuildContext context, List<T> items) {
    final slivers = <Widget>[];
    if (widget.sectionBuilder == null) {
      slivers.add(
        SliverPadding(
          padding: _theme.contentPadding,
          sliver: _buildItemSliver(items),
        ),
      );
    } else {
      for (final section in _groupItems(items)) {
        slivers.add(
          SliverMainAxisGroup(
            slivers: [
              SliverPersistentHeader(
                pinned: widget.stickySectionHeaders,
                delegate: _SectionHeaderDelegate(
                  height: _theme.sectionHeaderHeight,
                  child: _buildSectionHeader(context, section),
                ),
              ),
              SliverPadding(
                padding: _theme.itemPadding,
                sliver: _buildItemSliver(
                  section.items,
                  applyItemPadding: false,
                ),
              ),
            ],
          ),
        );
      }
      slivers.add(
        SliverPadding(
          padding: EdgeInsets.only(
            bottom: _theme.contentPadding
                .resolve(Directionality.of(context))
                .bottom,
          ),
        ),
      );
    }

    if (_loadingMore || _loadMoreError != null) {
      slivers.add(
        SliverToBoxAdapter(child: _buildPaginationFooter(context)),
      );
    }

    final scrollView = CustomScrollView(
      controller: _scrollController,
      physics: widget.isRemote && widget.enablePullToRefresh
          ? const AlwaysScrollableScrollPhysics()
          : null,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: slivers,
    );
    if (!widget.isRemote || !widget.enablePullToRefresh) return scrollView;
    return RefreshIndicator.adaptive(
      onRefresh: _reloadRemote,
      child: scrollView,
    );
  }

  Widget _buildItemSliver(
    List<T> items, {
    bool applyItemPadding = true,
  }) {
    if (_layout == SelectionSheetLayout.grid) {
      return SliverGrid(
        gridDelegate: _gridDelegate,
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final child = _buildItem(context, items[index]);
            if (!applyItemPadding) return child;
            return Padding(padding: _theme.itemPadding, child: child);
          },
          childCount: items.length,
        ),
      );
    }

    final showDividers = _theme.showDividers;
    final childCount = showDividers ? items.length * 2 - 1 : items.length;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (showDividers && index.isOdd) {
            return const Divider(height: 1);
          }
          final itemIndex = showDividers ? index ~/ 2 : index;
          final child = _buildItem(context, items[itemIndex]);
          if (!applyItemPadding) return child;
          return Padding(padding: _theme.itemPadding, child: child);
        },
        childCount: childCount,
      ),
    );
  }

  List<_SectionGroup<T>> _groupItems(List<T> items) {
    final grouped = <Object?, List<T>>{};
    for (final item in items) {
      final key = widget.sectionBuilder!(item);
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return [
      for (final entry in grouped.entries)
        _SectionGroup<T>(
          data: SelectionSheetSectionData(
            key: entry.key,
            label: widget.sectionLabelBuilder?.call(entry.key) ??
                entry.key?.toString() ??
                '',
            itemCount: entry.value.length,
          ),
          items: entry.value,
        ),
    ];
  }

  Widget _buildSectionHeader(
    BuildContext context,
    _SectionGroup<T> section,
  ) {
    return widget.sectionHeaderBuilder?.call(context, section.data) ??
        _theme.sectionHeaderBuilder?.call(context, section.data) ??
        ColoredBox(
          color: _theme.backgroundColor ?? Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                section.data.label,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
        );
  }

  Widget _buildPaginationFooter(BuildContext context) {
    if (_loadingMore) {
      return widget.loadingMoreBuilder?.call(context) ??
          _theme.loadingMoreBuilder?.call(context) ??
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
    }

    final error = _loadMoreError!;
    final retry = _retryNextPage;
    return widget.loadMoreErrorBuilder?.call(context, error, retry) ??
        _theme.loadMoreErrorBuilder?.call(context, error, retry) ??
        Padding(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: TextButton.icon(
              onPressed: retry,
              icon: const Icon(Icons.refresh),
              label: Text(_theme.retryLabel),
            ),
          ),
        );
  }

  Widget _buildItem(BuildContext context, T item) {
    final selected = _isSelected(item);
    final enabled = widget.isItemEnabled?.call(item) ?? true;
    final label = widget.itemLabelBuilder(item);
    final state = SelectionItemState(
      isSelected: selected,
      isEnabled: enabled,
      query: _query,
    );
    final defaultChild = _DefaultSelectionItem(
      label: label,
      selected: selected,
      enabled: enabled,
      multi: widget.isMulti,
      cupertino: _isCupertino,
      selectedColor: _theme.selectedColor,
    );

    final child = widget.itemBuilder?.call(context, item, state) ??
        _theme.itemBuilder?.call(
          context,
          SelectionSheetItemData(
            item: item,
            label: label,
            isSelected: selected,
            isEnabled: enabled,
            query: _query,
            defaultChild: defaultChild,
          ),
        ) ??
        defaultChild;

    return Semantics(
      selected: selected,
      enabled: enabled,
      button: true,
      label: label,
      child: InkWell(
        onTap: enabled ? () => _select(item) : null,
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }
}

class _SectionGroup<T> {
  const _SectionGroup({required this.data, required this.items});

  final SelectionSheetSectionData data;
  final List<T> items;
}

class _SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _SectionHeaderDelegate({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SectionHeaderDelegate oldDelegate) {
    return height != oldDelegate.height || child != oldDelegate.child;
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle({required this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 32,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _AdaptiveTextButton extends StatelessWidget {
  const _AdaptiveTextButton({
    required this.onPressed,
    required this.label,
    required this.cupertino,
  });

  final VoidCallback onPressed;
  final String label;
  final bool cupertino;

  @override
  Widget build(BuildContext context) {
    if (cupertino) {
      return CupertinoButton(onPressed: onPressed, child: Text(label));
    }
    return TextButton(onPressed: onPressed, child: Text(label));
  }
}

class _DefaultErrorState extends StatelessWidget {
  const _DefaultErrorState({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 32),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}

class _DefaultSelectionItem extends StatelessWidget {
  const _DefaultSelectionItem({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.multi,
    required this.cupertino,
    required this.selectedColor,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final bool multi;
  final bool cupertino;
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      decoration: BoxDecoration(
        color: selected ? selectedColor : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        enabled: enabled,
        title: Text(label),
        trailing: _indicator(theme),
      ),
    );
  }

  Widget? _indicator(ThemeData theme) {
    if (multi && !cupertino) {
      return Checkbox(value: selected, onChanged: null);
    }
    if (selected) {
      return Icon(
        cupertino ? CupertinoIcons.check_mark : Icons.check,
        color: theme.colorScheme.primary,
      );
    }
    return null;
  }
}
