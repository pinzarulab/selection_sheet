import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'selection_sheet_theme.dart';
import 'selection_sheet_types.dart';
import 'selection_sheet_view.dart';

/// Presents adaptive selection workflows as modal sheets.
abstract final class SelectionSheet {
  /// Shows a local or remote single-selection sheet.
  ///
  /// Provide exactly one of [items] or [loadItems]. Returns the selected item,
  /// or `null` when the sheet is dismissed.
  static Future<T?> showSingle<T>({
    required BuildContext context,
    required SelectionItemLabelBuilder<T> itemLabelBuilder,
    SelectionSheetViewItem<T>? item,
    List<T>? items,
    SelectionSheetPageLoader<T>? loadItems,
    int? pageSize,
    String? title,
    T? initialValue,
    bool searchable = false,
    String? searchHintText,
    Duration? searchDebounceDuration,
    SelectionSheetSearchFieldBuilder? searchFieldBuilder,
    SelectionSheetItemBuilder<T>? itemBuilder,
    bool Function(T item)? isItemEnabled,
    SelectionItemEquality<T>? itemEquals,
    SelectionItemKeyBuilder<T>? itemKeyBuilder,
    SelectionSheetSectionBuilder<T>? sectionBuilder,
    SelectionSheetSectionLabelBuilder? sectionLabelBuilder,
    SelectionSheetSectionHeaderBuilder? sectionHeaderBuilder,
    bool stickySectionHeaders = true,
    SelectionSheetLayout? layout,
    SliverGridDelegate? gridDelegate,
    SelectionSheetLoadingBuilder? loadingBuilder,
    SelectionSheetEmptyBuilder? emptyBuilder,
    SelectionSheetErrorBuilder? errorBuilder,
    SelectionSheetLoadingBuilder? loadingMoreBuilder,
    SelectionSheetErrorBuilder? loadMoreErrorBuilder,
    SelectionSheetController? controller,
    bool enablePullToRefresh = true,
    SelectionSheetThemeData? theme,
    SelectionSheetPresentation presentation =
        SelectionSheetPresentation.adaptive,
    bool useRootNavigator = false,
    bool isDismissible = true,
  }) {
    final hasDirectSource = items != null || loadItems != null;
    final resolvedItems = hasDirectSource ? items : item?.items;
    final resolvedLoadItems = hasDirectSource ? loadItems : item?.loadItems;
    final resolvedPageSize = pageSize ?? item?.pageSize ?? 20;
    final resolvedTitle = title ?? item?.title;
    final resolvedInitialValue = initialValue ?? item?.initialValue;
    final resolvedSearchHintText = searchHintText ?? item?.hintText;
    _validateSource(resolvedItems, resolvedLoadItems, resolvedPageSize);
    final resolvedTheme = theme ?? SelectionSheetTheme.of(context);
    return _show<T>(
      context: context,
      presentation: presentation,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      theme: resolvedTheme,
      builder: (sheetContext, scrollController) {
        return SelectionSheetView<T>.single(
          items: resolvedItems,
          loadItems: resolvedLoadItems,
          pageSize: resolvedPageSize,
          itemLabelBuilder: itemLabelBuilder,
          title: resolvedTitle,
          initialValue: resolvedInitialValue,
          searchable: searchable || searchFieldBuilder != null,
          searchHintText: resolvedSearchHintText,
          searchDebounceDuration: _resolveSearchDebounceDuration(
            searchDebounceDuration,
            resolvedTheme,
          ),
          searchFieldBuilder: searchFieldBuilder,
          itemBuilder: itemBuilder,
          isItemEnabled: isItemEnabled,
          itemEquals: itemEquals,
          itemKeyBuilder: itemKeyBuilder,
          sectionBuilder: sectionBuilder,
          sectionLabelBuilder: sectionLabelBuilder,
          sectionHeaderBuilder: sectionHeaderBuilder,
          stickySectionHeaders: stickySectionHeaders,
          layout: layout ?? resolvedTheme.layout,
          gridDelegate: gridDelegate ?? resolvedTheme.gridDelegate,
          loadingBuilder: loadingBuilder,
          emptyBuilder: emptyBuilder,
          errorBuilder: errorBuilder,
          loadingMoreBuilder: loadingMoreBuilder,
          loadMoreErrorBuilder: loadMoreErrorBuilder,
          controller: controller,
          enablePullToRefresh: enablePullToRefresh,
          theme: resolvedTheme,
          scrollController: scrollController,
          popOnComplete: true,
        );
      },
    );
  }

  /// Shows a local or remote multi-selection sheet.
  ///
  /// Provide exactly one of [items] or [loadItems]. Changes remain a draft
  /// until the confirmation action is pressed. Returns the confirmed
  /// selection, or `null` when dismissed.
  static Future<List<T>?> showMulti<T>({
    required BuildContext context,
    required SelectionItemLabelBuilder<T> itemLabelBuilder,
    SelectionSheetViewItem<T>? item,
    List<T>? items,
    SelectionSheetPageLoader<T>? loadItems,
    int? pageSize,
    String? title,
    Iterable<T>? initialSelection,
    bool searchable = false,
    String? searchHintText,
    Duration? searchDebounceDuration,
    SelectionSheetSearchFieldBuilder? searchFieldBuilder,
    String? doneLabel,
    SelectionSheetItemBuilder<T>? itemBuilder,
    bool Function(T item)? isItemEnabled,
    SelectionItemEquality<T>? itemEquals,
    SelectionItemKeyBuilder<T>? itemKeyBuilder,
    SelectionSheetSectionBuilder<T>? sectionBuilder,
    SelectionSheetSectionLabelBuilder? sectionLabelBuilder,
    SelectionSheetSectionHeaderBuilder? sectionHeaderBuilder,
    bool stickySectionHeaders = true,
    SelectionSheetLayout? layout,
    SliverGridDelegate? gridDelegate,
    bool? showSelectedChips,
    SelectionSheetSelectedChipBuilder<T>? selectedChipBuilder,
    SelectionSheetLoadingBuilder? loadingBuilder,
    SelectionSheetEmptyBuilder? emptyBuilder,
    SelectionSheetErrorBuilder? errorBuilder,
    SelectionSheetLoadingBuilder? loadingMoreBuilder,
    SelectionSheetErrorBuilder? loadMoreErrorBuilder,
    SelectionSheetController? controller,
    bool enablePullToRefresh = true,
    SelectionSheetThemeData? theme,
    SelectionSheetPresentation presentation =
        SelectionSheetPresentation.adaptive,
    bool useRootNavigator = false,
    bool isDismissible = true,
  }) {
    final hasDirectSource = items != null || loadItems != null;
    final resolvedItems = hasDirectSource ? items : item?.items;
    final resolvedLoadItems = hasDirectSource ? loadItems : item?.loadItems;
    final resolvedPageSize = pageSize ?? item?.pageSize ?? 20;
    final resolvedTitle = title ?? item?.title;
    final resolvedInitialSelection =
        initialSelection ?? item?.initialSelection ?? const [];
    final resolvedSearchHintText = searchHintText ?? item?.hintText;
    _validateSource(resolvedItems, resolvedLoadItems, resolvedPageSize);
    final resolvedTheme = theme ?? SelectionSheetTheme.of(context);
    return _show<List<T>>(
      context: context,
      presentation: presentation,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      theme: resolvedTheme,
      builder: (sheetContext, scrollController) {
        return SelectionSheetView<T>.multi(
          items: resolvedItems,
          loadItems: resolvedLoadItems,
          pageSize: resolvedPageSize,
          itemLabelBuilder: itemLabelBuilder,
          title: resolvedTitle,
          initialSelection: resolvedInitialSelection,
          searchable: searchable || searchFieldBuilder != null,
          searchHintText: resolvedSearchHintText,
          searchDebounceDuration: _resolveSearchDebounceDuration(
            searchDebounceDuration,
            resolvedTheme,
          ),
          searchFieldBuilder: searchFieldBuilder,
          doneLabel: doneLabel,
          itemBuilder: itemBuilder,
          isItemEnabled: isItemEnabled,
          itemEquals: itemEquals,
          itemKeyBuilder: itemKeyBuilder,
          sectionBuilder: sectionBuilder,
          sectionLabelBuilder: sectionLabelBuilder,
          sectionHeaderBuilder: sectionHeaderBuilder,
          stickySectionHeaders: stickySectionHeaders,
          layout: layout ?? resolvedTheme.layout,
          gridDelegate: gridDelegate ?? resolvedTheme.gridDelegate,
          showSelectedChips:
              showSelectedChips ?? resolvedTheme.showSelectedChips,
          selectedChipBuilder: selectedChipBuilder,
          loadingBuilder: loadingBuilder,
          emptyBuilder: emptyBuilder,
          errorBuilder: errorBuilder,
          loadingMoreBuilder: loadingMoreBuilder,
          loadMoreErrorBuilder: loadMoreErrorBuilder,
          controller: controller,
          enablePullToRefresh: enablePullToRefresh,
          theme: resolvedTheme,
          scrollController: scrollController,
          popOnComplete: true,
        );
      },
    );
  }

  static void _validateSource<T>(
    List<T>? items,
    SelectionSheetPageLoader<T>? loadItems,
    int pageSize,
  ) {
    if ((items == null) == (loadItems == null)) {
      throw ArgumentError(
        'Provide exactly one of items or loadItems.',
      );
    }
    if (pageSize <= 0) {
      throw ArgumentError.value(pageSize, 'pageSize', 'must be greater than 0');
    }
  }

  static Future<R?> _show<R>({
    required BuildContext context,
    required SelectionSheetPresentation presentation,
    required bool useRootNavigator,
    required bool isDismissible,
    required SelectionSheetThemeData theme,
    required Widget Function(
      BuildContext context,
      ScrollController scrollController,
    ) builder,
  }) {
    final platform = Theme.of(context).platform;
    final useCupertino = presentation == SelectionSheetPresentation.cupertino ||
        presentation == SelectionSheetPresentation.adaptive &&
            (platform == TargetPlatform.iOS ||
                platform == TargetPlatform.macOS);

    Widget sheetBuilder(BuildContext routeContext) {
      return DraggableScrollableSheet(
        initialChildSize: theme.initialHeight,
        minChildSize: theme.minHeight,
        maxChildSize: theme.maxHeight,
        expand: false,
        builder: builder,
      );
    }

    if (useCupertino) {
      return showCupertinoModalPopup<R>(
        context: context,
        useRootNavigator: useRootNavigator,
        barrierDismissible: isDismissible,
        builder: (routeContext) => Align(
          alignment: Alignment.bottomCenter,
          child: sheetBuilder(routeContext),
        ),
      );
    }

    return showModalBottomSheet<R>(
      context: context,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: sheetBuilder,
    );
  }

  static Duration _resolveSearchDebounceDuration(
    Duration? override,
    SelectionSheetThemeData theme,
  ) {
    final duration = override ?? theme.searchDebounceDuration;
    if (duration.isNegative) {
      throw ArgumentError.value(
        duration,
        'searchDebounceDuration',
        'must not be negative',
      );
    }
    return duration;
  }
}
