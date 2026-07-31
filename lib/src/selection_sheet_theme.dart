import 'package:flutter/material.dart';

import 'selection_sheet_types.dart';

/// Visual defaults inherited by selection sheets below this widget.
///
/// Place this widget inside `MaterialApp.builder` to configure every sheet in
/// an application. Any option passed directly to a sheet takes precedence.
class SelectionSheetTheme extends InheritedTheme {
  /// Creates a selection sheet theme.
  const SelectionSheetTheme({
    required this.data,
    required super.child,
    super.key,
  });

  /// The visual defaults for descendant selection sheets.
  final SelectionSheetThemeData data;

  /// Returns the nearest theme, or defaults derived from Flutter's theme.
  static SelectionSheetThemeData of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<SelectionSheetTheme>();
    return inherited?.data ?? SelectionSheetThemeData.fallback(context);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return SelectionSheetTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(SelectionSheetTheme oldWidget) {
    return data != oldWidget.data;
  }
}

/// Design tokens and global builders for [SelectionSheetTheme].
@immutable
class SelectionSheetThemeData {
  /// Creates selection sheet theme data.
  const SelectionSheetThemeData({
    this.shape,
    this.backgroundColor,
    this.surfaceTintColor,
    this.dragHandleColor,
    this.selectedColor,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    this.contentPadding = const EdgeInsets.only(bottom: 12),
    this.searchPadding = const EdgeInsets.fromLTRB(16, 8, 16, 8),
    this.searchDebounceDuration = const Duration(milliseconds: 300),
    this.searchFieldBuilder,
    this.itemBuilder,
    this.sectionHeaderBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.loadingMoreBuilder,
    this.loadMoreErrorBuilder,
    this.showDragHandle = true,
    this.showDividers = false,
    this.showSelectedChips = true,
    this.selectedChipsPadding = const EdgeInsets.fromLTRB(16, 0, 16, 8),
    this.selectedChipsHeight = 42,
    this.sectionHeaderHeight = 44,
    this.layout = SelectionSheetLayout.list,
    this.gridDelegate = const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 320,
      childAspectRatio: 4,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
    ),
    this.initialHeight = 0.72,
    this.minHeight = 0.35,
    this.maxHeight = 0.95,
    this.searchHintText = 'Search',
    this.doneLabel = 'Done',
    this.emptyLabel = 'No items found',
    this.errorLabel = 'Could not load items',
    this.retryLabel = 'Retry',
  })  : assert(minHeight > 0 && minHeight <= 1),
        assert(selectedChipsHeight > 0),
        assert(sectionHeaderHeight > 0),
        assert(initialHeight >= minHeight && initialHeight <= maxHeight),
        assert(maxHeight <= 1);

  /// Creates defaults derived from the ambient Material theme.
  factory SelectionSheetThemeData.fallback(BuildContext context) {
    final theme = Theme.of(context);
    return SelectionSheetThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      dragHandleColor: theme.colorScheme.onSurfaceVariant.withValues(
        alpha: 0.4,
      ),
      selectedColor: theme.colorScheme.secondaryContainer,
    );
  }

  /// Shape of the sheet surface.
  final ShapeBorder? shape;

  /// Sheet background color.
  final Color? backgroundColor;

  /// Material surface tint color.
  final Color? surfaceTintColor;

  /// Color of the drag handle.
  final Color? dragHandleColor;

  /// Background color used by the default selected row.
  final Color? selectedColor;

  /// Padding around each item row.
  final EdgeInsetsGeometry itemPadding;

  /// Padding around the scrollable content.
  final EdgeInsetsGeometry contentPadding;

  /// Padding around the search field.
  final EdgeInsetsGeometry searchPadding;

  /// Delay between the latest search input and filtering the item list.
  ///
  /// Set this to [Duration.zero] to disable debouncing globally.
  final Duration searchDebounceDuration;

  /// Optional application-wide search input.
  final SelectionSheetSearchFieldBuilder? searchFieldBuilder;

  /// Optional application-wide item renderer.
  final SelectionSheetGlobalItemBuilder? itemBuilder;

  /// Optional application-wide section header renderer.
  final SelectionSheetSectionHeaderBuilder? sectionHeaderBuilder;

  /// Optional application-wide initial loading state.
  final SelectionSheetLoadingBuilder? loadingBuilder;

  /// Optional application-wide empty state.
  final SelectionSheetEmptyBuilder? emptyBuilder;

  /// Optional application-wide initial error state.
  final SelectionSheetErrorBuilder? errorBuilder;

  /// Optional application-wide pagination loading footer.
  final SelectionSheetLoadingBuilder? loadingMoreBuilder;

  /// Optional application-wide pagination error footer.
  final SelectionSheetErrorBuilder? loadMoreErrorBuilder;

  /// Whether to show a drag handle.
  final bool showDragHandle;

  /// Whether to draw dividers between default rows.
  final bool showDividers;

  /// Whether multi-selection sheets show selected-item chips.
  final bool showSelectedChips;

  /// Padding around selected-item chips.
  final EdgeInsetsGeometry selectedChipsPadding;

  /// Height of the horizontal selected-item chip list.
  final double selectedChipsHeight;

  /// Height of each section header.
  final double sectionHeaderHeight;

  /// Default item arrangement.
  final SelectionSheetLayout layout;

  /// Default grid geometry when [layout] is [SelectionSheetLayout.grid].
  final SliverGridDelegate gridDelegate;

  /// Initial fractional height of the sheet.
  final double initialHeight;

  /// Minimum fractional height while dragging.
  final double minHeight;

  /// Maximum fractional height while dragging.
  final double maxHeight;

  /// Default placeholder for searchable sheets.
  final String searchHintText;

  /// Default confirmation label for multi-selection.
  final String doneLabel;

  /// Default text shown when filtering produces no items.
  final String emptyLabel;

  /// Default initial loading error text.
  final String errorLabel;

  /// Default retry action text.
  final String retryLabel;

  /// Returns a copy with selected values replaced.
  SelectionSheetThemeData copyWith({
    ShapeBorder? shape,
    Color? backgroundColor,
    Color? surfaceTintColor,
    Color? dragHandleColor,
    Color? selectedColor,
    EdgeInsetsGeometry? itemPadding,
    EdgeInsetsGeometry? contentPadding,
    EdgeInsetsGeometry? searchPadding,
    Duration? searchDebounceDuration,
    SelectionSheetSearchFieldBuilder? searchFieldBuilder,
    bool clearSearchFieldBuilder = false,
    SelectionSheetGlobalItemBuilder? itemBuilder,
    bool clearItemBuilder = false,
    SelectionSheetSectionHeaderBuilder? sectionHeaderBuilder,
    bool clearSectionHeaderBuilder = false,
    SelectionSheetLoadingBuilder? loadingBuilder,
    SelectionSheetEmptyBuilder? emptyBuilder,
    SelectionSheetErrorBuilder? errorBuilder,
    SelectionSheetLoadingBuilder? loadingMoreBuilder,
    SelectionSheetErrorBuilder? loadMoreErrorBuilder,
    bool? showDragHandle,
    bool? showDividers,
    bool? showSelectedChips,
    EdgeInsetsGeometry? selectedChipsPadding,
    double? selectedChipsHeight,
    double? sectionHeaderHeight,
    SelectionSheetLayout? layout,
    SliverGridDelegate? gridDelegate,
    double? initialHeight,
    double? minHeight,
    double? maxHeight,
    String? searchHintText,
    String? doneLabel,
    String? emptyLabel,
    String? errorLabel,
    String? retryLabel,
  }) {
    return SelectionSheetThemeData(
      shape: shape ?? this.shape,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceTintColor: surfaceTintColor ?? this.surfaceTintColor,
      dragHandleColor: dragHandleColor ?? this.dragHandleColor,
      selectedColor: selectedColor ?? this.selectedColor,
      itemPadding: itemPadding ?? this.itemPadding,
      contentPadding: contentPadding ?? this.contentPadding,
      searchPadding: searchPadding ?? this.searchPadding,
      searchDebounceDuration:
          searchDebounceDuration ?? this.searchDebounceDuration,
      searchFieldBuilder: clearSearchFieldBuilder
          ? null
          : searchFieldBuilder ?? this.searchFieldBuilder,
      itemBuilder: clearItemBuilder ? null : itemBuilder ?? this.itemBuilder,
      sectionHeaderBuilder: clearSectionHeaderBuilder
          ? null
          : sectionHeaderBuilder ?? this.sectionHeaderBuilder,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      emptyBuilder: emptyBuilder ?? this.emptyBuilder,
      errorBuilder: errorBuilder ?? this.errorBuilder,
      loadingMoreBuilder: loadingMoreBuilder ?? this.loadingMoreBuilder,
      loadMoreErrorBuilder: loadMoreErrorBuilder ?? this.loadMoreErrorBuilder,
      showDragHandle: showDragHandle ?? this.showDragHandle,
      showDividers: showDividers ?? this.showDividers,
      showSelectedChips: showSelectedChips ?? this.showSelectedChips,
      selectedChipsPadding: selectedChipsPadding ?? this.selectedChipsPadding,
      selectedChipsHeight: selectedChipsHeight ?? this.selectedChipsHeight,
      sectionHeaderHeight: sectionHeaderHeight ?? this.sectionHeaderHeight,
      layout: layout ?? this.layout,
      gridDelegate: gridDelegate ?? this.gridDelegate,
      initialHeight: initialHeight ?? this.initialHeight,
      minHeight: minHeight ?? this.minHeight,
      maxHeight: maxHeight ?? this.maxHeight,
      searchHintText: searchHintText ?? this.searchHintText,
      doneLabel: doneLabel ?? this.doneLabel,
      emptyLabel: emptyLabel ?? this.emptyLabel,
      errorLabel: errorLabel ?? this.errorLabel,
      retryLabel: retryLabel ?? this.retryLabel,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SelectionSheetThemeData &&
            other.shape == shape &&
            other.backgroundColor == backgroundColor &&
            other.surfaceTintColor == surfaceTintColor &&
            other.dragHandleColor == dragHandleColor &&
            other.selectedColor == selectedColor &&
            other.itemPadding == itemPadding &&
            other.contentPadding == contentPadding &&
            other.searchPadding == searchPadding &&
            other.searchDebounceDuration == searchDebounceDuration &&
            other.searchFieldBuilder == searchFieldBuilder &&
            other.itemBuilder == itemBuilder &&
            other.sectionHeaderBuilder == sectionHeaderBuilder &&
            other.loadingBuilder == loadingBuilder &&
            other.emptyBuilder == emptyBuilder &&
            other.errorBuilder == errorBuilder &&
            other.loadingMoreBuilder == loadingMoreBuilder &&
            other.loadMoreErrorBuilder == loadMoreErrorBuilder &&
            other.showDragHandle == showDragHandle &&
            other.showDividers == showDividers &&
            other.showSelectedChips == showSelectedChips &&
            other.selectedChipsPadding == selectedChipsPadding &&
            other.selectedChipsHeight == selectedChipsHeight &&
            other.sectionHeaderHeight == sectionHeaderHeight &&
            other.layout == layout &&
            other.gridDelegate == gridDelegate &&
            other.initialHeight == initialHeight &&
            other.minHeight == minHeight &&
            other.maxHeight == maxHeight &&
            other.searchHintText == searchHintText &&
            other.doneLabel == doneLabel &&
            other.emptyLabel == emptyLabel &&
            other.errorLabel == errorLabel &&
            other.retryLabel == retryLabel;
  }

  @override
  int get hashCode => Object.hashAll([
        shape,
        backgroundColor,
        surfaceTintColor,
        dragHandleColor,
        selectedColor,
        itemPadding,
        contentPadding,
        searchPadding,
        searchDebounceDuration,
        searchFieldBuilder,
        itemBuilder,
        sectionHeaderBuilder,
        loadingBuilder,
        emptyBuilder,
        errorBuilder,
        loadingMoreBuilder,
        loadMoreErrorBuilder,
        showDragHandle,
        showDividers,
        showSelectedChips,
        selectedChipsPadding,
        selectedChipsHeight,
        sectionHeaderHeight,
        layout,
        gridDelegate,
        initialHeight,
        minHeight,
        maxHeight,
        searchHintText,
        doneLabel,
        emptyLabel,
        errorLabel,
        retryLabel,
      ]);
}
