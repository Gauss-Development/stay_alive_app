import 'package:flutter/material.dart';

class StreakChip extends StatelessWidget {
  const StreakChip({required this.streak, super.key});

  final int streak;

  @override
  Widget build(BuildContext context) {
    if (streak == 0) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(
          Icons.local_fire_department_rounded,
          size: 13,
          color: Colors.orange,
        ),
        const SizedBox(width: 4),
        Text(
          '$streak day${streak == 1 ? '' : 's'}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
