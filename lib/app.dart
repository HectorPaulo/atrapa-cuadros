import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/game_provider.dart';
import 'services/audio_service.dart';
import 'screens/menu_screen.dart';
import 'screens/game_screen.dart';
import 'screens/victory_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthAppProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => AudioService()),
      ],
      child: MaterialApp(
        title: 'Atrapa el Cuadro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red,
            brightness: Brightness.light,
          ),
        ),
        initialRoute: '/carga',
        routes: {
          '/carga': (context) => const _ScreenCarga(),
          '/menu': (context) => const MenuScreen(),
          '/juego': (context) => const GameScreen(),
          '/victoria': (context) => const VictoryScreen(),
          '/login': (context) => const LoginScreen(),
          '/perfil': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}

class _ScreenCarga extends StatefulWidget {
  const _ScreenCarga();

  @override
  State<_ScreenCarga> createState() => _ScreenCargaState();
}

class _ScreenCargaState extends State<_ScreenCarga> {
  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    final gameProv = context.read<GameProvider>();
    await gameProv.cargarHighScore();

    if (mounted) {
      final authProv = context.read<AuthAppProvider>();
      if (authProv.estaAutenticado) {
        Navigator.pushReplacementNamed(context, '/menu');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFFFF3E0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset(
                  'assets/2d7b54b6-116e-11ee-9501-37ee3f293698.json',
                  repeat: true,
                  animate: true,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'CARGANDO...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
