import 'package:flutter_test/flutter_test.dart';
import 'package:selection_sheet_example/main.dart';

void main() {
  testWidgets('shows the country selection example', (tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('Selection Sheet'), findsOneWidget);
    expect(find.text('Choose a country'), findsOneWidget);
  });
}
