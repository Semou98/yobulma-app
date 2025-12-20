import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase avec les options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialisé avec succès');
  } catch (e) {
    // Si Firebase n'est pas configuré, on continue quand même
    debugPrint('⚠️ Erreur Firebase: $e');
    debugPrint('💡 Application en mode hors ligne');
  }
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState()..initialize(),
      child: const YoboulmaApp(),
    ),
  );
}