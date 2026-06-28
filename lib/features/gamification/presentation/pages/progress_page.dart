import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_cubit.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_state.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/badge_gallery.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/badge_list.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/category_mastery_list.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/daily_challenge_card.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/xp_event_timeline.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/xp_level_bar.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final GamificationState state = context.read<GamificationCubit>().state;
        if (state is! GamificationLoaded) {
          context.read<GamificationCubit>().load();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: BlocBuilder<GamificationCubit, GamificationState>(
          builder: (BuildContext context, GamificationState state) {
            if (state is GamificationInitial || state is GamificationLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is GamificationError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () =>
                            context.read<GamificationCubit>().load(),
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is! GamificationLoaded) {
              return const SizedBox.shrink();
            }

            final overview = state.overview;
            final profile = overview.profile;

            return RefreshIndicator(
              onRefresh: () => context.read<GamificationCubit>().refresh(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  Text(
                    '${profile.currentLevel.title} · Level ${profile.currentLevel.level}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  XpLevelBar(profile: profile),
                  const SizedBox(height: 16),
                  DailyChallengeCard(challenge: overview.dailyChallenge),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Streaks',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _InfoChip(
                          label: 'Perfect streak',
                          value: '${profile.currentStreak}',
                        ),
                        _InfoChip(
                          label: 'Active streak',
                          value: '${profile.activityStreak}',
                        ),
                        _InfoChip(
                          label: 'Best streak',
                          value: '${profile.longestStreak}',
                        ),
                        _InfoChip(
                          label: 'Perfect days',
                          value: '${profile.completedDates.length}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Badge Gallery',
                    child: BadgeGallery(items: overview.badgeGallery),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Recent Badges',
                    child: BadgeList(badges: profile.earnedBadges),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Category Mastery',
                    child: CategoryMasteryList(items: overview.categoryMastery),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'XP Activity',
                    child: XpEventTimeline(events: overview.recentXpEvents),
                  ),
                ],
              ),
            );
          },
        ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}
