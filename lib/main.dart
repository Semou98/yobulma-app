import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase avec les options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialisé avec succès');
  } catch (e) {
    // Si Firebase n'est pas configuré, on continue quand même
    // pour permettre le développement de l'UI
    debugPrint('⚠️ Erreur Firebase: $e');
    debugPrint('💡 Note: Exécutez "flutterfire configure" pour configurer Firebase correctement');
    debugPrint('   L\'application continuera à fonctionner mais Firebase ne sera pas disponible');
  }
  
  runApp(const YoboulmaApp());
}
