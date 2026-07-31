import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:selection_sheet/selection_sheet.dart';
import 'package:selection_sheet_example/main.dart';

void main() {
  testWidgets('shows the 0.5.1 country selection showcase', (tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('selection_sheet'), findsOneWidget);
    expect(find.text('v0.5.1'), findsOneWidget);
    expect(find.text('Native form field'), findsOneWidget);
    expect(find.text('Modal workflows'), findsOneWidget);
    expect(find.byType(SelectionSheetFormField<Country>), findsOneWidget);

    await tester.tap(find.text('Embedded'));
    await tester.pumpAndSettle();

    expect(find.byType(SelectionSheetView<Country>), findsOneWidget);
    expect(find.text('New in 0.5.0'), findsOneWidget);

    await tester.drag(
      find.byType(CustomScrollView),
      const Offset(0, -5000),
    );
    await tester.pumpAndSettle();

    expect(find.text('Papua New Guinea').hitTestable(), findsOneWidget);
    expect(find.text('Oceania').hitTestable(), findsOneWidget);
    expect(find.text('Americas').hitTestable(), findsNothing);
    expect(find.text('Europe').hitTestable(), findsNothing);
    expect(find.text('Asia').hitTestable(), findsNothing);
    expect(find.text('Africa').hitTestable(), findsNothing);
  });
}
