import 'package:flutter/material.dart';
import 'irregular_paint.dart';

class FondoAnimado extends StatefulWidget {
  final Widget child;

  const FondoAnimado({super.key, required this.child});

  @override
  State<FondoAnimado> createState() => _FondoAnimadoState();
}

class _FondoAnimadoState extends State<FondoAnimado>
    with SingleTickerProviderStateMixin {
  late AnimationController _controlador;
  late Animation<double> _animacionFlotar;
  late Animation<double> _animacionRotar;
  late Animation<double> _animacionPulso;

  @override
  void initState() {
    super.initState();
    _controlador = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _animacionFlotar = Tween<double>(begin: -20, end: 20).animate(
      CurvedAnimation(parent: _controlador, curve: Curves.easeInOut),
    );

    _animacionRotar = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _controlador, curve: Curves.linear),
    );

    _animacionPulso = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(
        parent: _controlador,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controlador,
      child: widget.child,
      builder: (context, child) {
        return Container(
          color: const Color(0xFFFFF3E0),
          child: Stack(
            children: [
              // Figura 1 - poligono rojo que flota arriba a la izquierda
              Positioned(
                top: 40 + _animacionFlotar.value,
                left: 20,
                child: Transform.rotate(
                  angle: _animacionRotar.value * 0.3,
                  child: FiguraIrregular(
                    color: Colors.red.withValues(alpha: 0.7),
                    tamanio: 120,
                  ),
                ),
              ),
              // Figura 2 - poligono azul abajo a la derecha
              Positioned(
                bottom: 60 - _animacionFlotar.value,
                right: 20,
                child: Transform.rotate(
                  angle: -_animacionRotar.value * 0.2,
                  child: FiguraIrregular(
                    color: Colors.blue.withValues(alpha: 0.6),
                    tamanio: 150,
                  ),
                ),
              ),
              // Figura 3 - mancha amarilla que pulsa
              Positioned(
                top: 150,
                right: 40,
                child: Transform.scale(
                  scale: _animacionPulso.value,
                  child: ManchaAsimetrica(
                    color: Colors.yellow.withValues(alpha: 0.5),
                    tamanio: 100,
                  ),
                ),
              ),
              // Figura 4 - poligono verde
              Positioned(
                bottom: 120,
                left: 30,
                child: Transform.rotate(
                  angle: _animacionRotar.value * 0.15,
                  child: FiguraIrregular(
                    color: Colors.green.withValues(alpha: 0.5),
                    tamanio: 90,
                  ),
                ),
              ),
              // Figura 5 - mancha naranja
              Positioned(
                top: 300 + _animacionFlotar.value * 0.5,
                left: 100,
                child: ManchaAsimetrica(
                  color: Colors.orange.withValues(alpha: 0.4),
                  tamanio: 80,
                ),
              ),
              child!,
            ],
          ),
        );
      },
    );
  }
}
