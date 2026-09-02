import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stay_alive/core/constants/app_routes.dart';
import 'package:stay_alive/core/constants/legal_urls.dart';
import 'package:stay_alive/features/user/presentation/widgets/settings_menu.dart';
import 'package:stay_alive/core/l10n/l10n.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/animations/animated_points_counter.dart';
import 'package:stay_alive/core/widgets/animations/fade_slide_in.dart';
import 'package:stay_alive/core/widgets/animations/scale_pop.dart';
import 'package:stay_alive/core/widgets/animations/staggered_list.dart';
import 'package:stay_alive/core/widgets/app_card.dart';
import 'package:stay_alive/core/widgets/app_progress_bar.dart';
import 'package:stay_alive/core/widgets/app_section_header.dart';
import 'package:stay_alive/core/widgets/app_states.dart';
import 'package:stay_alive/features/gamification/domain/entities/game_level.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_overview.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_cubit.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_state.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/badge_gallery.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:stay_alive/features/user/presentation/cubit/user_profile_cubit.dart';
import 'package:stay_alive/features/user/presentation/cubit/user_profile_state.dart';
import 'package:url_launcher/url_launcher.dart';

/// Profile as a progress screen: avatar + level, stat cards, level progress,
/// achievements and weekly activity.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<UserProfileCubit>().load();
      if (context.read<GamificationCubit>().state is! GamificationLoaded) {
        final bool isPremium = context
            .read<SubscriptionCubit>()
            .state
            .isPremiumActive;
        context.read<GamificationCubit>().load(isPremium: isPremium);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<UserProfileCubit, UserProfileState>(
          builder: (BuildContext context, UserProfileState state) {
            if (state is UserProfileLoading || state is UserProfileInitial) {
              return const AppLoadingState();
            }
            if (state is UserProfileError) {
              return AppErrorState(
                onRetry: () => context.read<UserProfileCubit>().load(),
              );
            }
            if (state is! UserProfileLoaded) {
              return const SizedBox.shrink();
            }

            final String displayName = state.profile.displayName;
            final String email = state.profile.email;

            return BlocBuilder<GamificationCubit, GamificationState>(
              builder:
                  (BuildContext context, GamificationState gamificationState) {
                    final GamificationOverview? overview =
                        gamificationState is GamificationLoaded
                        ? gamificationState.overview
                        : null;
                    final UserGameProfile profile =
                        overview?.profile ?? const UserGameProfile.empty();

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screen,
                        AppSpacing.sm,
                        AppSpacing.screen,
                        AppSpacing.xl,
                      ),
                      children: <Widget>[
                        FadeSlideIn(
                          child: Center(
                            child: Text(
                              context.l10n.navProfile,
                              style: context.text.titleLarge,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        ScalePop(
                          delay: const Duration(milliseconds: 80),
                          fromScale: 0.85,
                          child: _ProfileAvatar(
                            profile: profile,
                            name: displayName,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _StatsRow(profile: profile),
                        const SizedBox(height: AppSpacing.md),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 380),
                          child: _LevelProgressCard(profile: profile),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 450),
                          child: _AchievementsSection(overview: overview),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 520),
                          child: _WeeklyActivityCard(profile: profile),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppCard(
                          onTap: () => context.push(AppRoutes.progress),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: AppColors.lime,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.flag_rounded,
                                  size: 20,
                                  color: context.colors.onTertiary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      context.l10n.profileChallengesTitle,
                                      style: context.text.bodyLarge?.copyWith(
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      context.l10n.profileChallengesSubtitle,
                                      style: context.text.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: context.colors.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        const SettingsMenu(),
                        const SizedBox(height: AppSpacing.xl),
                        if (email.isNotEmpty)
                          Center(
                            child: Text(email, style: context.text.bodySmall),
                          ),
                        const SizedBox(height: AppSpacing.lg),
                        const _LegalLinks(),
                      ],
                    );
                  },
            );
          },
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.profile, required this.name});

  final UserGameProfile profile;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.mutedGreen,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        Theme.of(context).cardTheme.color ??
                        context.colors.surface,
                    width: 4,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                // Dark ink on the fixed green plate in both themes.
                child: Icon(
                  Icons.eco_rounded,
                  size: 38,
                  color: context.colors.onTertiary,
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.lime,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 3,
                    ),
                  ),
                  child: Text(
                    '${profile.currentLevel.level}',
                    style: context.text.labelLarge?.copyWith(
                      fontSize: 13,
                      color: context.colors.onTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          name,
          textAlign: TextAlign.center,
          style: context.text.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          context.l10n.profileLevelCaption(
            profile.currentLevel.level,
            profile.currentLevel.title,
          ),
          style: context.text.bodyMedium,
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.profile});

  final UserGameProfile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: StaggeredFadeSlide(
            index: 0,
            baseDelay: const Duration(milliseconds: 200),
            child: _StatCard(
              animatedValue: profile.totalXp,
              value: '${profile.totalXp}',
              label: context.l10n.profileStatTotalPoints,
              dark: true,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: StaggeredFadeSlide(
            index: 1,
            baseDelay: const Duration(milliseconds: 200),
            child: _StatCard(
              value: '${profile.currentStreak}',
              label: context.l10n.profileStatStreakDays(profile.currentStreak),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: StaggeredFadeSlide(
            index: 2,
            baseDelay: const Duration(milliseconds: 200),
            child: _StatCard(
              value: '${profile.longestStreak}',
              label: context.l10n.profileStatRecord,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    this.dark = false,
    this.animatedValue,
  });

  final String value;
  final String label;
  final bool dark;

  /// When set, the number rolls smoothly instead of being static text.
  final int? animatedValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        // [dark] is the deliberately dark hero tile — it stays dark in both
        // themes; the plain tile follows the theme's card colour.
        color: dark ? AppColors.dark : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: dark
            ? null
            : <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        children: <Widget>[
          if (animatedValue != null)
            AnimatedPointsCounter(
              value: animatedValue!,
              showFloatingDelta: false,
              style: context.text.headlineMedium?.copyWith(
                fontSize: 22,
                color: dark ? AppColors.lime : context.colors.onSurface,
              ),
            )
          else
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.headlineMedium?.copyWith(
                fontSize: 22,
                color: dark ? AppColors.lime : context.colors.onSurface,
              ),
            ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.labelSmall?.copyWith(
              color: dark
                  ? AppColors.textMuted
                  : context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelProgressCard extends StatelessWidget {
  const _LevelProgressCard({required this.profile});

  final UserGameProfile profile;

  static String _nextTitle(int level) {
    for (final GameLevel entry in GameLevelTable.levels) {
      if (entry.level == level + 1) {
        return entry.title;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final GameLevel level = profile.currentLevel;
    final double fraction = level.progressFraction(profile.totalXp);

    return AppCard(
      radius: AppRadius.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: Text(
                  level.isMaxLevel
                      ? context.l10n.profileMaxLevel
                      : context.l10n.profileNextLevel(
                          level.level + 1,
                          _nextTitle(level.level),
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelLarge,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                level.isMaxLevel
                    ? 'MAX'
                    : '${profile.totalXp} / ${level.xpForNext}',
                style: context.text.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppProgressBar(value: fraction, height: 12),
        ],
      ),
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection({required this.overview});

  final GamificationOverview? overview;

  @override
  Widget build(BuildContext context) {
    final GamificationOverview? data = overview;
    if (data == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: AppSkeleton(height: 120, radius: AppRadius.lg),
      );
    }

    final List<BadgeGalleryItem> gallery = data.badgeGallery;
    final int unlocked = gallery
        .where((BadgeGalleryItem g) => g.isUnlocked)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppSectionHeader(
          title: context.l10n.profileAchievements,
          trailing: Text(
            context.l10n.profileAchievementsCount(unlocked, gallery.length),
            style: context.text.labelMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        BadgeGallery(items: gallery),
      ],
    );
  }
}

class _WeeklyActivityCard extends StatelessWidget {
  const _WeeklyActivityCard({required this.profile});

  final UserGameProfile profile;

  static String _dateKey(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime monday = today.subtract(Duration(days: today.weekday - 1));
    final Set<String> done = profile.completedDates.toSet();
    final AppLocalizations l10n = context.l10n;
    final List<String> weekLabels = <String>[
      l10n.profileWeekdayMon,
      l10n.profileWeekdayTue,
      l10n.profileWeekdayWed,
      l10n.profileWeekdayThu,
      l10n.profileWeekdayFri,
      l10n.profileWeekdaySat,
      l10n.profileWeekdaySun,
    ];

    return AppCard(
      radius: AppRadius.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.profileWeeklyActivity, style: context.text.labelLarge),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(7, (int i) {
              final DateTime date = monday.add(Duration(days: i));
              final bool isDone = done.contains(_dateKey(date));
              final Duration delay = Duration(milliseconds: 40 * i);
              final Widget dot = _WeekDot(
                label: weekLabels[i],
                done: isDone,
                isToday: date == today,
              );
              // Wave left-to-right: done days pop, others simply fade in.
              return isDone
                  ? ScalePop(delay: delay, fromScale: 0.8, child: dot)
                  : FadeSlideIn(delay: delay, offset: 0, child: dot);
            }),
          ),
        ],
      ),
    );
  }
}

class _WeekDot extends StatelessWidget {
  const _WeekDot({
    required this.label,
    required this.done,
    required this.isToday,
  });

  final String label;
  final bool done;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    // Today's dot is a deliberately dark chip in both themes; the empty dot is
    // an inset pill, so it follows the theme's chip colour.
    final Color background = isToday
        ? AppColors.dark
        : (done
              ? AppColors.lime
              : (Theme.of(context).chipTheme.backgroundColor ??
                    context.colors.surface));

    return Column(
      children: <Widget>[
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: done
              ? Icon(
                  Icons.check_rounded,
                  size: 15,
                  color: isToday ? AppColors.lime : AppColors.dark,
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: isToday
              ? context.text.labelSmall?.copyWith(
                  color: context.colors.onSurface,
                )
              : context.text.labelSmall,
        ),
      ],
    );
  }
}

class _LegalLinks extends StatelessWidget {
  const _LegalLinks();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: AppSpacing.lg,
        children: <Widget>[
          _LegalLink(
            label: context.l10n.profilePrivacyPolicy,
            url: LegalUrls.privacyPolicy,
          ),
          _LegalLink(
            label: context.l10n.profileTermsOfService,
            url: LegalUrls.termsOfService,
          ),
        ],
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.url});

  final String label;
  final String url;

  Future<void> _open(BuildContext context) async {
    final bool launched = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profileLinkOpenFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _open(context),
      child: Text(label, style: context.text.bodySmall),
    );
  }
}
