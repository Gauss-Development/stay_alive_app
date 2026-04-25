import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stay_alive/features/gamification/domain/entities/badge.dart';

class BadgeList extends StatelessWidget {
  const BadgeList({required this.badges, super.key});

  final List<EarnedBadge> badges;

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'No badges yet — keep going!',
          style: TextStyle(
            color: const Color(0xFF2E7D65).withValues(alpha: 0.5),
            fontSize: 13,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: badges.length,
      separatorBuilder: (BuildContext context, int index) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        return _BadgeTile(badge: badges[index]);
      },
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});

  final EarnedBadge badge;

  @override
  Widget build(BuildContext context) {
    final def = badge.definition;
    final String dateStr = DateFormat('MMM d, yyyy').format(badge.earnedAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D65).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                def.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  def.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A3D2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  def.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A9E8A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            dateStr,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFAEC5B5),
            ),
          ),
        ],
      ),
    );
  }
}
