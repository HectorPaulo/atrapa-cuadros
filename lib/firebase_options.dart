// Archivo generado automaticamente por 'flutterfire configure'.
// Reemplaza este contenido ejecutando:
//   dart run flutterfire configure
//
// Este es un placeholder. Despues de ejecutar flutterfire configure,
// este archivo sera sobrescrito con la configuracion real de tu proyecto Firebase.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions no estan configurados para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCjPhvcD5rwKQife_ZS8ZYYNH0GZS0Wm2k',
    appId: '1:669468783122:web:7162b4ad54582e05249ecb',
    messagingSenderId: '669468783122',
    projectId: 'atrapa-cuadro',
    authDomain: 'atrapa-cuadro.firebaseapp.com',
    storageBucket: 'atrapa-cuadro.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDgip8Lg0AQUeRKmbN3XkEVpJB8Zvjx1XU',
    appId: '1:669468783122:android:febaa33c7363e570249ecb',
    messagingSenderId: '669468783122',
    projectId: 'atrapa-cuadro',
    storageBucket: 'atrapa-cuadro.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCObFpbm1h-UBtsA7LxlzDmGrG3Y2ATWnE',
    appId: '1:669468783122:ios:4177e2c32dece7e8249ecb',
    messagingSenderId: '669468783122',
    projectId: 'atrapa-cuadro',
    storageBucket: 'atrapa-cuadro.firebasestorage.app',
    androidClientId: '669468783122-a9fv9odvoesncn95fe5j71d9me0r85hh.apps.googleusercontent.com',
    iosClientId: '669468783122-0u39p7maj1qho23pjm0qnt71iet93r0v.apps.googleusercontent.com',
    iosBundleId: 'com.example.examen',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCObFpbm1h-UBtsA7LxlzDmGrG3Y2ATWnE',
    appId: '1:669468783122:ios:4177e2c32dece7e8249ecb',
    messagingSenderId: '669468783122',
    projectId: 'atrapa-cuadro',
    storageBucket: 'atrapa-cuadro.firebasestorage.app',
    androidClientId: '669468783122-a9fv9odvoesncn95fe5j71d9me0r85hh.apps.googleusercontent.com',
    iosClientId: '669468783122-0u39p7maj1qho23pjm0qnt71iet93r0v.apps.googleusercontent.com',
    iosBundleId: 'com.example.examen',
  );
}