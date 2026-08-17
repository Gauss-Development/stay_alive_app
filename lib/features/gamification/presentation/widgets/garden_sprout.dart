import 'package:flutter/material.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/widgets/animations/green_sprout_rive.dart';
import 'package:stay_alive/features/gamification/domain/entities/garden_state.dart';

/// Live garden sprout driven by [GardenState] (scale, wilt tint, bloom glow).
class GardenSprout extends StatelessWidget {
  const GardenSprout({
    required this.state,
    this.size = 96,
    this.showWiltingHint = true,
    super.key,
  });

  final GardenState state;
  final double size;
  final bool showWiltingHint;

  @override
  Widget build(BuildContext context) {
    final Color glow = state.wilting
        ? AppColors.softYellow
        : state.stage == GardenStage.bloom
            ? AppColors.lime
            : AppColors.green;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AnimatedScale(
          scale: state.displayScale,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutBack,
          child: ColorFiltered(
            colorFilter: state.wilting
                ? const ColorFilter.matrix(<double>[
                    0.85, 0.1, 0, 0, 12,
                    0.05, 0.75, 0.05, 0, 0,
                    0, 0.1, 0.55, 0, 0,
                    0, 0, 0, 1, 0,
                  ])
                : const ColorFilter.matrix(<double>[
                    1, 0, 0, 0, 0,
                    0, 1, 0, 0, 0,
                    0, 0, 1, 0, 0,
                    0, 0, 0, 1, 0,
                  ]),
            child: GreenSproutRiveEmblem(
              size: size,
              glowColor: glow,
              replayKey: (state.todayGrowth * 100).round() + state.level * 10,
              wilting: state.wilting,
            ),
          ),
        ),
        if (showWiltingHint && state.wilting) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            'Ростку нужна забота сегодня',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.softYellow,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
