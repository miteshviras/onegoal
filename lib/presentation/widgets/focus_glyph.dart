import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// The iconic Goal Planner Focus Glyph from Google Stitch designs.
class FocusGlyph extends StatelessWidget {
  final double size;

  const FocusGlyph({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceContainerHigh,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.darkOutlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: CustomPaint(
        painter: _FocusGlyphPainter(),
      ),
    );
  }
}

class _FocusGlyphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer faint background circle
    final bgPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.9, bgPaint);

    // Dashed / Arc ring
    final ringPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    // Arc of ~270 degrees
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.65),
      -pi / 2,
      1.5 * pi,
      false,
      ringPaint,
    );

    // Center focal dot
    final centerDotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.25, centerDotPaint);

    // Orbiting Emerald completion indicator dot at the top
    final emeraldDotPaint = Paint()
      ..color = AppColors.successEmerald
      ..style = PaintingStyle.fill;
    final topPoint = Offset(center.dx, center.dy - radius * 0.65);
    canvas.drawCircle(topPoint, radius * 0.16, emeraldDotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
