import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/auth_provider.dart';
import '../services/audio_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  bool _navegandoVictoria = false;

  // Controlador para animacion de pulsacion al tocar el cuadro
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  // Controlador para animacion de perdida de vida (flash rojo)
  late final AnimationController _lifeCtrl;
  late final Animation<double> _lifeFlash;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _pulseAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(
      parent: _pulseCtrl,
      curve: Curves.easeOut,
    ));

    _lifeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _lifeFlash = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _lifeCtrl, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audio = context.read<AudioService>();
      audio.playMusicaJuego();
      final prov = context.read<GameProvider>();
      prov.onPerderVida = () {
        audio.playEfectoPerderVida();
        _lifeCtrl.forward(from: 0.0);
      };
      prov.onGameOver = () => audio.playEfectoGameOver();
      if (prov.estado != EstadoJuego.jugando) {
        final size = MediaQuery.of(context).size;
        prov.iniciarJuego(size);
      }
    });
  }

  void _handleTapSquare() {
    _pulseCtrl.forward(from: 0.0);
    final audio = context.read<AudioService>();
    audio.playEfectoTap();
    final size = MediaQuery.of(context).size;
    final gameProv = context.read<GameProvider>();
    gameProv.tocarCuadro(size);
    final authProv = context.read<AuthAppProvider>();
    if (authProv.estaAutenticado) {
      authProv.actualizarHighScore(gameProv.highScore);
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _lifeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameProv = context.watch<GameProvider>();
    final audio = context.read<AudioService>();

    if (gameProv.estado == EstadoJuego.victoria && !_navegandoVictoria) {
      _navegandoVictoria = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/victoria');
        }
      });
    }

    return Scaffold(
      body: GestureDetector(
        onTap: () => gameProv.tocarFuera(),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Container(color: const Color(0xFFFFF3E0)),

            // Overlay de flash rojo al perder vida
            if (_lifeCtrl.value > 0)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _lifeCtrl,
                  builder: (context, _) {
                    return Container(
                      color: Colors.red.withValues(alpha: _lifeFlash.value),
                    );
                  },
                ),
              ),

            // HUD superior
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _HudItem(
                      color: Colors.red,
                      child: Row(
                        children: List.generate(3, (i) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              i < gameProv.vidas
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.white,
                              size: 24,
                            ),
                          );
                        }),
                      ),
                    ),
                    _HudItem(
                      color: Colors.blue,
                      child: Text(
                        'R${gameProv.ronda}/${gameProv.totalRondas}  ${gameProv.puntaje}pts',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (gameProv.combo > 1)
                          _HudItem(
                            color: Colors.orange,
                            child: Text(
                              'x${gameProv.combo}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            audio.playEfectoClick();
                            gameProv.pausar();
                          },
                          child: _HudItem(
                            color: Colors.yellow,
                            child: const Icon(Icons.pause, color: Colors.black, size: 28),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Cuadro para atrapar con animacion de desplazamiento y pulsacion
            if (gameProv.estado == EstadoJuego.jugando)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: gameProv.posicionCuadro.dx,
                top: gameProv.posicionCuadro.dy,
                width: gameProv.tamanoCuadro,
                height: gameProv.tamanoCuadro,
                child: ScaleTransition(
                  scale: _pulseAnim,
                  child: GestureDetector(
                    onTap: _handleTapSquare,
                    child: Container(
                      decoration: BoxDecoration(
                        color: gameProv.colorJugador,
                        border: Border.all(color: Colors.black, width: 4),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(5, 5),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.touch_app, color: Colors.white, size: 32),
                      ),
                    ),
                  ),
                ),
              ),

            // Transicion entre rondas
            if (gameProv.enTransicionRonda)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          border: Border.all(color: Colors.black, width: 4),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(6, 6),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          gameProv.ronda < gameProv.totalRondas
                              ? 'RONDA ${gameProv.ronda} COMPLETA!'
                              : 'RONDA FINAL COMPLETA!',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Overlay de pausa
            if (gameProv.estado == EstadoJuego.pausado)
              _OverlayJuego(
                color: Colors.yellow,
                titulo: 'PAUSA',
                colorTitulo: Colors.red,
                children: [
                  _BotonOverlay(
                    texto: 'REANUDAR',
                    color: Colors.green,
                    onTap: () => gameProv.reanudar(),
                  ),
                  const SizedBox(height: 12),
                  _BotonOverlay(
                    texto: 'SALIR',
                    color: Colors.red,
                    onTap: () {
                      gameProv.volverAlMenu();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),

            // Overlay de Game Over
            if (gameProv.estado == EstadoJuego.gameOver)
              _OverlayJuego(
                color: Colors.red,
                titulo: 'GAME OVER',
                colorTitulo: Colors.white,
                children: [
                  Text(
                    'Puntaje: ${gameProv.puntaje}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ronda: ${gameProv.ronda}/${gameProv.totalRondas}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (gameProv.maxCombo > 1)
                    Text(
                      'Mejor combo: x${gameProv.maxCombo}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'High Score: ${gameProv.highScore}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _BotonOverlay(
                    texto: 'REINTENTAR',
                    color: Colors.blue,
                    onTap: () {
                      final size = MediaQuery.of(context).size;
                      gameProv.reiniciar(size);
                    },
                  ),
                  const SizedBox(height: 12),
                  _BotonOverlay(
                    texto: 'MENU',
                    color: Colors.grey,
                    onTap: () {
                      gameProv.volverAlMenu();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),

            // Barra de progreso
            if (gameProv.estado == EstadoJuego.jugando)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 280,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final progreso =
                            gameProv.puntaje / GameProvider.puntajeVictoria;
                        return Row(
                          children: [
                            Container(
                              width: constraints.maxWidth * progreso.clamp(0.0, 1.0),
                              decoration: const BoxDecoration(color: Colors.green),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Widget reutilizable para items del HUD
class _HudItem extends StatelessWidget {
  final Color color;
  final Widget child;

  const _HudItem({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

// Overlay generico para pausa/game over
class _OverlayJuego extends StatelessWidget {
  final Color color;
  final String titulo;
  final Color colorTitulo;
  final List<Widget> children;

  const _OverlayJuego({
    required this.color,
    required this.titulo,
    required this.colorTitulo,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: Colors.black, width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(6, 6),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(
                titulo,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: colorTitulo,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _BotonOverlay extends StatelessWidget {
  final String texto;
  final Color color;
  final VoidCallback onTap;

  const _BotonOverlay({
    required this.texto,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<AudioService>().playEfectoClick();
        onTap();
      },
      child: Container(
        width: 220,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
