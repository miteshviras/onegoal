import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class TripleProgressRings extends StatelessWidget {
  final double missionsProgress;
  final double habitsProgress;
  final double focusHoursProgress;
  final int harmonyPercentage;
  final double size;

  const TripleProgressRings({
    super.key,
    required this.missionsProgress,
    required this.habitsProgress,
    required this.focusHoursProgress,
    this.harmonyPercentage = 84,
    this.size = 170,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _TripleRingsPainter(
              missionsProgress: missionsProgress,
              habitsProgress: habitsProgress,
              focusHoursProgress: focusHoursProgress,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$harmonyPercentage',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: size * 0.2,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    '%',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: size * 0.11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkOnSurface,
                    ),
                  ),
                ],
              ),
              Text(
                'harmony',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: size * 0.075,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkOutline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TripleRingsPainter extends CustomPainter {
  final double missionsProgress;
  final double habitsProgress;
  final double focusHoursProgress;

  _TripleRingsPainter({
    required this.missionsProgress,
    required this.habitsProgress,
    required this.focusHoursProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.065;
    final space = strokeWidth * 1.35;

    final outerRadius = (size.width / 2) - (strokeWidth / 2);
    final middleRadius = outerRadius - space;
    final innerRadius = middleRadius - space;

    final trackPaint = Paint()
      ..color = AppColors.darkSurfaceContainerHighest.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background tracks
    canvas.drawCircle(center, outerRadius, trackPaint);
    canvas.drawCircle(center, middleRadius, trackPaint);
    canvas.drawCircle(center, innerRadius, trackPaint);

    // Outer Ring: Missions (Primary Cyan-Blue)
    final outerArcPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      -pi / 2,
      2 * pi * missionsProgress.clamp(0.0, 1.0),
      false,
      outerArcPaint,
    );

    // Middle Ring: Habits (Emerald Green)
    final middleArcPaint = Paint()
      ..color = AppColors.successEmerald
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: middleRadius),
      -pi / 2,
      2 * pi * habitsProgress.clamp(0.0, 1.0),
      false,
      middleArcPaint,
    );

    // Inner Ring: Focus Hours (Tertiary Coral Amber)
    final innerArcPaint = Paint()
      ..color = AppColors.tertiary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      -pi / 2,
      2 * pi * focusHoursProgress.clamp(0.0, 1.0),
      false,
      innerArcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TripleRingsPainter oldDelegate) {
    return oldDelegate.missionsProgress != missionsProgress ||
        oldDelegate.habitsProgress != habitsProgress ||
        oldDelegate.focusHoursProgress != focusHoursProgress;
  }
}
