import 'package:flutter/widgets.dart';

/// Creates the text used for search, semantics, chips, and default item rows.
typedef SelectionItemLabelBuilder<T> = String Function(T item);

/// Builds a row for a typed item in a selection sheet.
typedef SelectionSheetItemBuilder<T> = Widget Function(
    BuildContext context, T item, SelectionItemState state);

/// Compares two items for selection equality.
typedef SelectionItemEquality<T> = bool Function(T first, T second);

/// Controls which route style presents the selection sheet.
enum SelectionSheetPresentation {
  /// Uses Cupertino presentation on Apple platforms and Material elsewhere.
  adaptive,

  /// Always uses a Material modal bottom sheet.
  material,

  /// Always uses a Cupertino modal popup.
  cupertino,
}

/// Presentation state supplied to a per-sheet [SelectionSheetItemBuilder].
@immutable
class SelectionItemState {
  /// Creates presentation state for an item.
  const SelectionItemState({
    required this.isSelected,
    required this.isEnabled,
    required this.query,
  });

  /// Whether the item is currently selected.
  final bool isSelected;

  /// Whether the item can be selected.
  final bool isEnabled;

  /// The current normalized search query.
  final String query;
}

/// Type-erased item information supplied to a global theme builder.
///
/// A global builder intentionally receives the resolved [label], allowing one
/// renderer to work for every item type. Use a typed per-sheet builder when a
/// row needs fields from the original model.
@immutable
class SelectionSheetItemData {
  /// Creates item data for a global renderer.
  const SelectionSheetItemData({
    required this.item,
    required this.label,
    required this.isSelected,
    required this.isEnabled,
    required this.query,
    required this.defaultChild,
  });

  /// The original item, with its static type erased.
  final Object? item;

  /// The label resolved by the sheet's item label builder.
  final String label;

  /// Whether the item is currently selected.
  final bool isSelected;

  /// Whether the item can be selected.
  final bool isEnabled;

  /// The current normalized search query.
  final String query;

  /// The package's default adaptive row.
  ///
  /// Global builders can decorate this child instead of rebuilding a complete
  /// row.
  final Widget defaultChild;
}

/// Builds item rows for all selection sheets below a theme.
typedef SelectionSheetGlobalItemBuilder = Widget Function(
    BuildContext context, SelectionSheetItemData item);
