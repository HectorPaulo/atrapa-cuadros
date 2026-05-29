import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/auth_provider.dart';
import '../services/audio_service.dart';
import '../widgets/animated_background.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AudioService>().playMusicaLobby();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameProv = context.watch<GameProvider>();
    final authProv = context.watch<AuthAppProvider>();

    return Scaffold(
      body: FondoAnimado(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  border: Border.all(color: Colors.black, width: 4),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(6, 6),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Text(
                  'ATRAPA EL CUADRO',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.red,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 100,
                height: 100,
                child: Lottie.asset(
                  'assets/b80c8f58-1166-11ee-bad3-8fb1e44c9ce0.json',
                  repeat: true,
                  animate: true,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue,
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
                  'HIGH SCORE: ${gameProv.highScore}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (authProv.estaAutenticado)
                Text(
                  'Bienvenido, ${authProv.usuario?.nombreUsuario.isNotEmpty == true ? authProv.usuario!.nombreUsuario : authProv.usuario?.email ?? ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              const Spacer(),
              _BotonNeoBrutalista(
                texto: 'JUGAR',
                color: Colors.red,
                onTap: () {
                  context.read<AudioService>().playEfectoClick();
                  final size = MediaQuery.of(context).size;
                  gameProv.iniciarJuego(size);
                  Navigator.pushNamed(context, '/juego');
                },
              ),
              const SizedBox(height: 16),
              _BotonNeoBrutalista(
                texto: 'PERFIL',
                color: Colors.blue,
                onTap: () {
                  context.read<AudioService>().playEfectoClick();
                  Navigator.pushNamed(context, '/perfil');
                },
              ),
              const SizedBox(height: 16),
              if (authProv.estaAutenticado)
                _BotonNeoBrutalista(
                  texto: 'CERRAR SESION',
                  color: Colors.grey,
                  onTap: () {
                    context.read<AudioService>().playEfectoClick();
                    authProv.cerrarSesion();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                )
              else
                _BotonNeoBrutalista(
                  texto: 'INICIAR SESION',
                  color: Colors.green,
                  onTap: () {
                    context.read<AudioService>().playEfectoClick();
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotonNeoBrutalista extends StatelessWidget {
  final String texto;
  final Color color;
  final VoidCallback onTap;

  const _BotonNeoBrutalista({
    required this.texto,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(5, 5),
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
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
