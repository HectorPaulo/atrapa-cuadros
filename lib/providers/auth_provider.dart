import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class AuthAppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  Usuario? _usuario;
  bool _cargando = false;
  String? _error;

  Usuario? get usuario => _usuario;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get estaAutenticado => _usuario != null;

  AuthAppProvider() {
    _authService.usuarioStream.listen((User? user) async {
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
      _cargando = false;
      notifyListeners();
    });
  }

  Future<void> registrar(String email, String password) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.registrar(email, password);
    } on FirebaseAuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Error al registrar';
    }
    _cargando = false;
    notifyListeners();
  }

  Future<void> iniciarSesion(String email, String password) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.iniciarSesion(email, password);
    } on FirebaseAuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Error al iniciar sesion';
    }
    _cargando = false;
    notifyListeners();
  }

  Future<void> iniciarSesionConGoogle() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      final credencial = await _authService.iniciarSesionConGoogle();
      if (credencial == null) {
        _error = 'Inicio de sesion cancelado';
      }
    } catch (e) {
      _error = 'Error al iniciar sesion con Google';
    }
    _cargando = false;
    notifyListeners();
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
