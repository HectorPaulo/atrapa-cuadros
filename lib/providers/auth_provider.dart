import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class AuthAppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  Usuario? _usuario;
  bool _cargando = false;
  String? _error;

  Completer<void>? _completerCarga;

  Usuario? get usuario => _usuario;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get estaAutenticado => _usuario != null;

  AuthAppProvider() {
    _authService.usuarioStream.listen((User? user) async {
      try {
        if (user != null) {
          _cargando = true;
          notifyListeners();
          final u = await _firestoreService.obtenerUsuario(user.uid);
          if (u != null) {
            _usuario = u;
          } else {
            _usuario = Usuario(uid: user.uid, email: user.email ?? '');
            await _firestoreService.guardarUsuario(_usuario!);
          }
        } else {
          _usuario = null;
        }
      } catch (e) {
        debugPrint('AuthProvider: error en stream listener: $e');
        if (user != null) {
          _usuario = Usuario(uid: user.uid, email: user.email ?? '');
        }
      }
      _cargando = false;
      notifyListeners();
      _completerCarga?.complete();
      _completerCarga = null;
    });
  }

  Future<void> _esperarCargaCompleta() async {
    if (_usuario != null) return;
    _completerCarga = Completer<void>();
    try {
      await _completerCarga!.future.timeout(const Duration(seconds: 8));
    } on TimeoutException {
      debugPrint('AuthProvider: timeout esperando carga de usuario');
      _completerCarga = null;
      final current = _authService.usuarioActual;
      if (current != null && _usuario == null) {
        _usuario = Usuario(uid: current.uid, email: current.email ?? '');
        notifyListeners();
      }
    }
  }

  Future<void> registrar(String email, String password) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      final cred = await _authService.registrar(email, password);
      debugPrint('AuthProvider: registro exitoso uid=${cred.user?.uid}');
      await _esperarCargaCompleta();
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      debugPrint('AuthProvider: error registro Firebase: $e');
    } catch (e) {
      _error = 'Error al registrar';
      debugPrint('AuthProvider: error registro: $e');
    }
    _cargando = false;
    notifyListeners();
  }

  Future<void> iniciarSesion(String email, String password) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      final cred = await _authService.iniciarSesion(email, password);
      debugPrint('AuthProvider: login exitoso uid=${cred.user?.uid}');
      await _esperarCargaCompleta();
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      debugPrint('AuthProvider: error login Firebase: $e');
    } catch (e) {
      _error = 'Error al iniciar sesion';
      debugPrint('AuthProvider: error login: $e');
    }
    _cargando = false;
    notifyListeners();
  }

  Future<bool> iniciarSesionConGoogle() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.iniciarSesionConGoogle();
      debugPrint('AuthProvider: Google sign-in exitoso, esperando carga...');
      await _esperarCargaCompleta();
      debugPrint(
          'AuthProvider: carga completa, autenticado=${_usuario != null}');
      _cargando = false;
      notifyListeners();
      return true;
    } on GoogleSignInException catch (e) {
      debugPrint('AuthProvider: GoogleSignInException code=${e.code} msg=$e');
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        _error = null;
      } else {
        _error = 'Error en Google: ${e.code}';
      }
      _cargando = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('AuthProvider: error Google sign-in: $e');
      _error = 'Error al iniciar sesion con Google';
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> cerrarSesion() async {
    await _authService.cerrarSesion();
  }

  Future<void> actualizarPerfil(String nombre, int color) async {
    if (_usuario == null) return;
    try {
      await _firestoreService.actualizarUsuario(_usuario!.uid, {
        'nombreUsuario': nombre,
        'colorFavorito': color,
      });
      _usuario = _usuario!.copyWith(nombreUsuario: nombre, colorFavorito: color);
      notifyListeners();
    } catch (e) {
      _error = 'Error al actualizar perfil';
      notifyListeners();
    }
  }

  Future<void> actualizarHighScore(int score) async {
    if (_usuario == null) return;
    if (score > _usuario!.highScore) {
      await _firestoreService.actualizarUsuario(_usuario!.uid, {
        'highScore': score,
      });
      _usuario = _usuario!.copyWith(highScore: score);
      notifyListeners();
    }
  }
}
