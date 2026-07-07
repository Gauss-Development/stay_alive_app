import 'package:flutter/material.dart';
import 'package:stay_alive/features/rostok/presentation/theme/rostok_colors.dart';

/// Soft diagonal-hatch fill used for placeholder blocks, avatars and food-icon
/// tiles, mirroring the mockup's repeating 45° stripe pattern.
class RostokHatch extends StatelessWidget {
  const RostokHatch({
    this.baseColor = RostokColors.hatch,
    this.stripeColor = const Color(0x2996AF78),
    this.spacing = 12,
    this.child,
    super.key,
  });

  final Color baseColor;
  final Color stripeColor;
  final double spacing;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HatchPainter(
        baseColor: baseColor,
        stripeColor: stripeColor,
        spacing: spacing,
      ),
      child: child ?? const SizedBox.expand(),
    );
  }
}

class _HatchPainter extends CustomPainter {
  _HatchPainter({
    required this.baseColor,
    required this.stripeColor,
    required this.spacing,
  });

  final Color baseColor;
  final Color stripeColor;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = baseColor);

    final Paint stripe = Paint()
      ..color = stripeColor
      ..strokeWidth = spacing * 0.55
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.clipRect(rect);
    for (double x = -size.height; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        stripe,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HatchPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor ||
        oldDelegate.stripeColor != stripeColor ||
        oldDelegate.spacing != spacing;
  }
}
