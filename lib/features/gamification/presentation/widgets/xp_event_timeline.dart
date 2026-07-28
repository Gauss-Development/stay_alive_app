import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_xp_event.dart';

class XpEventTimeline extends StatelessWidget {
  const XpEventTimeline({required this.events, super.key});

  final List<GamificationXpEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Text(
          'Здесь появится история твоих очков.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      separatorBuilder: (BuildContext context, int index) =>
          const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final GamificationXpEvent event = events[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      event.label,
                      style: AppTextStyles.bodyLarge.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat(
                        'd.MM.yyyy · HH:mm',
                      ).format(event.createdAt.toLocal()),
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                event.xpDelta > 0 ? '+${event.xpDelta}' : '—',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.green,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
