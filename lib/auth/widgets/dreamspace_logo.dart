import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// SVG-like logo drawn with CustomPainter to avoid asset dependency.
/// Replace with SvgPicture.asset() when you have the real SVG.
class DreamSpaceLogo extends StatelessWidget {
  const DreamSpaceLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Building icon
        SizedBox(
          width: 44,
          height: 44,
          child: CustomPaint(painter: _LogoPainter()),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'DreamSpace',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                height: 1,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'REAL ESTATE',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Left tall building
    final left = Path()
      ..moveTo(w * 0.12, h * 0.85)
      ..lineTo(w * 0.12, h * 0.25)
      ..lineTo(w * 0.32, h * 0.12)
      ..lineTo(w * 0.32, h * 0.85);
    canvas.drawPath(left, paint);

    // Center taller building
    final center = Path()
      ..moveTo(w * 0.32, h * 0.85)
      ..lineTo(w * 0.32, h * 0.18)
      ..lineTo(w * 0.52, h * 0.05)
      ..lineTo(w * 0.52, h * 0.85);
    canvas.drawPath(center, paint);

    // Right building
    final right = Path()
      ..moveTo(w * 0.52, h * 0.85)
      ..lineTo(w * 0.52, h * 0.28)
      ..lineTo(w * 0.72, h * 0.18)
      ..lineTo(w * 0.72, h * 0.85);
    canvas.drawPath(right, paint);

    // Base line
    canvas.drawLine(
      Offset(w * 0.08, h * 0.85),
      Offset(w * 0.78, h * 0.85),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
