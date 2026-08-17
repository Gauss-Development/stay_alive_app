import 'package:flutter/material.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/app_progress_bar.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';

/// Level progress bar: «До уровня N» + lime fill.
class XpLevelBar extends StatelessWidget {
  const XpLevelBar({required this.profile, this.dark = false, super.key});

  final UserGameProfile profile;

  /// True when displayed inside a dark panel.
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final level = profile.currentLevel;
    final double progress = level.progressFraction(profile.totalXp);
    final Color labelColor = dark
        ? AppColors.textMuted
        : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Text(
                'Уровень ${level.level} · ${level.title}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelMedium.copyWith(
                  color: dark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              level.isMaxLevel
                  ? 'MAX'
                  : '${profile.totalXp} / ${level.xpForNext}',
              style: AppTextStyles.labelMedium.copyWith(color: labelColor),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppProgressBar(
          value: progress,
          height: 10,
          backgroundColor: dark ? AppColors.darkChip : AppColors.border,
        ),
      ],
    );
  }
}
