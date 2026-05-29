import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService extends ChangeNotifier {
  // Reproductor para musica de fondo (un solo hilo)
  AudioPlayer? _musicPlayer;
  // Reproductor para efectos de sonido
  final AudioPlayer _sfxPlayer = AudioPlayer();
  // Volumen independiente para musica y efectos
  double _volumenMusica = 1.0;
  double _volumenEfectos = 1.0;

  double get volumenMusica => _volumenMusica;
  double get volumenEfectos => _volumenEfectos;

  // ─── Musica de fondo ───────────────────────────────────────────

  Future<void> playMusicaLobby() async {
    await _detenerMusica();
    _musicPlayer = AudioPlayer();
    await _musicPlayer!.setSource(AssetSource('sounds/lobby_music.mp3'));
    await _musicPlayer!.setVolume(_volumenMusica);
    await _musicPlayer!.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer!.resume();
  }

  Future<void> playMusicaJuego() async {
    await _detenerMusica();
    _musicPlayer = AudioPlayer();
    await _musicPlayer!.setSource(AssetSource('sounds/game_music.mp3'));
    await _musicPlayer!.setVolume(_volumenMusica);
    await _musicPlayer!.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer!.resume();
  }

  Future<void> _detenerMusica() async {
    await _musicPlayer?.stop();
    _musicPlayer?.dispose();
    _musicPlayer = null;
  }

  // ─── Efectos de sonido ─────────────────────────────────────────

  Future<void> playEfectoTap() async {
    await _playEfecto('sounds/tap.wav');
  }

  Future<void> playEfectoPerderVida() async {
    await _playEfecto('sounds/lose_life.wav');
  }

  Future<void> playEfectoGameOver() async {
    await _playEfecto('sounds/game_over.wav');
  }

  Future<void> playEfectoVictoria() async {
    await _playEfecto('sounds/victory.wav');
  }

  Future<void> playEfectoClick() async {
    await _playEfecto('sounds/click.wav');
  }

  Future<void> _playEfecto(String asset) async {
    await _sfxPlayer.stop();
    await _sfxPlayer.setSource(AssetSource(asset));
    await _sfxPlayer.setVolume(_volumenEfectos);
    await _sfxPlayer.resume();
  }

  // ─── Control de volumen ────────────────────────────────────────

  void setVolumenMusica(double v) {
    _volumenMusica = v.clamp(0.0, 1.0);
    _musicPlayer?.setVolume(_volumenMusica);
    notifyListeners();
  }

  void setVolumenEfectos(double v) {
    _volumenEfectos = v.clamp(0.0, 1.0);
    notifyListeners();
  }

  // ─── Limpieza ──────────────────────────────────────────────────

  Future<void> detenerTodo() async {
    await _detenerMusica();
    await _sfxPlayer.stop();
  }

  @override
  void dispose() {
    _musicPlayer?.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }
}
