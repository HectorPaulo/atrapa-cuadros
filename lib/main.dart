import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
    await GoogleSignIn.instance.initialize(
      serverClientId: '669468783122-v7d5ue94b1mqe74tvlmt7arlhtv115q6.apps.googleusercontent.com',
    );
    debugPrint('main: GoogleSignIn inicializado correctamente');
  } catch (e) {
    debugPrint('main: error al inicializar GoogleSignIn: $e');
  }
  runApp(const App());
}
