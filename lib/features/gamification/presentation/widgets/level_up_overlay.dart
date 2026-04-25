import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stay_alive/features/gamification/domain/entities/game_level.dart';

class LevelUpOverlay extends StatefulWidget {
  const LevelUpOverlay({
    required this.level,
    required this.onDismiss,
    super.key,
  });

  final GameLevel level;
  final VoidCallback onDismiss;

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _revealController;
  late final AnimationController _particleController;
  late final Animation<double> _revealAnim;
  late final List<_Particle> _particles;

  static const _kParticleCount = 60;
  static const _kColors = <Color>[
    Color(0xFF2E7D65),
    Color(0xFF8CBF93),
    Color(0xFFFFD700),
    Color(0xFFFFFFFF),
    Color(0xFFFF8A65),
  ];

  @override
  void initState() {
    super.initState();

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _revealAnim = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutExpo,
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    final rng = math.Random();
    _particles = List<_Particle>.generate(_kParticleCount, (_) {
      return _Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble() * -0.5 - 0.1,
        vx: (rng.nextDouble() - 0.5) * 0.3,
        vy: rng.nextDouble() * 0.3 + 0.1,
        rotation: rng.nextDouble() * math.pi * 2,
        rotationSpeed: (rng.nextDouble() - 0.5) * math.pi * 4,
        color: _kColors[rng.nextInt(_kColors.length)],
        size: rng.nextDouble() * 8 + 5,
      );
    });

    _revealController.forward();
    _particleController.repeat();
  }

  @override
  void dispose() {
    _revealController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: Listenable.merge(
        <Listenable>[_revealAnim, _particleController],
      ),
      builder: (BuildContext context, Widget? _) {
        final double revealFraction = _revealAnim.value;
        final double particleFraction = _particleController.value;

        return Stack(
          children: <Widget>[
            // Radial reveal
            CustomPaint(
              size: size,
              painter: _RadialRevealPainter(fraction: revealFraction),
            ),
            // Confetti
            if (revealFraction > 0.4)
              CustomPaint(
                size: size,
                painter: _ParticlePainter(
                  particles: _particles,
                  t: particleFraction,
                  screenSize: size,
                ),
              ),
            // Content
            if (revealFraction > 0.7)
              SafeArea(
                child: Center(
                  child: Opacity(
                    opacity: ((revealFraction - 0.7) / 0.3).clamp(0.0, 1.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text(
                          '🎉',
                          style: TextStyle(fontSize: 64),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'LEVEL UP!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Level ${widget.level.level}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            height: 1,
                            letterSpacing: -2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.level.title,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 40),
                        FilledButton(
                          onPressed: widget.onDismiss,
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.2),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(200, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                          child: const Text(
                            'Keep it up!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── Painters ─────────────────────────────────────────────────────────────────

class _RadialRevealPainter extends CustomPainter {
  const _RadialRevealPainter({required this.fraction});

  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    if (fraction <= 0) return;
    final double maxRadius =
        math.sqrt(size.width * size.width + size.height * size.height);
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      maxRadius * fraction,
      Paint()..color = const Color(0xFF1A3D2E),
    );
  }

  @override
  bool shouldRepaint(_RadialRevealPainter old) => old.fraction != fraction;
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.size,
  });

  final double x;
  final double y;
  final double vx;
  final double vy;
  final double rotation;
  final double rotationSpeed;
  final Color color;
  final double size;
}

class _ParticlePainter extends CustomPainter {
  const _ParticlePainter({
    required this.particles,
    required this.t,
    required this.screenSize,
  });

  final List<_Particle> particles;
  final double t;
  final Size screenSize;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    const double gravity = 0.4;

    for (final _Particle p in particles) {
      final double px = (p.x + p.vx * t) * size.width;
      final double py =
          (p.y + p.vy * t + gravity * t * t) * size.height;

      if (py > size.height + 20) continue;

      final double angle = p.rotation + p.rotationSpeed * t;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(angle);
      paint.color = p.color.withValues(alpha: (1.0 - t * 0.5).clamp(0.0, 1.0));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.5,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}
