import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';

class VictoryScreen extends StatefulWidget {
  const VictoryScreen({super.key});

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audio = context.read<AudioService>();
      audio.detenerTodo();
      audio.playEfectoVictoria();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameProv = context.watch<GameProvider>();

    return Scaffold(
      body: Container(
        color: const Color(0xFF1B5E20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 280,
                  height: 280,
                  child: Lottie.asset(
                    'assets/618fc384-1184-11ee-94d3-7fa9529e93c3.json',
                    repeat: true,
                    animate: true,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                    'VICTORIA!',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.red,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Puntaje: ${gameProv.puntaje}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                  ),
                ),
                const SizedBox(height: 32),
                _BotonVictoria(
                  texto: 'JUGAR DE NUEVO',
                  color: Colors.blue,
                  onTap: () {
                    context.read<AudioService>().playEfectoClick();
                    gameProv.volverAlMenu();
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/juego');
                  },
                ),
                const SizedBox(height: 12),
                _BotonVictoria(
                  texto: 'MENU PRINCIPAL',
                  color: Colors.red,
                  onTap: () {
                    context.read<AudioService>().playEfectoClick();
                    gameProv.volverAlMenu();
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BotonVictoria extends StatelessWidget {
  final String texto;
  final Color color;
  final VoidCallback onTap;

  const _BotonVictoria({
    required this.texto,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
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
          ),
        ),
      ),
    );
  }
}
