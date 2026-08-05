import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stay_alive/core/constants/app_routes.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log.dart';
import 'package:stay_alive/features/daily_tracker/domain/entities/daily_log_item.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_cubit.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_state.dart';
import 'package:stay_alive/features/gamification/domain/entities/garden_state.dart';
import 'package:stay_alive/features/gamification/domain/services/garden_state_builder.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_cubit.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_state.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/garden_sprout.dart';
import 'package:stay_alive/features/rostok/presentation/theme/rostok_colors.dart';
import 'package:stay_alive/features/rostok/presentation/theme/rostok_text.dart';
import 'package:stay_alive/features/rostok/presentation/widgets/points_ring.dart';
import 'package:stay_alive/features/rostok/presentation/widgets/rostok_hatch.dart';
import 'package:stay_alive/features/rostok/presentation/widgets/rostok_primitives.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:stay_alive/features/user/presentation/cubit/user_profile_cubit.dart';
import 'package:stay_alive/features/user/presentation/cubit/user_profile_state.dart';

enum _FoodFilter { all, remaining, done }

/// Per-row icon tints, cycled by category order (from the mockup palette).
const List<Color> _foodTints = <Color>[
  Color(0xFFECDCC0),
  Color(0xFFE7ECF3),
  Color(0xFFD9E7CD),
  Color(0xFFD5E8C8),
  Color(0xFFF0D9D6),
  Color(0xFFE8DDCF),
];

/// Росток "Главный" (home) screen.
///
/// The mockup's per-food "points" list maps onto the app's Daily-Dozen
/// *categories* (serving counts): each row is a category, the check toggles a
/// serving via [DailyTrackerCubit]. The ring shows daily completion; the level
/// chip + streak come from [GamificationCubit].
class RostokHomePage extends StatefulWidget {
  const RostokHomePage({super.key});

  @override
  State<RostokHomePage> createState() => _RostokHomePageState();
}

class _RostokHomePageState extends State<RostokHomePage> {
  _FoodFilter _filter = _FoodFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final bool isPremium = context
          .read<SubscriptionCubit>()
          .state
          .isPremiumActive;
      context.read<DailyTrackerCubit>().loadToday();
      context.read<GamificationCubit>().load(isPremium: isPremium);
      if (context.read<UserProfileCubit>().state is UserProfileInitial) {
        context.read<UserProfileCubit>().load();
      }
    });
  }

  void _toggle(DailyLogItem item) {
    final DailyTrackerCubit cubit = context.read<DailyTrackerCubit>();
    if (item.isCompleted) {
      cubit.decrement(item.categoryId);
    } else {
      cubit.increment(item.categoryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RostokScaffold(
      padding: EdgeInsets.zero,
      child: BlocBuilder<DailyTrackerCubit, DailyTrackerState>(
        builder: (BuildContext context, DailyTrackerState state) {
          final DailyLog? log = state.log;
          if (log == null) {
            if (state.status == DailyTrackerStatus.error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.errorMessage ?? 'Не удалось загрузить день.',
                    textAlign: TextAlign.center,
                    style: RostokText.body(),
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: <Widget>[
              Expanded(child: _buildList(context, log)),
              _HomeBottomBar(
                log: log,
                onAdd: () => context.push(AppRoutes.categories),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, DailyLog log) {
    final List<DailyLogItem> items = switch (_filter) {
      _FoodFilter.all => log.items,
      _FoodFilter.remaining =>
        log.items.where((DailyLogItem i) => !i.isCompleted).toList(),
      _FoodFilter.done =>
        log.items.where((DailyLogItem i) => i.isCompleted).toList(),
    };
    final int eaten = log.items.where((DailyLogItem i) => i.isCompleted).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      children: <Widget>[
        _buildGreeting(context),
        const SizedBox(height: 16),
        BlocBuilder<GamificationCubit, GamificationState>(
          builder: (BuildContext context, GamificationState state) {
            if (state is! GamificationLoaded) {
              return const SizedBox.shrink();
            }
            final GardenState garden = const GardenStateBuilder().build(
              profile: state.overview.profile,
              recentLogs: <DailyLog>[log],
              todayLog: log,
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GardenSprout(state: garden, size: 110),
            );
          },
        ),
        const SizedBox(height: 4),
        _buildPointsCard(log),
        const SizedBox(height: 20),
        _buildFilters(),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Съедено сегодня', style: RostokText.display(size: 19)),
            Text(
              '$eaten/${log.items.length}',
              style: RostokText.body(
                size: 13,
                weight: FontWeight.w600,
                color: RostokColors.textFaint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final DailyLogItem item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _FoodRow(
              item: item,
              tint: _foodTints[log.items.indexOf(item) % _foodTints.length],
              onTap: () => _toggle(item),
            ),
          ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: Text(
                'Здесь пока пусто',
                style: RostokText.body(color: RostokColors.textFaint),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: BlocBuilder<UserProfileCubit, UserProfileState>(
            builder: (BuildContext context, UserProfileState state) {
              final String name = state is UserProfileLoaded
                  ? state.profile.displayName
                  : 'друг';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Привет, $name 👋', style: RostokText.body(size: 15)),
                  const SizedBox(height: 2),
                  Text(
                    'Что съедим\nполезного?',
                    style: RostokText.display(size: 26, height: 1.1),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: RostokDimens.softShadow,
          ),
          child: const ClipOval(
            child: RostokHatch(baseColor: RostokColors.avatarBg),
          ),
        ),
      ],
    );
  }

  Widget _buildPointsCard(DailyLog log) {
    final int done = log.totalCompleted;
    final int goal = log.totalTarget;
    final int remaining = (goal - done).clamp(0, goal);
    final double fraction = goal > 0 ? done / goal : 0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: const BoxDecoration(
        color: RostokColors.ink,
        borderRadius: RostokDimens.panel,
      ),
      child: Row(
        children: <Widget>[
          PointsRing(
            fraction: fraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '$done',
                  style: RostokText.display(
                    size: 24,
                    weight: FontWeight.w700,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                Text(
                  'из $goal',
                  style: RostokText.body(
                    size: 10,
                    color: RostokColors.textOnDarkMuted,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: BlocBuilder<GamificationCubit, GamificationState>(
              builder: (BuildContext context, GamificationState state) {
                final int level = state is GamificationLoaded
                    ? state.overview.profile.currentLevel.level
                    : 1;
                final String title = state is GamificationLoaded
                    ? state.overview.profile.currentLevel.title
                    : '—';
                final int streak = state is GamificationLoaded
                    ? state.overview.profile.currentStreak
                    : 0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    RostokAccentTag(
                      label: 'Уровень $level · $title',
                      onDark: true,
                    ),
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        style: RostokText.display(
                          size: 16,
                          weight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.3,
                        ),
                        children: <InlineSpan>[
                          const TextSpan(text: 'Осталось '),
                          TextSpan(
                            text: '$remaining',
                            style: RostokText.display(
                              size: 16,
                              weight: FontWeight.w700,
                              color: RostokColors.accent,
                            ),
                          ),
                          const TextSpan(text: ' порций\nдо цели дня'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '🔥 $streak дней подряд',
                      style: RostokText.body(
                        size: 12,
                        color: RostokColors.textOnDarkMuted,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          RostokPill(
            label: 'Все',
            active: _filter == _FoodFilter.all,
            onTap: () => setState(() => _filter = _FoodFilter.all),
          ),
          const SizedBox(width: 9),
          RostokPill(
            label: 'Осталось',
            active: _filter == _FoodFilter.remaining,
            onTap: () => setState(() => _filter = _FoodFilter.remaining),
          ),
          const SizedBox(width: 9),
          RostokPill(
            label: 'Готово',
            active: _filter == _FoodFilter.done,
            onTap: () => setState(() => _filter = _FoodFilter.done),
          ),
        ],
      ),
    );
  }
}

class _FoodRow extends StatelessWidget {
  const _FoodRow({required this.item, required this.tint, required this.onTap});

  final DailyLogItem item;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool done = item.isCompleted;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: RostokColors.card,
        borderRadius: RostokDimens.row,
        boxShadow: RostokDimens.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: SizedBox(
                width: 52,
                height: 52,
                child: RostokHatch(
                  baseColor: tint,
                  stripeColor: const Color(0x33FFFFFF),
                  child: Center(
                    child: Text(
                      _mono(item.title),
                      style: RostokText.body(
                        size: 10,
                        weight: FontWeight.w700,
                        color: const Color(0x66000000),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RostokText.body(
                      size: 15,
                      weight: FontWeight.w700,
                      color: done
                          ? RostokColors.textFaint
                          : RostokColors.inkText,
                      decoration: done
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: RostokColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${item.completedCount}/${item.targetCount} порций',
                        style: RostokText.body(
                          size: 12,
                          weight: FontWeight.w600,
                          color: RostokColors.textFaint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _CheckButton(done: done, onTap: onTap),
          ],
        ),
      ),
    );
  }

  static String _mono(String title) {
    final String trimmed = title.trim();
    if (trimmed.isEmpty) {
      return '•';
    }
    final int end = trimmed.length < 3 ? trimmed.length : 3;
    return trimmed.substring(0, end).toUpperCase();
  }
}

class _CheckButton extends StatelessWidget {
  const _CheckButton({required this.done, required this.onTap});

  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: done ? RostokColors.ink : Colors.white,
          border: Border.all(
            color: done ? RostokColors.ink : RostokColors.fieldBorder,
            width: 2,
          ),
        ),
        child: Icon(
          Icons.check_rounded,
          size: 22,
          color: done ? RostokColors.accent : const Color(0xFFD0D0C6),
        ),
      ),
    );
  }
}

class _HomeBottomBar extends StatelessWidget {
  const _HomeBottomBar({required this.log, required this.onAdd});

  final DailyLog log;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x0F3C5032),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: RostokColors.accent,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Text(
                  '+',
                  style: RostokText.display(size: 20, weight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '${log.totalCompleted} порций',
                    style: RostokText.display(
                      size: 17,
                      weight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'отмечено сегодня',
                    style: RostokText.body(
                      size: 12,
                      color: RostokColors.textFaint,
                    ),
                  ),
                ],
              ),
            ],
          ),
          DecoratedBox(
            decoration: const BoxDecoration(
              color: RostokColors.ink,
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(18)),
                onTap: onAdd,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  child: Text(
                    'Добавить',
                    style: RostokText.display(
                      size: 15,
                      weight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
