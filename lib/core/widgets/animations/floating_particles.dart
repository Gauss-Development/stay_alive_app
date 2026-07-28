import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stay_alive/core/motion/motion_config.dart';
import 'package:stay_alive/core/theme/app_colors.dart';

/// Slow decorative particles drifting upwards — for the reward / level-up
/// background and the auth hero only.
///
/// One repeating [AnimationController], a fixed particle set generated once,
/// and a [RepaintBoundary] keep it cheap. Renders a static frame under
/// reduced motion.
class FloatingParticles extends StatefulWidget {
  const FloatingParticles({
    this.count = 22,
    this.colors = const <Color>[
      AppColors.lime,
      AppColors.mutedGreen,
      AppColors.softYellow,
      AppColors.blue,
    ],
    super.key,
  });

  final int count;
  final List<Color> colors;

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  );
  late final List<_Particle> _particles;
  bool _configured = false;

  @override
  void initState() {
    super.initState();
    final math.Random rng = math.Random(7);
    _particles = List<_Particle>.generate(widget.count, (int i) {
      return _Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        speed: 0.35 + rng.nextDouble() * 0.65,
        drift: (rng.nextDouble() - 0.5) * 0.06,
        phase: rng.nextDouble() * math.pi * 2,
        size: 2 + rng.nextDouble() * 4,
        opacity: 0.2 + rng.nextDouble() * 0.5,
        color: widget.colors[i % widget.colors.length],
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_configured) {
      return;
    }
    _configured = true;
    if (!MotionConfig.reduceMotionOf(context)) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _ParticlesPainter(
            particles: _particles,
            animation: _controller,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _Particle {
  const _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.drift,
    required this.phase,
    required this.size,
    required this.opacity,
    required this.color,
  });

  final double x;
  final double y;
  final double speed;
  final double drift;
  final double phase;
  final double size;
  final double opacity;
  final Color color;
}

class _ParticlesPainter extends CustomPainter {
  _ParticlesPainter({required this.particles, required this.animation})
    : super(repaint: animation);

  final List<_Particle> particles;
  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    final double t = animation.value;

    for (final _Particle p in particles) {
      // Vertical drift upwards with wraparound, gentle horizontal sway.
      final double y = (p.y - t * p.speed) % 1;
      final double x = p.x + p.drift * math.sin(t * math.pi * 2 + p.phase);

      paint.color = p.color.withValues(alpha: p.opacity);
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        p.size / 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter oldDelegate) =>
      oldDelegate.particles != particles;
}
