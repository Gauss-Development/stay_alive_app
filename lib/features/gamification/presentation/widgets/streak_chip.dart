import 'package:flutter/material.dart';

enum StreakChipStyle {
  compact,
  header,
}

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

    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool isHeader = style == StreakChipStyle.header;
    final Color textColor = isHeader ? Colors.white70 : colors.onSurfaceVariant;
    final Color iconColor = isHeader ? Colors.orange : colors.tertiary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.local_fire_department_rounded,
          size: 13,
          color: iconColor,
        ),
        const SizedBox(width: 4),
        Text(
          '$streak day${streak == 1 ? '' : 's'}',
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
