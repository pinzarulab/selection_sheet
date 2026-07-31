import 'package:flutter/widgets.dart';

/// Creates the text used for search, semantics, chips, and default item rows.
typedef SelectionItemLabelBuilder<T> = String Function(T item);

/// Builds a row for a typed item in a selection sheet.
typedef SelectionSheetItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  SelectionItemState state,
);

/// Compares two items for selection equality.
typedef SelectionItemEquality<T> = bool Function(T first, T second);

/// Resolves the stable identity used for selection and page deduplication.
typedef SelectionItemKeyBuilder<T> = Object Function(T item);

/// Builds the search input shown above selection results.
typedef SelectionSheetSearchFieldBuilder = Widget Function(
  BuildContext context,
  SelectionSheetSearchFieldData search,
);

/// Loads one page of remote items.
typedef SelectionSheetPageLoader<T> = Future<SelectionSheetPage<T>> Function(
    SelectionSheetLoadRequest request);

/// Resolves the section key for an item.
typedef SelectionSheetSectionBuilder<T> = Object? Function(T item);

/// Creates a display label for a section key.
typedef SelectionSheetSectionLabelBuilder = String Function(Object? section);

/// Builds a sticky or non-sticky section header.
typedef SelectionSheetSectionHeaderBuilder = Widget Function(
    BuildContext context, SelectionSheetSectionData section);

/// Builds a selected-item chip for a typed item.
typedef SelectionSheetSelectedChipBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  String label,
  VoidCallback onDeleted,
);

/// Builds a loading state.
typedef SelectionSheetLoadingBuilder = Widget Function(BuildContext context);

/// Builds an empty state.
typedef SelectionSheetEmptyBuilder = Widget Function(
    BuildContext context, String query);

/// Builds an error state with a retry action.
typedef SelectionSheetErrorBuilder = Widget Function(
  BuildContext context,
  Object error,
  VoidCallback retry,
);

/// Controls how selection items are arranged.
enum SelectionSheetLayout {
  /// A vertically scrolling list.
  list,

  /// A configurable scrolling grid.
  grid,
}

/// Controls which route style presents the selection sheet.
enum SelectionSheetPresentation {
  /// Uses Cupertino presentation on Apple platforms and Material elsewhere.
  adaptive,

  /// Always uses a Material modal bottom sheet.
  material,

  /// Always uses a Cupertino modal popup.
  cupertino,
}

/// Optional reusable source and header configuration for modal helpers.
///
/// Pass this to `SelectionSheet.showSingle` or `SelectionSheet.showMulti`.
/// Any equivalent argument supplied directly to the helper takes precedence.
@immutable
class SelectionSheetViewItem<T> {
  /// Creates a partial selection-view configuration.
  const SelectionSheetViewItem({
    this.items,
    this.loadItems,
    this.pageSize,
    this.initialValue,
    this.initialSelection,
    this.hintText,
    this.title,
  }) : assert(pageSize == null || pageSize > 0);

  /// Local items, mutually exclusive with [loadItems] after resolution.
  final List<T>? items;

  /// Remote loader, mutually exclusive with [items] after resolution.
  final SelectionSheetPageLoader<T>? loadItems;

  /// Number of remote items requested per page.
  final int? pageSize;

  /// Initial value used by a single-selection helper.
  final T? initialValue;

  /// Initial values used by a multi-selection helper.
  final Iterable<T>? initialSelection;

  /// Search-input hint text.
  final String? hintText;

  /// Sheet title.
  final String? title;
}

/// A request passed to a remote [SelectionSheetPageLoader].
@immutable
class SelectionSheetLoadRequest {
  /// Creates a page request.
  const SelectionSheetLoadRequest({
    required this.query,
    required this.page,
    required this.pageSize,
    required this.cancellationToken,
    this.cursor,
  });

  /// Current debounced search text.
  final String query;

  /// One-based page number.
  ///
  /// Page-based repositories can use this directly. Cursor-based repositories
  /// can ignore it and use [cursor].
  final int page;

  /// Requested page size.
  final int pageSize;

  /// Cursor returned by the previous page, or `null` for the first page.
  final Object? cursor;

  /// Cooperative cancellation token for this request.
  ///
  /// Repositories can stop HTTP clients, database work, or other expensive
  /// operations when the sheet starts a newer search, refreshes, or closes.
  final SelectionSheetCancellationToken cancellationToken;
}

/// Cooperative cancellation signal for one async page request.
class SelectionSheetCancellationToken {
  final Set<VoidCallback> _listeners = {};
  bool _isCancelled = false;

  /// Whether the request has been superseded or the sheet has closed.
  bool get isCancelled => _isCancelled;

  /// Registers [listener] and returns a function that unregisters it.
  ///
  /// If cancellation already happened, [listener] is invoked immediately.
  VoidCallback onCancel(VoidCallback listener) {
    if (_isCancelled) {
      listener();
      return () {};
    }
    _listeners.add(listener);
    return () => _listeners.remove(listener);
  }

  /// Throws [SelectionSheetRequestCancelled] when cancelled.
  void throwIfCancelled() {
    if (_isCancelled) throw const SelectionSheetRequestCancelled();
  }

  /// Signals cancellation.
  ///
  /// This is invoked by the sheet. It remains public so custom data-source
  /// orchestration can forward cancellation between operations.
  void cancel() {
    if (_isCancelled) return;
    _isCancelled = true;
    final listeners = List<VoidCallback>.of(_listeners);
    _listeners.clear();
    for (final listener in listeners) {
      listener();
    }
  }
}

/// Thrown by [SelectionSheetCancellationToken.throwIfCancelled].
class SelectionSheetRequestCancelled implements Exception {
  /// Creates a cancellation exception.
  const SelectionSheetRequestCancelled();

  @override
  String toString() => 'Selection sheet request cancelled';
}

/// State and actions supplied to a custom search-field builder.
@immutable
class SelectionSheetSearchFieldData {
  /// Creates search-field data.
  const SelectionSheetSearchFieldData({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  /// Controller owned and disposed by the selection view.
  final TextEditingController controller;

  /// Focus node owned and disposed by the selection view.
  final FocusNode focusNode;

  /// Resolved local or global hint text.
  final String hintText;

  /// Current debounced query.
  final String query;

  /// Must be called when the custom input text changes.
  final ValueChanged<String> onChanged;

  /// Clears the controller and immediately applies an empty query.
  final VoidCallback onClear;
}

/// One page returned by a remote selection loader.
@immutable
class SelectionSheetPage<T> {
  /// Creates a page of items.
  const SelectionSheetPage({
    required this.items,
    this.hasMore = false,
    this.nextCursor,
  });

  /// Items in this page.
  final List<T> items;

  /// Whether another page can be requested.
  final bool hasMore;

  /// Cursor to send with the next request.
  ///
  /// Leave this `null` for page-number pagination.
  final Object? nextCursor;
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

  /// The current debounced search query.
  final String query;
}

/// Information supplied to a section header builder.
@immutable
class SelectionSheetSectionData {
  /// Creates section presentation data.
  const SelectionSheetSectionData({
    required this.key,
    required this.label,
    required this.itemCount,
  });

  /// Original key returned by the section resolver.
  final Object? key;

  /// Display label for the key.
  final String label;

  /// Number of visible items in the section.
  final int itemCount;
}

/// Type-erased item information supplied to a global theme builder.
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

  /// The current debounced search query.
  final String query;

  /// The package's default adaptive row.
  final Widget defaultChild;
}

/// Builds item rows for all selection sheets below a theme.
typedef SelectionSheetGlobalItemBuilder = Widget Function(
    BuildContext context, SelectionSheetItemData item);
