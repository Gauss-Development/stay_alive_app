import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_xp_event.dart';

class XpEventTimeline extends StatelessWidget {
  const XpEventTimeline({
    required this.events,
    super.key,
  });

  final List<GamificationXpEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'XP events will appear here as you progress.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(event.label),
          subtitle: Text(
            DateFormat('MMM d, yyyy · HH:mm').format(event.createdAt.toLocal()),
          ),
          trailing: Text(
            event.xpDelta > 0 ? '+${event.xpDelta} XP' : '—',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      },
    );
  }
}
