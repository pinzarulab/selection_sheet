import 'package:flutter/material.dart';

import 'selection_sheet.dart';
import 'selection_sheet_theme.dart';
import 'selection_sheet_types.dart';
import 'selection_sheet_view.dart';

/// Builds the value displayed by a single-selection form field.
typedef SelectionSheetFieldValueBuilder<T> = Widget Function(
    BuildContext context, T? value);

/// Builds the value displayed by a multi-selection form field.
typedef SelectionSheetMultiFieldValueBuilder<T> = Widget Function(
    BuildContext context, List<T> value);

/// A native Flutter [FormField] that opens a single-selection sheet.
///
/// This widget depends only on Flutter's form APIs.
class SelectionSheetFormField<T> extends FormField<T> {
  /// Creates a single-selection form field.
  SelectionSheetFormField({
    required SelectionItemLabelBuilder<T> itemLabelBuilder,
    List<T>? items,
    SelectionSheetPageLoader<T>? loadItems,
    int pageSize = 20,
    String? title,
    bool searchable = false,
    String? searchHintText,
    Duration? searchDebounceDuration,
    SelectionSheetSearchFieldBuilder? searchFieldBuilder,
    SelectionSheetItemBuilder<T>? itemBuilder,
    SelectionItemEquality<T>? itemEquals,
    SelectionItemKeyBuilder<T>? itemKeyBuilder,
    SelectionSheetSectionBuilder<T>? sectionBuilder,
    SelectionSheetSectionHeaderBuilder? sectionHeaderBuilder,
    SelectionSheetLayout? layout,
    SliverGridDelegate? gridDelegate,
    SelectionSheetController? controller,
    bool enablePullToRefresh = true,
    SelectionSheetThemeData? sheetTheme,
    InputDecoration decoration = const InputDecoration(),
    String? hintText,
    SelectionSheetFieldValueBuilder<T>? fieldBuilder,
    bool allowClear = true,
    super.enabled = true,
    ValueChanged<T?>? onChanged,
    super.key,
    super.initialValue,
    super.validator,
    super.onSaved,
    super.autovalidateMode,
    super.restorationId,
  })  : assert((items == null) != (loadItems == null)),
        super(
          builder: (field) {
            Future<void> openSheet() async {
              final result = await SelectionSheet.showSingle<T>(
                context: field.context,
                items: items,
                loadItems: loadItems,
                pageSize: pageSize,
                title: title,
                initialValue: field.value,
                searchable: searchable,
                searchHintText: searchHintText,
                searchDebounceDuration: searchDebounceDuration,
                searchFieldBuilder: searchFieldBuilder,
                itemLabelBuilder: itemLabelBuilder,
                itemBuilder: itemBuilder,
                itemEquals: itemEquals,
                itemKeyBuilder: itemKeyBuilder,
                sectionBuilder: sectionBuilder,
                sectionHeaderBuilder: sectionHeaderBuilder,
                layout: layout,
                gridDelegate: gridDelegate,
                controller: controller,
                enablePullToRefresh: enablePullToRefresh,
                theme: sheetTheme,
              );
              if (result == null || !field.mounted) return;
              field.didChange(result);
              onChanged?.call(result);
            }

            void clear() {
              field.didChange(null);
              onChanged?.call(null);
            }

            return _SelectionSheetFieldSurface(
              decoration: decoration.copyWith(errorText: field.errorText),
              enabled: field.widget.enabled,
              isEmpty: field.value == null,
              allowClear: allowClear,
              onTap: openSheet,
              onClear: clear,
              child: fieldBuilder?.call(field.context, field.value) ??
                  (field.value == null
                      ? hintText == null
                          ? const SizedBox.shrink()
                          : Text(
                              hintText,
                              style: Theme.of(field.context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(field.context).hintColor,
                                  ),
                            )
                      : Text(itemLabelBuilder(field.value as T))),
            );
          },
        );
}

/// A native Flutter [FormField] that opens a multi-selection sheet.
class SelectionSheetMultiFormField<T> extends FormField<List<T>> {
  /// Creates a multi-selection form field.
  SelectionSheetMultiFormField({
    required SelectionItemLabelBuilder<T> itemLabelBuilder,
    List<T>? items,
    SelectionSheetPageLoader<T>? loadItems,
    int pageSize = 20,
    String? title,
    bool searchable = false,
    String? searchHintText,
    Duration? searchDebounceDuration,
    SelectionSheetSearchFieldBuilder? searchFieldBuilder,
    String? doneLabel,
    SelectionSheetItemBuilder<T>? itemBuilder,
    SelectionItemEquality<T>? itemEquals,
    SelectionItemKeyBuilder<T>? itemKeyBuilder,
    SelectionSheetSectionBuilder<T>? sectionBuilder,
    SelectionSheetSectionHeaderBuilder? sectionHeaderBuilder,
    SelectionSheetLayout? layout,
    SliverGridDelegate? gridDelegate,
    bool? showSelectedChips,
    SelectionSheetSelectedChipBuilder<T>? selectedChipBuilder,
    SelectionSheetController? controller,
    bool enablePullToRefresh = true,
    SelectionSheetThemeData? sheetTheme,
    InputDecoration decoration = const InputDecoration(),
    String? hintText,
    SelectionSheetMultiFieldValueBuilder<T>? fieldBuilder,
    bool allowClear = true,
    super.enabled = true,
    ValueChanged<List<T>>? onChanged,
    super.key,
    List<T> initialValue = const [],
    super.validator,
    super.onSaved,
    super.autovalidateMode,
    super.restorationId,
  })  : assert((items == null) != (loadItems == null)),
        super(
          initialValue: initialValue,
          builder: (field) {
            final value = field.value ?? const [];

            Future<void> openSheet() async {
              final result = await SelectionSheet.showMulti<T>(
                context: field.context,
                items: items,
                loadItems: loadItems,
                pageSize: pageSize,
                title: title,
                initialSelection: value,
                searchable: searchable,
                searchHintText: searchHintText,
                searchDebounceDuration: searchDebounceDuration,
                searchFieldBuilder: searchFieldBuilder,
                doneLabel: doneLabel,
                itemLabelBuilder: itemLabelBuilder,
                itemBuilder: itemBuilder,
                itemEquals: itemEquals,
                itemKeyBuilder: itemKeyBuilder,
                sectionBuilder: sectionBuilder,
                sectionHeaderBuilder: sectionHeaderBuilder,
                layout: layout,
                gridDelegate: gridDelegate,
                showSelectedChips: showSelectedChips,
                selectedChipBuilder: selectedChipBuilder,
                controller: controller,
                enablePullToRefresh: enablePullToRefresh,
                theme: sheetTheme,
              );
              if (result == null || !field.mounted) return;
              field.didChange(result);
              onChanged?.call(result);
            }

            void clear() {
              const empty = <Never>[];
              final result = List<T>.of(empty);
              field.didChange(result);
              onChanged?.call(result);
            }

            return _SelectionSheetFieldSurface(
              decoration: decoration.copyWith(errorText: field.errorText),
              enabled: field.widget.enabled,
              isEmpty: value.isEmpty,
              allowClear: allowClear,
              onTap: openSheet,
              onClear: clear,
              child: fieldBuilder?.call(field.context, value) ??
                  (value.isEmpty
                      ? hintText == null
                          ? const SizedBox.shrink()
                          : Text(
                              hintText,
                              style: Theme.of(field.context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(field.context).hintColor,
                                  ),
                            )
                      : Text(
                          value.map(itemLabelBuilder).join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
            );
          },
        );
}

class _SelectionSheetFieldSurface extends StatelessWidget {
  const _SelectionSheetFieldSurface({
    required this.decoration,
    required this.enabled,
    required this.isEmpty,
    required this.allowClear,
    required this.onTap,
    required this.onClear,
    required this.child,
  });

  final InputDecoration decoration;
  final bool enabled;
  final bool isEmpty;
  final bool allowClear;
  final VoidCallback onTap;
  final VoidCallback onClear;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        isEmpty: isEmpty,
        decoration: decoration.copyWith(enabled: enabled),
        child: Row(
          children: [
            Expanded(child: child),
            if (enabled && allowClear && !isEmpty)
              IconButton(
                tooltip: 'Clear selection',
                visualDensity: VisualDensity.compact,
                onPressed: onClear,
                icon: const Icon(Icons.clear),
              )
            else
              const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
