import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoboulma_app/app.dart';

import 'package:yoboulma_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const YoboulmaApp());

    // Attendre que l'application s'initialise
    await tester.pumpAndSettle();

    // Vérifiez que votre application se charge correctement
    // Remplacez ces vérifications par les éléments réels de votre YoboulmaApp
    
    // Exemple 1: Vérifier qu'un Scaffold est présent
    expect(find.byType(Scaffold), findsWidgets);
    
    // Exemple 2: Si votre app a un AppBar avec un titre spécifique
    // expect(find.text('Titre de votre app'), findsOneWidget);
    
    // Exemple 3: Si vous avez un compteur dans votre app
    // expect(find.text('0'), findsOneWidget);
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();
    // expect(find.text('1'), findsOneWidget);
  });

  // Vous pouvez ajouter d'autres tests
  testWidgets('App loads without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const YoboulmaApp());
    await tester.pumpAndSettle();
    
    // Vérifiez que MaterialApp est présent
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Vérifiez qu'il n'y a pas d'erreurs de rendu
    // (pas d'exceptions pendant le build)
  });
}