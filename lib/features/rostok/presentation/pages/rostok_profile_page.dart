import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stay_alive/core/constants/app_routes.dart';
import 'package:stay_alive/features/gamification/domain/entities/game_level.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_overview.dart';
import 'package:stay_alive/features/gamification/domain/entities/user_game_profile.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_cubit.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_state.dart';
import 'package:stay_alive/features/rostok/presentation/theme/rostok_colors.dart';
import 'package:stay_alive/features/rostok/presentation/theme/rostok_text.dart';
import 'package:stay_alive/features/rostok/presentation/widgets/rostok_hatch.dart';
import 'package:stay_alive/features/rostok/presentation/widgets/rostok_primitives.dart';
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
const List<Color> _achieveTints = <Color>[
  RostokColors.accent,
  Color(0xFFE6DCF5),
  Color(0xFFD6DEF7),
  Color(0xFFD5E8C8),
];

/// Росток "Профиль" screen — avatar + level badge, stat cards, level progress,
/// achievements grid ([GamificationOverview.badgeGallery]) and a weekly-activity
/// row derived from [UserGameProfile.completedDates].
class RostokProfilePage extends StatefulWidget {
  const RostokProfilePage({super.key});

  @override
  State<RostokProfilePage> createState() => _RostokProfilePageState();
}

class _RostokProfilePageState extends State<RostokProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (context.read<UserProfileCubit>().state is UserProfileInitial) {
        context.read<UserProfileCubit>().load();
      }
      if (context.read<GamificationCubit>().state is! GamificationLoaded) {
        final bool isPremium = context
            .read<SubscriptionCubit>()
            .state
            .isPremiumActive;
        context.read<GamificationCubit>().load(isPremium: isPremium);
      }
    });
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.rostokHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RostokScaffold(
      child: BlocBuilder<GamificationCubit, GamificationState>(
        builder: (BuildContext context, GamificationState state) {
          final GamificationOverview? overview = state is GamificationLoaded
              ? state.overview
              : null;
          final UserGameProfile profile =
              overview?.profile ?? const UserGameProfile.empty();
          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            children: <Widget>[
              RostokHeader(
                title: 'Профиль',
                onBack: _back,
                trailing: RostokCircleButton(
                  icon: Icons.settings_outlined,
                  onTap: () => context.push(AppRoutes.profile),
                ),
              ),
              const SizedBox(height: 20),
              _buildAvatar(profile),
              const SizedBox(height: 22),
              _buildStats(profile),
              const SizedBox(height: 14),
              _buildLevelCard(profile),
              const SizedBox(height: 20),
              _buildAchievements(overview),
              const SizedBox(height: 18),
              _buildWeek(profile),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAvatar(UserGameProfile profile) {
    return Column(
      children: <Widget>[
        Center(
          child: SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: RostokDimens.softShadow,
                  ),
                  child: const ClipOval(
                    child: RostokHatch(baseColor: RostokColors.avatarBg),
                  ),
                ),
                Positioned(
                  right: -6,
                  bottom: -6,
                  child: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: RostokColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: RostokColors.surface, width: 3),
                    ),
                    child: Text(
                      '${profile.currentLevel.level}',
                      style: RostokText.display(
                        size: 13,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        BlocBuilder<UserProfileCubit, UserProfileState>(
          builder: (BuildContext context, UserProfileState state) {
            final String name = state is UserProfileLoaded
                ? state.profile.displayName
                : 'Игрок';
            return Text(name, style: RostokText.display(size: 24));
          },
        ),
        const SizedBox(height: 4),
        Text(
          'Уровень ${profile.currentLevel.level} · ${profile.currentLevel.title} 🌱',
          style: RostokText.body(
            size: 14,
            weight: FontWeight.w600,
            color: RostokColors.textFaint,
          ),
        ),
      ],
    );
  }

  Widget _buildStats(UserGameProfile profile) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _StatCard(
            value: '${profile.totalXp}',
            label: 'всего XP',
            dark: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: '${profile.currentStreak}',
            label: '🔥 дней серия',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: '${profile.longestStreak}',
            label: '🏆 рекорд',
          ),
        ),
      ],
    );
  }

  Widget _buildLevelCard(UserGameProfile profile) {
    final GameLevel level = profile.currentLevel;
    final double fraction = level.progressFraction(profile.totalXp);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: RostokColors.card,
        borderRadius: RostokDimens.card,
        boxShadow: RostokDimens.softShadow,
      ),
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
                      : 'До уровня ${level.level + 1} · ${_nextTitle(level.level)}',
                  style: RostokText.body(
                    size: 14,
                    weight: FontWeight.w700,
                    color: RostokColors.inkText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                level.isMaxLevel
                    ? 'MAX'
                    : '${profile.totalXp} / ${level.xpForNext} XP',
                style: RostokText.body(
                  size: 13,
                  weight: FontWeight.w700,
                  color: RostokColors.textFaint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RostokProgressBar(
            fraction: fraction,
            height: 14,
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFFA8D84A), RostokColors.accent],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(GamificationOverview? overview) {
    if (overview == null) {
      return const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final List<BadgeGalleryItem> gallery = overview.badgeGallery;
    final int unlocked = gallery
        .where((BadgeGalleryItem g) => g.isUnlocked)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Достижения', style: RostokText.display(size: 18)),
            Text(
              '$unlocked из ${gallery.length}',
              style: RostokText.body(
                size: 13,
                weight: FontWeight.w600,
                color: RostokColors.textFaint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: <Widget>[
            for (int i = 0; i < gallery.length; i++)
              _AchieveTile(
                item: gallery[i],
                tint: _achieveTints[i % _achieveTints.length],
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeek(UserGameProfile profile) {
    final List<_WeekDay> days = _weekDays(profile);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: RostokColors.card,
        borderRadius: RostokDimens.card,
        boxShadow: RostokDimens.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Активность недели',
            style: RostokText.body(
              size: 14,
              weight: FontWeight.w700,
              color: RostokColors.inkText,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              for (final _WeekDay day in days) _WeekDot(day: day),
            ],
          ),
        ],
      ),
    );
  }

  static String _nextTitle(int level) {
    for (final GameLevel entry in GameLevelTable.levels) {
      if (entry.level == level + 1) {
        return entry.title;
      }
    }
    return '';
  }

  static List<_WeekDay> _weekDays(UserGameProfile profile) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime monday = today.subtract(Duration(days: today.weekday - 1));
    final Set<String> done = profile.completedDates.toSet();
    return List<_WeekDay>.generate(7, (int i) {
      final DateTime date = monday.add(Duration(days: i));
      return _WeekDay(
        label: _weekLabels[i],
        done: done.contains(_dateKey(date)),
        isToday: date == today,
      );
    });
  }

  static String _dateKey(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    this.dark = false,
  });

  final String value;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: dark ? RostokColors.ink : RostokColors.card,
        borderRadius: RostokDimens.row,
        boxShadow: dark ? null : RostokDimens.softShadow,
      ),
      child: Column(
        children: <Widget>[
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: RostokText.display(
              size: 22,
              weight: FontWeight.w700,
              color: dark ? RostokColors.accent : RostokColors.inkText,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: RostokText.body(
              size: 11,
              color: dark
                  ? RostokColors.textOnDarkMuted
                  : RostokColors.textFaint,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchieveTile extends StatelessWidget {
  const _AchieveTile({required this.item, required this.tint});

  final BadgeGalleryItem item;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final bool unlocked = item.isUnlocked;
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: unlocked ? tint : RostokColors.chipBg,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Opacity(
            opacity: unlocked ? 1 : 0.5,
            child: Text(
              item.definition.emoji,
              style: const TextStyle(fontSize: 26),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              unlocked ? item.definition.name : 'Закрыто',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: RostokText.body(
                size: 9,
                weight: FontWeight.w700,
                color: unlocked
                    ? RostokColors.chipText
                    : RostokColors.textOnDarkMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekDay {
  const _WeekDay({
    required this.label,
    required this.done,
    required this.isToday,
  });

  final String label;
  final bool done;
  final bool isToday;
}

class _WeekDot extends StatelessWidget {
  const _WeekDot({required this.day});

  final _WeekDay day;

  @override
  Widget build(BuildContext context) {
    final Color background = day.isToday
        ? RostokColors.ink
        : (day.done ? RostokColors.accent : RostokColors.chipBg);
    return Column(
      children: <Widget>[
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: day.done
              ? Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: day.isToday
                      ? RostokColors.accent
                      : RostokColors.inkText,
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 8),
        Text(
          day.label,
          style: RostokText.body(
            size: 11,
            weight: FontWeight.w600,
            color: day.isToday
                ? RostokColors.inkText
                : RostokColors.textOnDarkMuted,
          ),
        ),
      ],
    );
  }
}
