import 'dart:math' as math;

import 'package:flutter/material.dart';

class MagicBackground extends StatelessWidget {
  const MagicBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF041B48),
                Color(0xFF0A2C63),
                Color(0xFF061532),
              ],
            ),
          ),
        ),
        const CustomPaint(painter: _StarsPainter()),
        Positioned(
          top: -90,
          right: -80,
          child: Container(
            width: 260,
            height: 260,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x334B8DFF), Colors.transparent],
              ),
            ),
          ),
        ),
        SafeArea(child: child),
      ],
    );
  }
}

class _StarsPainter extends CustomPainter {
  const _StarsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(7);
    final paint = Paint()..color = const Color(0xCCFFF1B6);

    for (var i = 0; i < 85; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 0.6 + random.nextDouble() * 1.8;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
