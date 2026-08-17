import 'package:flutter/material.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';

/// Small pill badge with an accent dot — points, tags, statuses.
class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label,
    this.accent = AppColors.lime,
    this.onDark = false,
    this.showDot = true,
    super.key,
  });

  final String label;
  final Color accent;

  /// Set when the badge sits on a dark panel.
  final bool onDark;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: onDark ? AppColors.darkChip : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (showDot) ...<Widget>[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
            const SizedBox(width: 7),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMedium.copyWith(
                color: onDark ? accent : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
