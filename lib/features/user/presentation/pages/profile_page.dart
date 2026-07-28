import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stay_alive/core/constants/app_routes.dart';
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
import 'package:stay_alive/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_state.dart';
import 'package:stay_alive/features/gamification/domain/entities/game_level.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_overview.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_cubit.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_state.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/badge_gallery.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:stay_alive/features/user/presentation/cubit/user_profile_cubit.dart';
import 'package:stay_alive/features/user/presentation/cubit/user_profile_state.dart';

const List<String> _weekLabels = <String>[
  'Пн',
  'Вт',
  'Ср',
  'Чт',
  'Пт',
  'Сб',
  'Вс',
];

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
                              'Профиль',
                              style: AppTextStyles.titleLarge,
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
                                child: const Icon(
                                  Icons.flag_rounded,
                                  size: 20,
                                  color: AppColors.dark,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Челленджи и награды',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      'Квесты, серии и все достижения',
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textMuted,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        if (email.isNotEmpty)
                          Center(
                            child: Text(
                              email,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        const SizedBox(height: AppSpacing.lg),
                        const _DeleteAccountButton(),
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
                  border: Border.all(color: AppColors.white, width: 4),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 38,
                  color: AppColors.textPrimary,
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
                    border: Border.all(color: AppColors.background, width: 3),
                  ),
                  child: Text(
                    '${profile.currentLevel.level}',
                    style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
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
          style: AppTextStyles.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Уровень ${profile.currentLevel.level} · '
          '${profile.currentLevel.title} 🌱',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
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
              label: 'всего очков',
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
              label: '🔥 дней серия',
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
              label: '🏆 рекорд',
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
        color: dark ? AppColors.dark : AppColors.white,
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
              style: AppTextStyles.headlineMedium.copyWith(
                fontSize: 22,
                color: dark ? AppColors.lime : AppColors.textPrimary,
              ),
            )
          else
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.headlineMedium.copyWith(
                fontSize: 22,
                color: dark ? AppColors.lime : AppColors.textPrimary,
              ),
            ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSmall.copyWith(
              color: dark ? AppColors.textMuted : AppColors.textSecondary,
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
                      ? 'Максимальный уровень'
                      : 'До уровня ${level.level + 1} · '
                            '${_nextTitle(level.level)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLarge,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                level.isMaxLevel
                    ? 'MAX'
                    : '${profile.totalXp} / ${level.xpForNext}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textMuted,
                ),
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
          title: 'Достижения',
          trailing: Text(
            '$unlocked из ${gallery.length}',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textMuted,
            ),
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

    return AppCard(
      radius: AppRadius.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Активность недели', style: AppTextStyles.labelLarge),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(7, (int i) {
              final DateTime date = monday.add(Duration(days: i));
              final bool isDone = done.contains(_dateKey(date));
              final Duration delay = Duration(milliseconds: 40 * i);
              final Widget dot = _WeekDot(
                label: _weekLabels[i],
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
    final Color background = isToday
        ? AppColors.dark
        : (done ? AppColors.lime : AppColors.surface);

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
          style: AppTextStyles.labelSmall.copyWith(
            color: isToday ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _DeleteAccountButton extends StatelessWidget {
  const _DeleteAccountButton();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
          previous != current &&
          (current is AuthError || current is AuthUnauthenticated),
      listener: (BuildContext context, AuthState state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Не удалось удалить аккаунт: ${state.message}'),
            ),
          );
        }
      },
      child: Center(
        child: TextButton(
          onPressed: () => _confirm(context),
          child: Text(
            'Удалить аккаунт',
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Удалить аккаунт?'),
          content: const Text(
            'Это навсегда удалит профиль, дневные записи, историю, прогресс '
            'и данные подписки. Отменить это будет нельзя.\n\n'
            'Активные подписки App Store / Play Store при удалении аккаунта '
            'не отменяются — управляй ими в настройках подписок магазина.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<AuthCubit>().deleteAccount();
  }
}
