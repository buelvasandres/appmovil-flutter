import 'package:flutter_test/flutter_test.dart';

import 'package:catalogo_express/main.dart';

void main() {
  testWidgets('La app abre en la pantalla de inicio de sesión', (tester) async {
    await tester.pumpWidget(const CatalogoExpressApp());
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
  });
}
