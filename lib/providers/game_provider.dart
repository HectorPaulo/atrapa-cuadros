import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum EstadoJuego { inicio, jugando, pausado, victoria, gameOver }

class GameProvider extends ChangeNotifier {
  static const int _vidasIniciales = 3;
  static const int _puntajeVictoria = 30;
  static const double _tiempoInicial = 2.0;
  static const double _tiempoMinimo = 0.4;
  static const double _factorReduccion = 0.05;

  EstadoJuego _estado = EstadoJuego.inicio;
  int _puntaje = 0;
  int _vidas = _vidasIniciales;
  double _tiempoAparecer = _tiempoInicial;
  Offset _posicionCuadro = Offset.zero;
  double _tamanoCuadro = 80;
  int _highScore = 0;
  Timer? _timerCuadro;
  String _nombreUsuario = 'Jugador';
  Color _colorJugador = Colors.red;
  final Random _random = Random();

  // Callbacks opcionales para efectos de sonido
  VoidCallback? onPerderVida;
  VoidCallback? onGameOver;

  EstadoJuego get estado => _estado;
  int get puntaje => _puntaje;
  int get vidas => _vidas;
  double get tiempoAparecer => _tiempoAparecer;
  Offset get posicionCuadro => _posicionCuadro;
  double get tamanoCuadro => _tamanoCuadro;
  int get highScore => _highScore;
  String get nombreUsuario => _nombreUsuario;
  Color get colorJugador => _colorJugador;
  static int get puntajeVictoria => _puntajeVictoria;

  void setNombreUsuario(String nombre) {
    _nombreUsuario = nombre;
    notifyListeners();
  }

  void setColorJugador(Color color) {
    _colorJugador = color;
    notifyListeners();
  }

  Future<void> cargarHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt('highScore') ?? 0;
    notifyListeners();
  }

  Future<void> _guardarHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (_puntaje > _highScore) {
      _highScore = _puntaje;
      await prefs.setInt('highScore', _highScore);
    }
  }

  void iniciarJuego(Size tamanoPantalla) {
    _estado = EstadoJuego.jugando;
    _puntaje = 0;
    _vidas = _vidasIniciales;
    _tiempoAparecer = _tiempoInicial;
    _generarPosicion(tamanoPantalla);
    notifyListeners();
    _iniciarTimer();
  }

  void _iniciarTimer() {
    _timerCuadro?.cancel();
    _timerCuadro = Timer(Duration(milliseconds: (_tiempoAparecer * 1000).toInt()), () {
      if (_estado == EstadoJuego.jugando) {
        _perderVida();
      }
    });
  }

  void _generarPosicion(Size tamano) {
    final maxX = (tamano.width - _tamanoCuadro - 20).toInt();
    final maxY = (tamano.height - _tamanoCuadro - 100).toInt();
    if (maxX > 0 && maxY > 0) {
      _posicionCuadro = Offset(
        (_random.nextInt(maxX) + 10).toDouble(),
        (_random.nextInt(maxY) + 80).toDouble(),
      );
    }
  }

  void tocarCuadro(Size tamanoPantalla) {
    if (_estado != EstadoJuego.jugando) return;

    _timerCuadro?.cancel();
    _puntaje++;
    notifyListeners();

    if (_puntaje >= _puntajeVictoria) {
      _estado = EstadoJuego.victoria;
      _guardarHighScore();
      notifyListeners();
      return;
    }

    _tiempoAparecer = (_tiempoInicial - (_puntaje * _factorReduccion))
        .clamp(_tiempoMinimo, _tiempoInicial);
    _tamanoCuadro = (80 - (_puntaje * 1.2)).clamp(40, 80).toDouble();
    _generarPosicion(tamanoPantalla);
    notifyListeners();
    _iniciarTimer();
  }

  void _perderVida() {
    _vidas--;
    onPerderVida?.call();
    notifyListeners();

    if (_vidas <= 0) {
      _estado = EstadoJuego.gameOver;
      onGameOver?.call();
      _guardarHighScore();
      notifyListeners();
      return;
    }

    _tiempoAparecer = _tiempoInicial;
    _tamanoCuadro = 80;
    notifyListeners();
    _iniciarTimer();
  }

  void pausar() {
    _estado = EstadoJuego.pausado;
    _timerCuadro?.cancel();
    notifyListeners();
  }

  void reanudar() {
    if (_estado == EstadoJuego.pausado) {
      _estado = EstadoJuego.jugando;
      notifyListeners();
      _iniciarTimer();
    }
  }

  void reiniciar(Size tamanoPantalla) {
    _timerCuadro?.cancel();
    iniciarJuego(tamanoPantalla);
  }

  void volverAlMenu() {
    _timerCuadro?.cancel();
    _estado = EstadoJuego.inicio;
    _puntaje = 0;
    _vidas = _vidasIniciales;
    _tiempoAparecer = _tiempoInicial;
    _tamanoCuadro = 80;
    notifyListeners();
  }

  @override
  void dispose() {
    _timerCuadro?.cancel();
    super.dispose();
  }
}
