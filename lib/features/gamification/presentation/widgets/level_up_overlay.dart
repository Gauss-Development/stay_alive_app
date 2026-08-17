import 'package:flutter/material.dart';
import 'package:stay_alive/core/motion/app_curves.dart';
import 'package:stay_alive/core/motion/motion_config.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/animations/fade_slide_in.dart';
import 'package:stay_alive/core/widgets/animations/floating_particles.dart';
import 'package:stay_alive/core/widgets/animations/pressable_scale.dart';
import 'package:stay_alive/core/widgets/animations/reward_burst.dart';
import 'package:stay_alive/core/widgets/animations/scale_pop.dart';
import 'package:stay_alive/core/widgets/animations/sprout_growth_animation.dart';
import 'package:stay_alive/core/widgets/app_badge.dart';
import 'package:stay_alive/core/widgets/app_button.dart';
import 'package:stay_alive/features/gamification/domain/entities/game_level.dart';

/// Dark, emotional level-up celebration.
///
/// Sequence: floating particles drift in the background → badge pops →
/// the sprout grows → title and level bounce in → a short radial burst →
/// the lime CTA slides up from the bottom.
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (MotionConfig.reduceMotionOf(context)) {
      _reveal.value = 1;
    } else {
      _reveal.forward();
    }
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MotionConfig.reduceMotionOf(context);

    return FadeTransition(
      opacity: CurvedAnimation(parent: _reveal, curve: AppCurves.standard),
      child: ColoredBox(
        color: AppColors.dark,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (!reduceMotion)
              const Positioned.fill(child: FloatingParticles()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const ScalePop(
                                delay: Duration(milliseconds: 150),
                                child: AppBadge(
                                  label: 'НОВЫЙ УРОВЕНЬ',
                                  onDark: true,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              _buildSproutHero(),
                              const SizedBox(height: AppSpacing.xl),
                              FadeSlideIn(
                                delay: const Duration(milliseconds: 650),
                                child: Text(
                                  'Уровень ${widget.level.level}',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.headlineLarge.copyWith(
                                    color: AppColors.white,
                                    fontSize: 44,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              ScalePop(
                                delay: const Duration(milliseconds: 850),
                                duration: const Duration(milliseconds: 500),
                                curve: reduceMotion
                                    ? AppCurves.standard
                                    : AppCurves.bounce,
                                fromScale: 0.7,
                                child: Text(
                                  widget.level.title,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.points,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              FadeSlideIn(
                                delay: const Duration(milliseconds: 1050),
                                child: Text(
                                  'Твой росток стал ещё сильнее',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 1150),
                      offset: 24,
                      child: PressableScale(
                        child: AppButton(
                          text: 'Продолжить',
                          variant: AppButtonVariant.lime,
                          onPressed: widget.onDismiss,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSproutHero() {
    return SizedBox(
      width: 220,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Short premium burst timed to the level reveal.
          const RewardBurst(size: 220, delay: Duration(milliseconds: 750)),
          ScalePop(
            delay: const Duration(milliseconds: 300),
            fromScale: 0.8,
            child: Container(
              width: 132,
              height: 132,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.lime.withValues(alpha: 0.25),
                    blurRadius: 44,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: const SproutGrowthAnimation(
                size: 76,
                delay: Duration(milliseconds: 450),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
