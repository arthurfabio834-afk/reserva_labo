import 'package:flutter_test/flutter_test.dart';
import 'package:reserva_labo/main.dart';

void main() {
  testWidgets('Carrega tela de login', (WidgetTester tester) async {
    await tester.pumpWidget(const ReservaLaboApp());
    await tester.pumpAndSettle();

    expect(find.text('Laboratórios IFPA'), findsOneWidget);
  });
}