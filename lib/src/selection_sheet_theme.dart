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
    this.itemBuilder,
    this.showDragHandle = true,
    this.showDividers = false,
    this.initialHeight = 0.72,
    this.minHeight = 0.35,
    this.maxHeight = 0.95,
    this.searchHintText = 'Search',
    this.doneLabel = 'Done',
    this.emptyLabel = 'No items found',
  })  : assert(minHeight > 0 && minHeight <= 1),
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

  /// Optional application-wide item renderer.
  final SelectionSheetGlobalItemBuilder? itemBuilder;

  /// Whether to show a drag handle.
  final bool showDragHandle;

  /// Whether to draw dividers between default rows.
  final bool showDividers;

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
    SelectionSheetGlobalItemBuilder? itemBuilder,
    bool clearItemBuilder = false,
    bool? showDragHandle,
    bool? showDividers,
    double? initialHeight,
    double? minHeight,
    double? maxHeight,
    String? searchHintText,
    String? doneLabel,
    String? emptyLabel,
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
      itemBuilder: clearItemBuilder ? null : itemBuilder ?? this.itemBuilder,
      showDragHandle: showDragHandle ?? this.showDragHandle,
      showDividers: showDividers ?? this.showDividers,
      initialHeight: initialHeight ?? this.initialHeight,
      minHeight: minHeight ?? this.minHeight,
      maxHeight: maxHeight ?? this.maxHeight,
      searchHintText: searchHintText ?? this.searchHintText,
      doneLabel: doneLabel ?? this.doneLabel,
      emptyLabel: emptyLabel ?? this.emptyLabel,
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
            other.itemBuilder == itemBuilder &&
            other.showDragHandle == showDragHandle &&
            other.showDividers == showDividers &&
            other.initialHeight == initialHeight &&
            other.minHeight == minHeight &&
            other.maxHeight == maxHeight &&
            other.searchHintText == searchHintText &&
            other.doneLabel == doneLabel &&
            other.emptyLabel == emptyLabel;
  }

  @override
  int get hashCode => Object.hash(
        shape,
        backgroundColor,
        surfaceTintColor,
        dragHandleColor,
        selectedColor,
        itemPadding,
        contentPadding,
        searchPadding,
        searchDebounceDuration,
        itemBuilder,
        showDragHandle,
        showDividers,
        initialHeight,
        minHeight,
        maxHeight,
        searchHintText,
        doneLabel,
        emptyLabel,
      );
}
