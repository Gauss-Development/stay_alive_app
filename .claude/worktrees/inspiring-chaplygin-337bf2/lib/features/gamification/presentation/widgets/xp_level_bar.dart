import 'package:flutter/material.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';

class XpLevelBar extends StatelessWidget {
  const XpLevelBar({required this.profile, this.dark = false, super.key});

  final UserGameProfile profile;

  /// True when displayed inside the dark green header.
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final level = profile.currentLevel;
    final double progress = level.progressFraction(profile.totalXp);
    final Color labelColor = dark ? Colors.white70 : const Color(0xFF5A7A65);
    final Color barBg =
        dark ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFDDE8E0);
    final Color barFill = dark ? Colors.white : const Color(0xFF2E7D65);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Lv ${level.level} · ${level.title}',
              style: TextStyle(
                color: labelColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              level.isMaxLevel
                  ? 'MAX'
                  : '${profile.totalXp} / ${level.xpForNext} XP',
              style: TextStyle(
                color: labelColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: progress),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (BuildContext _, double value, Widget? child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: barBg,
                valueColor: AlwaysStoppedAnimation<Color>(barFill),
              ),
            );
          },
        ),
      ],
    );
  }
}
