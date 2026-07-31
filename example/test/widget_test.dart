import 'package:flutter_test/flutter_test.dart';
import 'package:selection_sheet/selection_sheet.dart';
import 'package:selection_sheet_example/main.dart';

void main() {
  testWidgets('shows the 0.5.0 country selection showcase', (tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('selection_sheet'), findsOneWidget);
    expect(find.text('v0.5.0'), findsOneWidget);
    expect(find.text('Native form field'), findsOneWidget);
    expect(find.text('Modal workflows'), findsOneWidget);
    expect(find.byType(SelectionSheetFormField<Country>), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Embedded SelectionSheetView'),
      300,
    );
    expect(find.byType(SelectionSheetView<Country>), findsOneWidget);
    expect(find.text('New in 0.5.0'), findsOneWidget);
  });
}
