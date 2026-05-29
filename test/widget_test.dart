import 'package:flutter_test/flutter_test.dart';
import 'package:examen/app.dart';

void main() {
  testWidgets('App se inicia correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.byType(App), findsOneWidget);
  });
}
