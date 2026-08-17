import 'package:flutter/material.dart';

/// Soft diagonal-stripe fill — the signature «Росток» decorative texture.
///
/// Used on the auth hero card, reward-shop tiles and achievement decorations.
/// Rendered with a [CustomPainter], no image assets.
class DiagonalPattern extends StatelessWidget {
  const DiagonalPattern({
    required this.background,
    required this.lineColor,
    this.child,
    this.borderRadius,
    this.spacing = 18,
    this.strokeWidth = 5,
    super.key,
  });

  final Color background;
  final Color lineColor;
  final Widget? child;
  final BorderRadius? borderRadius;
  final double spacing;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final Widget content = CustomPaint(
      painter: DiagonalPatternPainter(
        background: background,
        lineColor: lineColor,
        spacing: spacing,
        strokeWidth: strokeWidth,
      ),
      child: child ?? const SizedBox.expand(),
    );

    if (borderRadius == null) {
      return content;
    }

    return ClipRRect(borderRadius: borderRadius!, child: content);
  }
}

class DiagonalPatternPainter extends CustomPainter {
  DiagonalPatternPainter({
    required this.background,
    required this.lineColor,
    this.spacing = 18,
    this.strokeWidth = 5,
  });

  final Color background;
  final Color lineColor;
  final double spacing;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = background);

    final Paint linePaint = Paint()
      ..color = lineColor.withValues(alpha: 0.35)
      ..strokeWidth = strokeWidth;

    canvas.save();
    canvas.clipRect(rect);
    for (double x = -size.height; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        linePaint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DiagonalPatternPainter oldDelegate) {
    return oldDelegate.background != background ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.spacing != spacing ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
