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
    final puntos = 6 + random.nextInt(4);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radio = size.width / 2;

    final vertices = <Offset>[];
    for (int i = 0; i < puntos; i++) {
      final angulo = (2 * pi * i / puntos) + (random.nextDouble() - 0.5) * 0.8;
      final dist = radio * (0.6 + random.nextDouble() * 0.4);
      vertices.add(Offset(
        cx + dist * cos(angulo),
        cy + dist * sin(angulo),
      ));
    }

    final path = _poligonoRedondeado(vertices, tamanio: 18);
    canvas.drawPath(path, paint);

    final paintBorde = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(path, paintBorde);
  }

  /// Version local que recibe [tamanio] como el radio de redondeo.
  Path _poligonoRedondeado(List<Offset> pts, {required double tamanio}) {
    if (pts.length < 3) return Path()..addPolygon(pts, true);
    final path = Path();
    final n = pts.length;
    final r = min(tamanio, 20.0);

    for (int i = 0; i < n; i++) {
      final a = pts[(i - 1 + n) % n];
      final b = pts[i];
      final c = pts[(i + 1) % n];

      final ab = (a - b);
      final cb = (c - b);
      final dAB = ab.distance;
      final dCB = cb.distance;

      if (dAB < 0.001 || dCB < 0.001) {
        path.lineTo(b.dx, b.dy);
        continue;
      }

      final abN = ab / dAB;
      final cbN = cb / dCB;
      final radioEfectivo = min(r, min(dAB, dCB) * 0.4);
      final pIn = b + abN * radioEfectivo;
      final pOut = b + cbN * radioEfectivo;

      if (i == 0) {
        path.moveTo(pIn.dx, pIn.dy);
      } else {
        path.lineTo(pIn.dx, pIn.dy);
      }
      path.quadraticBezierTo(b.dx, b.dy, pOut.dx, pOut.dy);
    }
    path.close();
    return path;
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
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radio = size.width / 2;
    final puntos = 10;

    final vertices = <Offset>[];
    for (int i = 0; i <= puntos; i++) {
      final angulo = 2 * pi * i / puntos;
      final dist = radio * (0.4 + random.nextDouble() * 0.6);
      vertices.add(Offset(
        cx + dist * cos(angulo),
        cy + dist * sin(angulo),
      ));
    }

    // Usar el mismo redondeo para las manchas (curvas mas suaves)
    final pathRedondeado = _poligonoRedondeado(vertices, tamanio: 24);
    canvas.drawPath(pathRedondeado, paint);
  }

  Path _poligonoRedondeado(List<Offset> pts, {required double tamanio}) {
    if (pts.length < 3) return Path()..addPolygon(pts, true);
    final path = Path();
    final n = pts.length;
    final r = min(tamanio, 30.0);

    for (int i = 0; i < n; i++) {
      final a = pts[(i - 1 + n) % n];
      final b = pts[i];
      final c = pts[(i + 1) % n];

      final ab = (a - b);
      final cb = (c - b);
      final dAB = ab.distance;
      final dCB = cb.distance;

      if (dAB < 0.001 || dCB < 0.001) {
        path.lineTo(b.dx, b.dy);
        continue;
      }

      final abN = ab / dAB;
      final cbN = cb / dCB;
      final radioEfectivo = min(r, min(dAB, dCB) * 0.4);
      final pIn = b + abN * radioEfectivo;
      final pOut = b + cbN * radioEfectivo;

      if (i == 0) {
        path.moveTo(pIn.dx, pIn.dy);
      } else {
        path.lineTo(pIn.dx, pIn.dy);
      }
      path.quadraticBezierTo(b.dx, b.dy, pOut.dx, pOut.dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _ManchaPainter oldDelegate) => false;
}
