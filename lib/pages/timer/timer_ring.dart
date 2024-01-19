import 'dart:math';

import 'package:flutter/material.dart';

class TimerPainter extends CustomPainter {
  double minutes;
  ColorScheme colorScheme;
  TimerPainter({
    required this.minutes,
    required this.colorScheme,
  });
  @override
  void paint(Canvas canvas, Size size) {
    double minSize = min(size.width, size.height);
    double strokeWidth = minSize * 0.3;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = (minSize - strokeWidth) / 2;

    Paint ringBg = Paint()
      ..color = colorScheme.onInverseSurface
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.inner, minSize / 5)
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, ringBg);

    Paint ringFill = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    double fillAngle = 2 * pi * (minutes / 60);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -pi / 2 - fillAngle, fillAngle, false, ringFill);

    Paint centerShadow = Paint()
      ..color = colorScheme.shadow.withOpacity(.2)
      ..style = PaintingStyle.fill
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - strokeWidth / 2, centerShadow);

    Paint centerBg = Paint()
      ..color = colorScheme.background
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.inner, minSize / 20)
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - strokeWidth / 2, centerBg);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
