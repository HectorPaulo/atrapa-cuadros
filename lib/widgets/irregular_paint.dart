import 'dart:math';
import 'package:flutter/material.dart';

class FiguraIrregular extends StatelessWidget {
  final Color color;
  final double tamanio;
  final double rotacion;
  final double desplazamientoX;
  final double desplazamientoY;

  const FiguraIrregular({
    super.key,
    required this.color,
    required this.tamanio,
    this.rotacion = 0,
    this.desplazamientoX = 0,
    this.desplazamientoY = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(desplazamientoX, desplazamientoY),
      child: Transform.rotate(
        angle: rotacion,
        child: CustomPaint(
          size: Size(tamanio, tamanio),
          painter: _PoligonoPainter(color: color),
        ),
      ),
    );
  }
}

class _PoligonoPainter extends CustomPainter {
  final Color color;

  _PoligonoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final random = Random(42);
    final path = Path();
    final puntos = 6 + random.nextInt(4);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radio = size.width / 2;

    for (int i = 0; i < puntos; i++) {
      final angulo = (2 * pi * i / puntos) + (random.nextDouble() - 0.5) * 0.8;
      final dist = radio * (0.6 + random.nextDouble() * 0.4);
      final x = cx + dist * cos(angulo);
      final y = cy + dist * sin(angulo);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    final paintBorde = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(path, paintBorde);
  }

  @override
  bool shouldRepaint(covariant _PoligonoPainter oldDelegate) => false;
}

class ManchaAsimetrica extends StatelessWidget {
  final Color color;
  final double tamanio;

  const ManchaAsimetrica({super.key, required this.color, required this.tamanio});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(tamanio, tamanio),
      painter: _ManchaPainter(color: color),
    );
  }
}

class _ManchaPainter extends CustomPainter {
  final Color color;

  _ManchaPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final random = Random(42);
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radio = size.width / 2;
    final puntos = 10;

    for (int i = 0; i <= puntos; i++) {
      final angulo = 2 * pi * i / puntos;
      final dist = radio * (0.4 + random.nextDouble() * 0.6);
      final x = cx + dist * cos(angulo);
      final y = cy + dist * sin(angulo);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final anguloAnt = 2 * pi * (i - 1) / puntos;
        final distAnt = radio * (0.4 + random.nextDouble() * 0.6);
        final cx1 = cx + distAnt * cos(anguloAnt + 0.3);
        final cy1 = cy + distAnt * sin(anguloAnt + 0.3);
        final anguloSig = 2 * pi * (i + 1) / puntos;
        final distSig = radio * (0.4 + random.nextDouble() * 0.6);
        final cx2 = cx + distSig * cos(anguloSig - 0.3);
        final cy2 = cy + distSig * sin(anguloSig - 0.3);
        path.cubicTo(cx1, cy1, cx2, cy2, x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ManchaPainter oldDelegate) => false;
}
