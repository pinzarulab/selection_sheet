import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'selection_sheet_theme.dart';
import 'selection_sheet_types.dart';
import 'selection_sheet_view.dart';

/// Presents adaptive selection workflows as modal sheets.
abstract final class SelectionSheet {
  /// Shows a searchable single-selection sheet.
  ///
  /// Returns the selected item, or `null` when the sheet is dismissed.
  static Future<T?> showSingle<T>({
    required BuildContext context,
    required List<T> items,
    required SelectionItemLabelBuilder<T> itemLabelBuilder,
    String? title,
    T? initialValue,
    bool searchable = false,
    String? searchHintText,
    SelectionSheetItemBuilder<T>? itemBuilder,
    bool Function(T item)? isItemEnabled,
    SelectionItemEquality<T>? itemEquals,
    SelectionSheetThemeData? theme,
    SelectionSheetPresentation presentation =
        SelectionSheetPresentation.adaptive,
    bool useRootNavigator = false,
    bool isDismissible = true,
  }) {
    final resolvedTheme = theme ?? SelectionSheetTheme.of(context);
    return _show<T>(
      context: context,
      presentation: presentation,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      theme: resolvedTheme,
      builder: (sheetContext, scrollController) {
        return SelectionSheetView<T>.single(
          items: items,
          itemLabelBuilder: itemLabelBuilder,
          title: title,
          initialValue: initialValue,
          searchable: searchable,
          searchHintText: searchHintText,
          itemBuilder: itemBuilder,
          isItemEnabled: isItemEnabled,
          itemEquals: itemEquals,
          theme: resolvedTheme,
          scrollController: scrollController,
        );
      },
    );
  }

  /// Shows a searchable multi-selection sheet.
  ///
  /// Changes are kept as a draft until the confirmation action is pressed.
  /// Returns the confirmed selection, or `null` when dismissed.
  static Future<List<T>?> showMulti<T>({
    required BuildContext context,
    required List<T> items,
    required SelectionItemLabelBuilder<T> itemLabelBuilder,
    String? title,
    Iterable<T> initialSelection = const [],
    bool searchable = false,
    String? searchHintText,
    String? doneLabel,
    SelectionSheetItemBuilder<T>? itemBuilder,
    bool Function(T item)? isItemEnabled,
    SelectionItemEquality<T>? itemEquals,
    SelectionSheetThemeData? theme,
    SelectionSheetPresentation presentation =
        SelectionSheetPresentation.adaptive,
    bool useRootNavigator = false,
    bool isDismissible = true,
  }) {
    final resolvedTheme = theme ?? SelectionSheetTheme.of(context);
    return _show<List<T>>(
      context: context,
      presentation: presentation,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      theme: resolvedTheme,
      builder: (sheetContext, scrollController) {
        return SelectionSheetView<T>.multi(
          items: items,
          itemLabelBuilder: itemLabelBuilder,
          title: title,
          initialSelection: initialSelection,
          searchable: searchable,
          searchHintText: searchHintText,
          doneLabel: doneLabel,
          itemBuilder: itemBuilder,
          isItemEnabled: isItemEnabled,
          itemEquals: itemEquals,
          theme: resolvedTheme,
          scrollController: scrollController,
        );
      },
    );
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
}
