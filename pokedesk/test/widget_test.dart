import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:pokeflutter/router/app_router.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: appRouter),
    );
    await tester.pump();

    expect(find.text('PokéFlutter'), findsOneWidget);

    // Espera a que SharedPreferences.getInstance() complete y navegue
    await tester.pumpAndSettle();
  });
}
