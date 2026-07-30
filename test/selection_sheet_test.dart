import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:selection_sheet/selection_sheet.dart';

void main() {
  testWidgets('single selection returns the tapped item', (tester) async {
    String? result;
    await tester.pumpWidget(
      _TestApp(
        onPressed: (context) async {
          result = await SelectionSheet.showSingle<String>(
            context: context,
            items: const ['France', 'Germany', 'Ukraine'],
            itemLabelBuilder: (item) => item,
            title: 'Country',
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Germany'));
    await tester.pumpAndSettle();

    expect(result, 'Germany');
  });

  testWidgets('search filters items and shows the empty state', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        onPressed: (context) {
          SelectionSheet.showSingle<String>(
            context: context,
            items: const ['France', 'Germany', 'Ukraine'],
            itemLabelBuilder: (item) => item,
            searchable: true,
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ukr');
    await tester.pump(const Duration(milliseconds: 299));

    expect(find.text('France'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1));

    expect(find.text('Ukraine'), findsOneWidget);
    expect(find.text('France'), findsNothing);

    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('No items found'), findsOneWidget);
  });

  testWidgets('per-sheet debounce overrides the global duration', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        theme: const SelectionSheetThemeData(
          searchDebounceDuration: Duration(seconds: 1),
        ),
        onPressed: (context) {
          SelectionSheet.showSingle<String>(
            context: context,
            items: const ['France', 'Ukraine'],
            itemLabelBuilder: (item) => item,
            searchable: true,
            searchDebounceDuration: const Duration(milliseconds: 50),
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ukr');
    await tester.pump(const Duration(milliseconds: 49));

    expect(find.text('France'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1));

    expect(find.text('France'), findsNothing);
    expect(find.text('Ukraine'), findsOneWidget);
  });

  testWidgets('multi selection commits only when Done is pressed', (
    tester,
  ) async {
    List<String>? result;
    await tester.pumpWidget(
      _TestApp(
        onPressed: (context) async {
          result = await SelectionSheet.showMulti<String>(
            context: context,
            items: const ['France', 'Germany', 'Ukraine'],
            itemLabelBuilder: (item) => item,
            initialSelection: const ['France'],
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Germany'));
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(result, ['France', 'Germany']);
  });

  testWidgets('per-sheet item builder overrides the global builder', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        theme: SelectionSheetThemeData(
          itemBuilder: (context, item) => Text('Global ${item.label}'),
        ),
        onPressed: (context) {
          SelectionSheet.showSingle<String>(
            context: context,
            items: const ['France'],
            itemLabelBuilder: (item) => item,
            itemBuilder: (context, item, state) => Text('Local $item'),
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Local France'), findsOneWidget);
    expect(find.text('Global France'), findsNothing);
  });

  testWidgets('disabled items cannot be selected', (tester) async {
    String? result;
    await tester.pumpWidget(
      _TestApp(
        onPressed: (context) async {
          result = await SelectionSheet.showSingle<String>(
            context: context,
            items: const ['Disabled'],
            itemLabelBuilder: (item) => item,
            isItemEnabled: (item) => false,
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Disabled'));
    await tester.pump();

    expect(result, isNull);
    expect(find.text('Disabled'), findsOneWidget);
  });

  testWidgets('remote search ignores stale responses', (tester) async {
    final requests = <SelectionSheetLoadRequest>[];
    final responses = <String, Completer<SelectionSheetPage<String>>>{};

    await tester.pumpWidget(
      _TestApp(
        onPressed: (context) {
          SelectionSheet.showSingle<String>(
            context: context,
            loadItems: (request) {
              requests.add(request);
              final response = Completer<SelectionSheetPage<String>>();
              responses[request.query] = response;
              return response.future;
            },
            itemLabelBuilder: (item) => item,
            searchable: true,
            searchDebounceDuration: Duration.zero,
            loadingBuilder: (context) => const Text('Loading results'),
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    expect(requests.single.query, '');
    responses['']!.complete(
      const SelectionSheetPage(items: ['Initial']),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'first');
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'second');
    await tester.pump();

    responses['second']!.complete(
      const SelectionSheetPage(items: ['Second result']),
    );
    await tester.pump();
    responses['first']!.complete(
      const SelectionSheetPage(items: ['Stale first result']),
    );
    await tester.pump();

    expect(find.text('Second result'), findsOneWidget);
    expect(find.text('Stale first result'), findsNothing);
    expect(
      requests.map((request) => request.query),
      ['', 'first', 'second'],
    );
  });

  testWidgets('superseded requests signal cooperative cancellation', (
    tester,
  ) async {
    final responses = <String, Completer<SelectionSheetPage<String>>>{};
    final cancelledQueries = <String>[];

    await tester.pumpWidget(
      _TestApp(
        onPressed: (context) {
          SelectionSheet.showSingle<String>(
            context: context,
            loadItems: (request) {
              request.cancellationToken.onCancel(
                () => cancelledQueries.add(request.query),
              );
              final response = Completer<SelectionSheetPage<String>>();
              responses[request.query] = response;
              return response.future;
            },
            itemLabelBuilder: (item) => item,
            searchable: true,
            searchDebounceDuration: Duration.zero,
            loadingBuilder: (context) => const Text('Loading'),
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'new query');
    await tester.pump();

    expect(cancelledQueries, ['']);
    expect(responses[''] != null, isTrue);
    expect(responses['new query'] != null, isTrue);

    responses['new query']!.complete(
      const SelectionSheetPage(items: ['Fresh result']),
    );
    await tester.pumpAndSettle();
    expect(find.text('Fresh result'), findsOneWidget);
  });

  testWidgets('closing the sheet cancels an active request', (tester) async {
    SelectionSheetCancellationToken? activeToken;
    var cancellationCalls = 0;
    final response = Completer<SelectionSheetPage<String>>();

    await tester.pumpWidget(
      _TestApp(
        onPressed: (context) {
          SelectionSheet.showSingle<String>(
            context: context,
            loadItems: (request) {
              activeToken = request.cancellationToken;
              request.cancellationToken.onCancel(() => cancellationCalls++);
              return response.future;
            },
            itemLabelBuilder: (item) => item,
            loadingBuilder: (context) => const Text('Loading'),
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(activeToken?.isCancelled, isFalse);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(activeToken?.isCancelled, isTrue);
    expect(cancellationCalls, 1);
  });

  testWidgets('controller refresh resets page one and preserves the query', (
    tester,
  ) async {
    final controller = SelectionSheetController();
    final requests = <SelectionSheetLoadRequest>[];

    await tester.pumpWidget(
      _TestApp(
        onPressed: (context) {
          SelectionSheet.showSingle<String>(
            context: context,
            controller: controller,
            loadItems: (request) async {
              requests.add(request);
              return SelectionSheetPage(
                items: ['Result ${requests.length}'],
              );
            },
            itemLabelBuilder: (item) => item,
            searchable: true,
            searchDebounceDuration: Duration.zero,
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(controller.isAttached, isTrue);
    expect(find.byType(RefreshIndicator), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'team');
    await tester.pumpAndSettle();
    await controller.refresh();
    await tester.pumpAndSettle();

    expect(requests, hasLength(3));
    expect(requests.last.query, 'team');
    expect(requests.last.page, 1);
    expect(requests.last.cursor, isNull);
    expect(find.text('Result 3'), findsOneWidget);

    await tester.tap(find.text('Result 3'));
    await tester.pumpAndSettle();
    expect(controller.isAttached, isFalse);
  });

  testWidgets('pagination forwards page number, page size, and cursor', (
    tester,
  ) async {
    final requests = <SelectionSheetLoadRequest>[];

    await tester.pumpWidget(
      _TestApp(
        onPressed: (context) {
          SelectionSheet.showSingle<String>(
            context: context,
            loadItems: (request) async {
              requests.add(request);
              if (request.page == 1) {
                return const SelectionSheetPage(
                  items: ['First page'],
                  hasMore: true,
                  nextCursor: 'cursor-2',
                );
              }
              return const SelectionSheetPage(items: ['Second page']);
            },
            pageSize: 25,
            itemLabelBuilder: (item) => item,
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(requests, hasLength(2));
    expect(requests[0].page, 1);
    expect(requests[0].cursor, isNull);
    expect(requests[1].page, 2);
    expect(requests[1].pageSize, 25);
    expect(requests[1].cursor, 'cursor-2');
    expect(find.text('First page'), findsOneWidget);
    expect(find.text('Second page'), findsOneWidget);
  });

  testWidgets('sections use sticky custom headers', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        onPressed: (context) {
          SelectionSheet.showSingle<String>(
            context: context,
            items: const ['A-one', 'A-two', 'B-one'],
            itemLabelBuilder: (item) => item,
            sectionBuilder: (item) => item.substring(0, 1),
            sectionHeaderBuilder: (context, section) {
              return Text('${section.label}: ${section.itemCount}');
            },
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('A: 2'), findsOneWidget);
    expect(find.text('B: 1'), findsOneWidget);
    final headers = tester.widgetList<SliverPersistentHeader>(
      find.byType(SliverPersistentHeader),
    );
    expect(headers, hasLength(2));
    expect(headers.every((header) => header.pinned), isTrue);
  });

  testWidgets('grid presentation can be configured globally', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        theme: const SelectionSheetThemeData(
          layout: SelectionSheetLayout.grid,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
          ),
        ),
        onPressed: (context) {
          SelectionSheet.showSingle<String>(
            context: context,
            items: const ['One', 'Two', 'Three'],
            itemLabelBuilder: (item) => item,
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(SliverGrid), findsOneWidget);
    expect(find.text('One'), findsOneWidget);
    expect(find.text('Three'), findsOneWidget);
  });

  testWidgets('selected item chips can be customized and remove selections', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        onPressed: (context) {
          SelectionSheet.showMulti<String>(
            context: context,
            items: const ['France', 'Germany'],
            initialSelection: const ['France'],
            itemLabelBuilder: (item) => item,
            selectedChipBuilder: (context, item, label, onDeleted) {
              return ActionChip(
                label: Text('Selected $label'),
                onPressed: onDeleted,
              );
            },
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Selected France'), findsOneWidget);

    await tester.tap(find.text('Selected France'));
    await tester.pump();

    expect(find.text('Selected France'), findsNothing);
    expect(find.text('France'), findsOneWidget);
  });

  testWidgets('custom loading and error states can retry', (tester) async {
    final firstResponse = Completer<SelectionSheetPage<String>>();
    var attempts = 0;

    await tester.pumpWidget(
      _TestApp(
        onPressed: (context) {
          SelectionSheet.showSingle<String>(
            context: context,
            loadItems: (request) {
              attempts++;
              if (attempts == 1) return firstResponse.future;
              return Future.value(
                const SelectionSheetPage(items: ['Recovered']),
              );
            },
            itemLabelBuilder: (item) => item,
            loadingBuilder: (context) => const Text('Custom loading'),
            errorBuilder: (context, error, retry) {
              return TextButton(
                onPressed: retry,
                child: const Text('Custom retry'),
              );
            },
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Custom loading'), findsOneWidget);

    firstResponse.completeError(StateError('network failed'));
    await tester.pumpAndSettle();
    expect(find.text('Custom retry'), findsOneWidget);

    await tester.tap(find.text('Custom retry'));
    await tester.pumpAndSettle();

    expect(attempts, 2);
    expect(find.text('Recovered'), findsOneWidget);
  });

  testWidgets('custom empty state receives the debounced query', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        onPressed: (context) {
          SelectionSheet.showSingle<String>(
            context: context,
            loadItems: (request) async {
              return const SelectionSheetPage(items: []);
            },
            itemLabelBuilder: (item) => item,
            searchable: true,
            searchDebounceDuration: Duration.zero,
            emptyBuilder: (context, query) => Text('Empty: $query'),
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Ukraine');
    await tester.pumpAndSettle();

    expect(find.text('Empty: Ukraine'), findsOneWidget);
  });

  testWidgets('pagination errors expose a custom retry builder', (
    tester,
  ) async {
    var secondPageAttempts = 0;

    await tester.pumpWidget(
      _TestApp(
        onPressed: (context) {
          SelectionSheet.showSingle<String>(
            context: context,
            loadItems: (request) async {
              if (request.page == 1) {
                return const SelectionSheetPage(
                  items: ['First page'],
                  hasMore: true,
                );
              }
              secondPageAttempts++;
              if (secondPageAttempts == 1) {
                throw StateError('page failed');
              }
              return const SelectionSheetPage(items: ['Recovered page']);
            },
            itemLabelBuilder: (item) => item,
            loadMoreErrorBuilder: (context, error, retry) {
              return TextButton(
                onPressed: retry,
                child: const Text('Retry page'),
              );
            },
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Retry page'), findsOneWidget);

    await tester.tap(find.text('Retry page'));
    await tester.pumpAndSettle();

    expect(secondPageAttempts, 2);
    expect(find.text('Recovered page'), findsOneWidget);
  });

  testWidgets('single form field validates and updates its value', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    String? changedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: Column(
              children: [
                SelectionSheetFormField<String>(
                  items: const ['France', 'Germany'],
                  itemLabelBuilder: (item) => item,
                  hintText: 'Select an item',
                  validator: (value) =>
                      value == null ? 'Country is required' : null,
                  onChanged: (value) => changedValue = value,
                ),
                FilledButton(
                  onPressed: () => formKey.currentState!.validate(),
                  child: const Text('Validate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Validate'));
    await tester.pump();
    expect(find.text('Country is required'), findsOneWidget);

    await tester.tap(find.text('Select an item'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Germany'));
    await tester.pumpAndSettle();

    expect(changedValue, 'Germany');
    expect(find.text('Germany'), findsOneWidget);
    expect(formKey.currentState!.validate(), isTrue);
  });

  testWidgets('multi form field commits selected values', (tester) async {
    List<String>? changedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SelectionSheetMultiFormField<String>(
            items: const ['France', 'Germany'],
            initialValue: const ['France'],
            itemLabelBuilder: (item) => item,
            onChanged: (value) => changedValue = value,
          ),
        ),
      ),
    );

    await tester.tap(find.text('France'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Germany'));
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(changedValue, ['France', 'Germany']);
    expect(find.text('France, Germany'), findsOneWidget);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.onPressed, this.theme});

  final void Function(BuildContext context) onPressed;
  final SelectionSheetThemeData? theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(platform: TargetPlatform.android),
      builder: (context, child) {
        return SelectionSheetTheme(
          data: theme ?? SelectionSheetThemeData.fallback(context),
          child: child!,
        );
      },
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: FilledButton(
                onPressed: () => onPressed(context),
                child: const Text('Open'),
              ),
            );
          },
        ),
      ),
    );
  }
}
