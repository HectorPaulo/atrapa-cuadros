import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum EstadoJuego { inicio, jugando, pausado, victoria, gameOver }

class GameProvider extends ChangeNotifier {
  static const int _vidasIniciales = 3;
  static const int _totalRondas = 5;
  static const List<int> _rondasObjetivos = [5, 8, 10, 12, 15];
  static const List<double> _rondasTiempos = [2.0, 1.6, 1.3, 1.0, 0.7];
  static const List<double> _rondasTamanos = [80, 70, 60, 50, 42];
  static const double _tiempoTransicion = 1.5;
  static const int puntajeVictoria = 50;

  EstadoJuego _estado = EstadoJuego.inicio;
  int _puntaje = 0;
  int _vidas = _vidasIniciales;
  double _tiempoAparecer = _rondasTiempos[0];
  Offset _posicionCuadro = Offset.zero;
  double _tamanoCuadro = _rondasTamanos[0];
  int _highScore = 0;
  Timer? _timerCuadro;
  String _nombreUsuario = 'Jugador';
  Color _colorJugador = Colors.red;
  final Random _random = Random();
  Size _ultimoTamano = Size.zero;

  int _ronda = 1;
  int _puntajeEnRonda = 0;
  int _combo = 0;
  int _maxCombo = 0;
  bool _enTransicionRonda = false;

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
  int get ronda => _ronda;
  int get combo => _combo;
  int get maxCombo => _maxCombo;
  int get puntajeEnRonda => _puntajeEnRonda;
  bool get enTransicionRonda => _enTransicionRonda;
  int get totalRondas => _totalRondas;
  int get objetivoRondaActual => _rondasObjetivos[_ronda - 1];

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
    _ronda = 1;
    _puntajeEnRonda = 0;
    _combo = 0;
    _maxCombo = 0;
    _enTransicionRonda = false;
    _tiempoAparecer = _rondasTiempos[0];
    _tamanoCuadro = _rondasTamanos[0];
    _ultimoTamano = tamanoPantalla;
    _generarPosicion(tamanoPantalla);
    notifyListeners();
    _iniciarTimer();
  }

  void _iniciarTimer() {
    _timerCuadro?.cancel();
    _timerCuadro = Timer(Duration(milliseconds: (_tiempoAparecer * 1000).toInt()), () {
      if (_estado == EstadoJuego.jugando && !_enTransicionRonda) {
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
    if (_estado != EstadoJuego.jugando || _enTransicionRonda) return;

    _timerCuadro?.cancel();

    _combo++;
    if (_combo > _maxCombo) _maxCombo = _combo;

    final bonus = (_combo ~/ 5).clamp(0, 2);
    final puntosGanados = 1 + bonus;
    _puntaje += puntosGanados;
    _puntajeEnRonda++;
    _ultimoTamano = tamanoPantalla;
    notifyListeners();

    if (_puntajeEnRonda >= _rondasObjetivos[_ronda - 1]) {
      _completarRonda();
      return;
    }

    _generarPosicion(tamanoPantalla);
    notifyListeners();
    _iniciarTimer();
  }

  void _completarRonda() {
    _timerCuadro?.cancel();
    _enTransicionRonda = true;
    notifyListeners();

    Future.delayed(Duration(milliseconds: (_tiempoTransicion * 1000).toInt()), () {
      if (_ronda >= _totalRondas) {
        _estado = EstadoJuego.victoria;
        _enTransicionRonda = false;
        _guardarHighScore();
        notifyListeners();
      } else {
        _ronda++;
        _puntajeEnRonda = 0;
        _tiempoAparecer = _rondasTiempos[_ronda - 1];
        _tamanoCuadro = _rondasTamanos[_ronda - 1];
        _enTransicionRonda = false;
        _generarPosicion(_ultimoTamano);
        notifyListeners();
        _iniciarTimer();
      }
    });
  }

  void _perderVida() {
    _vidas--;
    _combo = 0;
    onPerderVida?.call();
    notifyListeners();

    if (_vidas <= 0) {
      _estado = EstadoJuego.gameOver;
      onGameOver?.call();
      _guardarHighScore();
      notifyListeners();
      return;
    }

    _tiempoAparecer = _rondasTiempos[_ronda - 1];
    _tamanoCuadro = _rondasTamanos[_ronda - 1];
    notifyListeners();
    _iniciarTimer();
  }

  void tocarFuera() {
    if (_estado != EstadoJuego.jugando || _enTransicionRonda) return;
    _timerCuadro?.cancel();
    _perderVida();
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
    _ronda = 1;
    _puntajeEnRonda = 0;
    _combo = 0;
    _maxCombo = 0;
    _enTransicionRonda = false;
    _tiempoAparecer = _rondasTiempos[0];
    _tamanoCuadro = _rondasTamanos[0];
    notifyListeners();
  }

  @override
  void dispose() {
    _timerCuadro?.cancel();
    super.dispose();
  }
}
