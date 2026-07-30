import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'selection_sheet_theme.dart';
import 'selection_sheet_types.dart';

class SelectionSheetView<T> extends StatefulWidget {
  const SelectionSheetView.single({
    required this.items,
    required this.itemLabelBuilder,
    required this.searchable,
    required this.searchDebounceDuration,
    required this.theme,
    required this.scrollController,
    this.title,
    this.initialValue,
    this.searchHintText,
    this.itemBuilder,
    this.isItemEnabled,
    this.itemEquals,
    super.key,
  })  : isMulti = false,
        initialSelection = const [],
        doneLabel = null;

  const SelectionSheetView.multi({
    required this.items,
    required this.itemLabelBuilder,
    required this.searchable,
    required this.searchDebounceDuration,
    required this.theme,
    required this.scrollController,
    required this.initialSelection,
    this.title,
    this.searchHintText,
    this.doneLabel,
    this.itemBuilder,
    this.isItemEnabled,
    this.itemEquals,
    super.key,
  })  : isMulti = true,
        initialValue = null;

  final List<T> items;
  final SelectionItemLabelBuilder<T> itemLabelBuilder;
  final String? title;
  final T? initialValue;
  final Iterable<T> initialSelection;
  final bool searchable;
  final String? searchHintText;
  final Duration searchDebounceDuration;
  final String? doneLabel;
  final SelectionSheetItemBuilder<T>? itemBuilder;
  final bool Function(T item)? isItemEnabled;
  final SelectionItemEquality<T>? itemEquals;
  final SelectionSheetThemeData theme;
  final ScrollController scrollController;
  final bool isMulti;

  @override
  State<SelectionSheetView<T>> createState() => _SelectionSheetViewState<T>();
}

class _SelectionSheetViewState<T> extends State<SelectionSheetView<T>> {
  late final TextEditingController _searchController;
  late List<T> _selection;
  Timer? _searchDebounceTimer;
  String _query = '';

  bool get _isCupertino {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selection = widget.isMulti
        ? List<T>.of(widget.initialSelection)
        : <T>[if (widget.initialValue case final value?) value];
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  bool _equals(T first, T second) {
    return widget.itemEquals?.call(first, second) ?? first == second;
  }

  bool _isSelected(T item) {
    return _selection.any((selected) => _equals(selected, item));
  }

  List<T> get _visibleItems {
    if (_query.isEmpty) return widget.items;
    return widget.items.where((item) {
      return widget.itemLabelBuilder(item).toLowerCase().contains(_query);
    }).toList(growable: false);
  }

  void _select(T item) {
    if (widget.isItemEnabled?.call(item) == false) return;

    if (!widget.isMulti) {
      Navigator.of(context).pop<T>(item);
      return;
    }

    setState(() {
      final index = _selection.indexWhere(
        (selected) => _equals(selected, item),
      );
      if (index == -1) {
        _selection.add(item);
      } else {
        _selection.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
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
              if (theme.showDragHandle)
                _DragHandle(color: theme.dragHandleColor),
              _buildHeader(context),
              if (widget.searchable) _buildSearch(context),
              Expanded(child: _buildItems(context)),
            ],
          ),
        ),
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
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            )
          else
            const Spacer(),
          if (widget.isMulti)
            _AdaptiveTextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop<List<T>>(List<T>.unmodifiable(_selection));
              },
              label: widget.doneLabel ?? widget.theme.doneLabel,
              cupertino: _isCupertino,
            ),
        ],
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    final hint = widget.searchHintText ?? widget.theme.searchHintText;
    return Padding(
      padding: widget.theme.searchPadding,
      child: _isCupertino
          ? CupertinoSearchTextField(
              controller: _searchController,
              placeholder: hint,
              onChanged: _scheduleQueryUpdate,
            )
          : TextField(
              controller: _searchController,
              onChanged: _scheduleQueryUpdate,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          _searchDebounceTimer?.cancel();
                          _applyQuery('');
                        },
                        icon: const Icon(Icons.clear),
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
    );
  }

  void _scheduleQueryUpdate(String value) {
    _searchDebounceTimer?.cancel();
    if (widget.searchDebounceDuration == Duration.zero) {
      _applyQuery(value);
      return;
    }
    _searchDebounceTimer = Timer(
      widget.searchDebounceDuration,
      () => _applyQuery(value),
    );
  }

  void _applyQuery(String value) {
    if (!mounted) return;
    setState(() => _query = value.trim().toLowerCase());
  }

  Widget _buildItems(BuildContext context) {
    final items = _visibleItems;
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            widget.theme.emptyLabel,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return ListView.separated(
      controller: widget.scrollController,
      padding: widget.theme.contentPadding,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: items.length,
      separatorBuilder: (context, index) => widget.theme.showDividers
          ? const Divider(height: 1)
          : const SizedBox.shrink(),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItem(context, item);
      },
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
      selectedColor: widget.theme.selectedColor,
    );

    final child = widget.itemBuilder?.call(context, item, state) ??
        widget.theme.itemBuilder?.call(
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

    return Padding(
      padding: widget.theme.itemPadding,
      child: Semantics(
        selected: selected,
        enabled: enabled,
        button: true,
        label: label,
        child: InkWell(
          onTap: enabled ? () => _select(item) : null,
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      ),
    );
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
