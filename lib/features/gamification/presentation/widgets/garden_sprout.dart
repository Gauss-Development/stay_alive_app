import 'package:flutter/material.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/widgets/sprout_image.dart';
import 'package:stay_alive/features/gamification/domain/entities/garden_state.dart';

/// Live garden sprout driven by [GardenState] (scale + mood artwork).
///
/// The sprout never wilts or gets punished: an untouched day just makes it
/// look up expectantly (GAU-416). Mood here is a temporary projection of
/// [GardenState]; the full v2 loop (missed_you on return, week 5/7) will move
/// this into the domain.
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

  SproutMood _moodFor(GardenState state) {
    final int hour = DateTime.now().hour;
    if (hour >= 22 || hour < 6) {
      return SproutMood.sleeping;
    }
    if (state.todayGrowth >= 1.0) {
      return SproutMood.cheer;
    }
    if (state.wilting || state.todayGrowth == 0) {
      return SproutMood.curious;
    }
    return SproutMood.happy;
  }

  /// Visual boost over the layout box: the artwork paints larger than the
  /// reserved [size] (via [OverflowBox]) so the card never grows with it.
  static const double _visualBoost = 2.2;

  @override
  Widget build(BuildContext context) {
    final SproutMood mood = _moodFor(state);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: size,
          height: size,
          child: OverflowBox(
            maxWidth: size * _visualBoost * 1.2,
            maxHeight: size * _visualBoost * 1.2,
            child: AnimatedScale(
              scale: state.displayScale * _visualBoost,
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutBack,
              child: SproutImage(mood: mood, size: size),
            ),
          ),
        ),
        if (showWiltingHint && state.wilting) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            'Росток ждёт тебя сегодня',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.green,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
