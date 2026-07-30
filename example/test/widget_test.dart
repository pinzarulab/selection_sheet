import 'package:flutter_test/flutter_test.dart';
import 'package:selection_sheet/selection_sheet.dart';
import 'package:selection_sheet_example/main.dart';

void main() {
  testWidgets('shows the country selection example', (tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('Selection Sheet'), findsOneWidget);
    expect(find.text('Select an item'), findsNothing);
    expect(find.text('Country'), findsOneWidget);
    expect(find.byType(SelectionSheetFormField<Country>), findsOneWidget);
  });
}
