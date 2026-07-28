import 'package:flutter/material.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';

enum StreakChipStyle { compact, header }

/// Small «🔥 N дней» streak indicator.
class StreakChip extends StatelessWidget {
  const StreakChip({
    required this.streak,
    this.style = StreakChipStyle.header,
    super.key,
  });

  final int streak;
  final StreakChipStyle style;

  @override
  Widget build(BuildContext context) {
    if (streak == 0) {
      return const SizedBox.shrink();
    }

    final bool isHeader = style == StreakChipStyle.header;
    final Color textColor = isHeader
        ? AppColors.textMuted
        : AppColors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(
          Icons.local_fire_department_rounded,
          size: 14,
          color: AppColors.orange,
        ),
        const SizedBox(width: 4),
        Text(
          '$streak ${_daysLabel(streak)}',
          style: AppTextStyles.labelMedium.copyWith(color: textColor),
        ),
      ],
    );
  }

  static String _daysLabel(int count) {
    final int mod10 = count % 10;
    final int mod100 = count % 100;
    if (mod100 >= 11 && mod100 <= 14) {
      return 'дней';
    }
    if (mod10 == 1) {
      return 'день';
    }
    if (mod10 >= 2 && mod10 <= 4) {
      return 'дня';
    }
    return 'дней';
  }
}
