import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/audio_service.dart';
import '../widgets/animated_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _esRegistro = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AudioService>().playMusicaLobby();
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    final authProv = context.read<AuthAppProvider>();
    if (_esRegistro) {
      await authProv.registrar(_emailCtrl.text.trim(), _passCtrl.text.trim());
    } else {
      await authProv.iniciarSesion(_emailCtrl.text.trim(), _passCtrl.text.trim());
    }

    if (mounted && authProv.error == null && authProv.estaAutenticado) {
      Navigator.pushReplacementNamed(context, '/menu');
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
            child: Form(
              key: _formKey,
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
                    child: Text(
                      _esRegistro ? 'REGISTRO' : 'INICIAR SESION',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Campo email
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
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Correo electronico',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Ingresa tu correo' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Campo password
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
                      controller: _passCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Contrasena',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      obscureText: true,
                      validator: (v) =>
                          v == null || v.length < 6 ? 'Minimo 6 caracteres' : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (authProv.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        authProv.error!,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Boton Google
                  // GestureDetector(
                  //   onTap: authProv.cargando
                  //       ? null
                  //       : () async {
                  //           context.read<AudioService>().playEfectoClick();
                  //           final nav = Navigator.of(context);
                  //           final ok = await context
                  //               .read<AuthAppProvider>()
                  //               .iniciarSesionConGoogle();
                  //           if (ok && mounted) {
                  //             nav.pushReplacementNamed('/menu');
                  //           }
                  //         },
                  //   child: Container(
                  //     width: 240,
                  //     padding: const EdgeInsets.symmetric(vertical: 14),
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       border: Border.all(color: Colors.black, width: 3),
                  //       boxShadow: const [
                  //         BoxShadow(
                  //           color: Colors.black,
                  //           offset: Offset(5, 5),
                  //           blurRadius: 0,
                  //         ),
                  //       ],
                  //     ),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         SvgPicture.asset(
                  //           'assets/google-icon-logo.svg',
                  //           width: 24,
                  //           height: 24,
                  //         ),
                  //         const SizedBox(width: 8),
                  //         const Text(
                  //           'GOOGLE',
                  //           style: TextStyle(
                  //             fontSize: 18,
                  //             fontWeight: FontWeight.bold,
                  //             color: Colors.black87,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 16),
                  // Boton enviar
                  GestureDetector(
                    onTap: authProv.cargando ? null : _enviar,
                    child: Container(
                      width: 240,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: authProv.cargando ? Colors.grey : Colors.red,
                        border: Border.all(color: Colors.black, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(5, 5),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: authProv.cargando
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
                          : Text(
                              _esRegistro ? 'REGISTRARSE' : 'INGRESAR',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Cambiar entre login y registro
                  TextButton(
                    onPressed: () => setState(() => _esRegistro = !_esRegistro),
                    child: Text(
                      _esRegistro
                          ? 'Ya tienes cuenta? Inicia sesion'
                          : 'No tienes cuenta? Registrate',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
