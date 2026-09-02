import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stay_alive/core/constants/app_routes.dart';
import 'package:stay_alive/core/l10n/l10n.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/animations/fade_slide_in.dart';
import 'package:stay_alive/core/widgets/animations/scale_pop.dart';
import 'package:stay_alive/core/widgets/app_button.dart';
import 'package:stay_alive/core/widgets/app_card.dart';
import 'package:stay_alive/core/widgets/app_icon_button.dart';
import 'package:stay_alive/core/widgets/app_section_header.dart';
import 'package:stay_alive/core/widgets/app_states.dart';
import 'package:stay_alive/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:stay_alive/features/coach/domain/services/coach_context_builder.dart';
import 'package:stay_alive/features/coach/presentation/cubit/coach_cubit.dart';
import 'package:stay_alive/features/coach/presentation/cubit/coach_state.dart';
import 'package:stay_alive/features/coach/presentation/widgets/weekly_insight_section.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_cubit.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_cubit.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_state.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/badge_gallery.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/badge_list.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/category_mastery_list.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/daily_challenge_card.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/xp_event_timeline.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/xp_level_bar.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_cubit.dart';

/// «Челленджи» — quests, streaks, achievements and XP history.
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
        final bool isPremium = context
            .read<SubscriptionCubit>()
            .state
            .isPremiumActive;
        if (state is! GamificationLoaded) {
          context.read<GamificationCubit>().load(isPremium: isPremium);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<GamificationCubit, GamificationState>(
          builder: (BuildContext context, GamificationState state) {
            if (state is GamificationInitial || state is GamificationLoading) {
              return AppLoadingState(message: context.l10n.progressLoading);
            }

            if (state is GamificationError) {
              return AppErrorState(
                onRetry: () {
                  final bool isPremium = context
                      .read<SubscriptionCubit>()
                      .state
                      .isPremiumActive;
                  context.read<GamificationCubit>().load(isPremium: isPremium);
                },
              );
            }

            if (state is! GamificationLoaded) {
              return const SizedBox.shrink();
            }

            final overview = state.overview;
            final profile = overview.profile;

            return RefreshIndicator(
              color: AppColors.green,
              onRefresh: () {
                final bool isPremium = context
                    .read<SubscriptionCubit>()
                    .state
                    .isPremiumActive;
                return context.read<GamificationCubit>().refresh(
                  isPremium: isPremium,
                );
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.sm,
                  AppSpacing.screen,
                  AppSpacing.xl,
                ),
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      AppIconButton(
                        icon: Icons.chevron_left_rounded,
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRoutes.home);
                          }
                        },
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            context.l10n.progressTitle,
                            style: context.text.titleLarge,
                          ),
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ScalePop(
                    delay: const Duration(milliseconds: 60),
                    fromScale: 0.96,
                    child: DailyChallengeCard(
                      challenge: overview.weeklyChallenge,
                      isPremium: overview.isPremium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 180),
                    child: AppSectionHeader(
                      title: context.l10n.progressSectionDaily,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 240),
                    child: DailyChallengeCard(
                      challenge: overview.dailyChallenge,
                      isPremium: overview.isPremium,
                    ),
                  ),
                  if (overview.isPremium) ...<Widget>[
                    const SizedBox(height: AppSpacing.md),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 260),
                      child: _PersonalizedQuestBlock(),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 280),
                    child: WeeklyInsightSection(
                      onRequestInsights: () => _requestWeeklyInsights(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 320),
                    child: AppCard(
                      radius: AppRadius.xl,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          XpLevelBar(profile: profile),
                          if (overview.isPremium) ...<Widget>[
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              context.l10n.progressPremiumActive(
                                overview.xpMultiplier,
                              ),
                              style: context.text.labelMedium?.copyWith(
                                color: AppColors.green,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: <Widget>[
                              _StreakStat(
                                label: context.l10n.progressStreakPerfect,
                                value: '${profile.currentStreak}',
                              ),
                              _StreakStat(
                                label: context.l10n.progressStreakActive,
                                value: '${profile.activityStreak}',
                              ),
                              _StreakStat(
                                label: context.l10n.progressStreakRecord,
                                value: '${profile.longestStreak}',
                              ),
                              _StreakStat(
                                label: context.l10n.progressPerfectDays,
                                value: '${profile.completedDates.length}',
                              ),
                              _StreakStat(
                                label: context.l10n.progressStreakFreezes,
                                value: '${profile.streakFreezesRemaining}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 380),
                    child: AppSectionHeader(
                      title: context.l10n.progressSectionAchievements,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 420),
                    child: BadgeGallery(items: overview.badgeGallery),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppSectionHeader(
                    title: context.l10n.progressSectionRecentBadges,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(child: BadgeList(badges: profile.earnedBadges)),
                  const SizedBox(height: AppSpacing.xl),
                  AppSectionHeader(
                    title: context.l10n.progressSectionCategories,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  CategoryMasteryList(items: overview.categoryMastery),
                  const SizedBox(height: AppSpacing.xl),
                  AppSectionHeader(
                    title: context.l10n.progressSectionXpHistory,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    child: XpEventTimeline(events: overview.recentXpEvents),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _requestWeeklyInsights(BuildContext context) async {
    final bool isPremium =
        context.read<SubscriptionCubit>().state.isPremiumActive;
    final gState = context.read<GamificationCubit>().state;
    await context.read<CoachCubit>().loadWeeklyInsights(
          context: CoachContextBuilder.build(
            overview: gState is GamificationLoaded ? gState.overview : null,
            todayLog: context.read<DailyTrackerCubit>().state.log,
          ),
          isPremium: isPremium,
        );
    if (!context.mounted) {
      return;
    }
    await context.read<AnalyticsCubit>().track(
          eventName: 'coach_weekly_insight',
          screenName: 'progress',
        );
  }
}

class _PersonalizedQuestBlock extends StatelessWidget {
  const _PersonalizedQuestBlock();

  @override
  Widget build(BuildContext context) {
    final bool hasAiDaily = context
            .watch<GamificationCubit>()
            .aiDailyDraft !=
        null;
    if (hasAiDaily) {
      final overview = context.watch<GamificationCubit>().state;
      if (overview is GamificationLoaded) {
        return DailyChallengeCard(
          challenge: overview.overview.dailyChallenge,
          isPremium: true,
        );
      }
    }

    return AppButton(
      text: context.l10n.progressGenerateQuest,
      onPressed: () async {
        final bool isPremium =
            context.read<SubscriptionCubit>().state.isPremiumActive;
        final gState = context.read<GamificationCubit>().state;
        final log = context.read<DailyTrackerCubit>().state.log;
        await context.read<CoachCubit>().personalizeChallenge(
              context: CoachContextBuilder.build(
                overview: gState is GamificationLoaded ? gState.overview : null,
                todayLog: log,
              ),
              isPremium: isPremium,
            );
        if (!context.mounted) {
          return;
        }
        final coachState = context.read<CoachCubit>().state;
        final draft =
            coachState is CoachLoaded ? coachState.challengeDraft : null;
        if (draft == null) {
          return;
        }
        context.read<GamificationCubit>().setAiDailyDraft(draft);
        if (log != null) {
          await context.read<GamificationCubit>().refreshToday(
                todayLog: log,
                isPremium: isPremium,
              );
        }
        if (context.mounted) {
          await context.read<AnalyticsCubit>().track(
                eventName: 'coach_personalize_challenge',
                screenName: 'progress',
              );
        }
      },
    );
  }
}

class _StreakStat extends StatelessWidget {
  const _StreakStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        // Inset pill on top of a card: the chip role, not `surface` — in the
        // dark theme `surface` is the card colour and the pill would vanish.
        color: Theme.of(context).chipTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(value, style: context.text.labelLarge?.copyWith(fontSize: 13)),
          const SizedBox(width: 6),
          Text(label, style: context.text.labelMedium),
        ],
      ),
    );
  }
}
