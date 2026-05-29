import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/audio_service.dart';
import '../widgets/animated_background.dart';

final List<Color> coloresDisponibles = [
  Colors.red,
  Colors.blue,
  Colors.yellow,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.pink,
  Colors.teal,
];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nombreCtrl = TextEditingController();
  late Color _colorSeleccionado;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final authProv = context.read<AuthAppProvider>();
    _nombreCtrl.text = authProv.usuario?.nombreUsuario ?? '';
    _colorSeleccionado = Color(authProv.usuario?.colorFavorito ?? 0xFFFF0000);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    final authProv = context.read<AuthAppProvider>();
    await authProv.actualizarPerfil(
      _nombreCtrl.text.trim(),
      _colorSeleccionado.toARGB32(),
    );
    if (mounted) {
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthAppProvider>();

    return Scaffold(
      body: FondoAnimado(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                    'MI PERFIL',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Avatar con color seleccionado
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _colorSeleccionado,
                    border: Border.all(color: Colors.black, width: 4),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(5, 5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: _colorSeleccionado.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  authProv.usuario?.email ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                // Campo nombre
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Nombre de usuario',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Selector de color
                const Text(
                  'Color favorito:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: coloresDisponibles.map((color) {
                    final seleccionado = color.toARGB32() == _colorSeleccionado.toARGB32();
                    return GestureDetector(
                      onTap: () => setState(() => _colorSeleccionado = color),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color,
                          border: Border.all(
                            color: seleccionado ? Colors.yellow : Colors.black,
                            width: seleccionado ? 4 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: seleccionado ? Colors.yellow : Colors.black26,
                              offset: const Offset(3, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                // Boton guardar
                GestureDetector(
                  onTap: _guardando
                      ? null
                      : () {
                          context.read<AudioService>().playEfectoClick();
                          _guardar();
                        },
                  child: Container(
                    width: 240,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _guardando ? Colors.grey : Colors.blue,
                      border: Border.all(color: Colors.black, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(5, 5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: _guardando
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                          )
                        : const Text(
                            'GUARDAR',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // Boton volver
                GestureDetector(
                  onTap: () {
                    context.read<AudioService>().playEfectoClick();
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 240,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      border: Border.all(color: Colors.black, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(5, 5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Text(
                      'VOLVER',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
