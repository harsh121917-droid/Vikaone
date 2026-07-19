import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DreamSpaceLogo extends StatelessWidget {
  const DreamSpaceLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 44, height: 44, child: CustomPaint(painter: _LogoPainter())),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('DreamSpace', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3, height: 1)),
            SizedBox(height: 2),
            Text('REAL ESTATE', style: TextStyle(color: AppColors.textSecondary, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 2.5)),
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
    final w = size.width; final h = size.height;
    canvas.drawPath(Path()..moveTo(w*.12,h*.85)..lineTo(w*.12,h*.25)..lineTo(w*.32,h*.12)..lineTo(w*.32,h*.85), paint);
    canvas.drawPath(Path()..moveTo(w*.32,h*.85)..lineTo(w*.32,h*.18)..lineTo(w*.52,h*.05)..lineTo(w*.52,h*.85), paint);
    canvas.drawPath(Path()..moveTo(w*.52,h*.85)..lineTo(w*.52,h*.28)..lineTo(w*.72,h*.18)..lineTo(w*.72,h*.85), paint);
    canvas.drawLine(Offset(w*.08,h*.85), Offset(w*.78,h*.85), paint);
  }
  @override bool shouldRepaint(covariant CustomPainter o) => false;
}
