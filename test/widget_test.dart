import 'package:flutter_test/flutter_test.dart';
import 'package:link_manager/main.dart';

void main() {
  testWidgets('App shows title', (WidgetTester tester) async {
    await tester.pumpWidget(const LinkManagerApp());
    expect(find.text('Gerenciador de Links'), findsOneWidget);
  });
}
