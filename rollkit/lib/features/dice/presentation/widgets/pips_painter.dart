import 'package:flutter/material.dart';

class PipsPainter extends CustomPainter {
  final int value;
  final Color color;

  PipsPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double dotSize = size.width * 0.18; // Dot size relative to die size
    final double radius = dotSize / 2;

    // Grid positions (0..1 range)
    // 0.2  0.5  0.8
    //
    // 0.2  (TL)    (TR) 0.8
    // 0.5  (ML) (C) (MR) 0.5
    // 0.8  (BL)    (BR) 0.8

    final double left = size.width * 0.22;
    final double center = size.width * 0.5;
    final double right = size.width * 0.78;

    final double top = size.height * 0.22;
    final double mid = size.height * 0.5;
    final double bottom = size.height * 0.78;

    final List<Offset> pips = [];

    switch (value) {
      case 1:
        pips.add(Offset(center, mid));
        break;
      case 2:
        pips.add(Offset(left, top));
        pips.add(Offset(right, bottom));
        break;
      case 3:
        pips.add(Offset(left, top));
        pips.add(Offset(center, mid));
        pips.add(Offset(right, bottom));
        break;
      case 4:
        pips.add(Offset(left, top));
        pips.add(Offset(right, top));
        pips.add(Offset(left, bottom));
        pips.add(Offset(right, bottom));
        break;
      case 5:
        pips.add(Offset(left, top));
        pips.add(Offset(right, top));
        pips.add(Offset(center, mid));
        pips.add(Offset(left, bottom));
        pips.add(Offset(right, bottom));
        break;
      case 6:
        pips.add(Offset(left, top));
        pips.add(Offset(right, top));
        pips.add(Offset(left, mid));
        pips.add(Offset(right, mid));
        pips.add(Offset(left, bottom));
        pips.add(Offset(right, bottom));
        break;
    }

    for (var pip in pips) {
      canvas.drawCircle(pip, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PipsPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}
