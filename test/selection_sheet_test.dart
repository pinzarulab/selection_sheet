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
    await tester.pump();

    expect(find.text('Ukraine'), findsOneWidget);
    expect(find.text('France'), findsNothing);

    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pump();

    expect(find.text('No items found'), findsOneWidget);
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
