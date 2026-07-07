import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stay_alive/core/constants/app_routes.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_cubit.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_state.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_cubit.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_state.dart';
import 'package:stay_alive/features/rostok/presentation/theme/rostok_colors.dart';
import 'package:stay_alive/features/rostok/presentation/theme/rostok_text.dart';
import 'package:stay_alive/features/rostok/presentation/widgets/rostok_primitives.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:stay_alive/features/user/presentation/cubit/user_profile_cubit.dart';
import 'package:stay_alive/features/user/presentation/cubit/user_profile_state.dart';

/// XP granted per serving by the gamification engine — used to show the day's
/// gain on the celebration screen.
const int _xpPerServing = 5;

/// Росток "Награда" (level-up / goal-reached celebration) screen.
///
/// Standalone route driven by current gamification + daily state. It is
/// intentionally NOT hooked into the live effect stream so it does not clash
/// with the existing [GamificationCelebrationHost] overlay.
class RostokRewardPage extends StatefulWidget {
  const RostokRewardPage({super.key});

  @override
  State<RostokRewardPage> createState() => _RostokRewardPageState();
}

class _RostokRewardPageState extends State<RostokRewardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (context.read<GamificationCubit>().state is! GamificationLoaded) {
        final bool isPremium =
            context.read<SubscriptionCubit>().state.isPremiumActive;
        context.read<GamificationCubit>().load(isPremium: isPremium);
      }
      if (context.read<DailyTrackerCubit>().state.log == null) {
        context.read<DailyTrackerCubit>().loadToday();
      }
      if (context.read<UserProfileCubit>().state is UserProfileInitial) {
        context.read<UserProfileCubit>().load();
      }
    });
  }

  void _dismiss() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.rostokHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RostokColors.rewardBottom,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.35),
            radius: 1.15,
            colors: <Color>[RostokColors.rewardTop, RostokColors.rewardBottom],
            stops: <double>[0, 0.72],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 12, 26, 24),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ..._confetti(),
                _buildContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildStatusTag(),
                  const SizedBox(height: 26),
                  _buildMascotGlow(),
                  const SizedBox(height: 24),
                  BlocBuilder<UserProfileCubit, UserProfileState>(
                    builder: (BuildContext context, UserProfileState state) {
                      final String name = state is UserProfileLoaded
                          ? state.profile.displayName
                          : 'чемпион';
                      return Text(
                        'Отлично,\n$name!',
                        textAlign: TextAlign.center,
                        style: RostokText.display(
                          size: 32,
                          color: Colors.white,
                          height: 1.15,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildPointsLine(),
                  const SizedBox(height: 8),
                  _buildLevelLine(),
                ],
              ),
            ),
          ),
        ),
        _RewardButton(onTap: _dismiss),
        const SizedBox(height: 12),
        Text(
          'Поделиться с друзьями',
          style: RostokText.body(
            size: 14,
            weight: FontWeight.w600,
            color: const Color(0xFF8F977F),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTag() {
    return BlocBuilder<DailyTrackerCubit, DailyTrackerState>(
      builder: (BuildContext context, DailyTrackerState state) {
        final bool done = state.log?.isFullyCompleted ?? false;
        return RostokAccentTag(
          label: done ? 'ЦЕЛЬ ДНЯ ВЫПОЛНЕНА' : 'ТЫ НА ПУТИ К ЦЕЛИ',
          onDark: true,
          uppercase: true,
        );
      },
    );
  }

  Widget _buildPointsLine() {
    return BlocBuilder<DailyTrackerCubit, DailyTrackerState>(
      builder: (BuildContext context, DailyTrackerState state) {
        final int points = (state.log?.totalCompleted ?? 0) * _xpPerServing;
        return Text(
          '+$points XP',
          style: RostokText.display(
            size: 22,
            weight: FontWeight.w700,
            color: RostokColors.accent,
          ),
        );
      },
    );
  }

  Widget _buildLevelLine() {
    return BlocBuilder<GamificationCubit, GamificationState>(
      builder: (BuildContext context, GamificationState state) {
        if (state is! GamificationLoaded) {
          return const SizedBox.shrink();
        }
        final int level = state.overview.profile.currentLevel.level;
        final String title = state.overview.profile.currentLevel.title;
        final String emoji = level >= 5 ? '🌳' : (level >= 3 ? '🌿' : '🌱');
        return Text.rich(
          TextSpan(
            style: RostokText.body(size: 15, color: Colors.white70),
            children: <InlineSpan>[
              const TextSpan(text: 'Твой уровень — '),
              TextSpan(
                text: '$title $emoji',
                style: RostokText.body(
                  size: 15,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        );
      },
    );
  }

  Widget _buildMascotGlow() {
    return Container(
      width: 172,
      height: 172,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            RostokColors.accent.withValues(alpha: 0.33),
            Colors.transparent,
          ],
          stops: const <double>[0, 0.7],
        ),
      ),
      child: Container(
        width: 118,
        height: 118,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0x59000000),
              blurRadius: 40,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: const RostokMascot(size: 56),
      ),
    );
  }

  List<Widget> _confetti() {
    const List<_Dot> dots = <_Dot>[
      _Dot(Alignment(-0.7, -0.78), RostokColors.accent, 10, true),
      _Dot(Alignment(0.72, -0.66), Color(0xFFE6DCF5), 8, false),
      _Dot(Alignment(-0.55, -0.34), RostokColors.accentBlue, 7, false),
      _Dot(Alignment(0.62, 0.5), RostokColors.accent, 11, true),
      _Dot(Alignment(-0.5, 0.46), RostokColors.accentOrange, 8, false),
    ];
    return <Widget>[
      for (final _Dot dot in dots)
        Align(
          alignment: dot.alignment,
          child: Container(
            width: dot.size,
            height: dot.size,
            decoration: BoxDecoration(
              color: dot.color,
              shape: dot.square ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: dot.square
                  ? const BorderRadius.all(Radius.circular(3))
                  : null,
            ),
          ),
        ),
    ];
  }
}

class _Dot {
  const _Dot(this.alignment, this.color, this.size, this.square);

  final Alignment alignment;
  final Color color;
  final double size;
  final bool square;
}

class _RewardButton extends StatelessWidget {
  const _RewardButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: RostokColors.accent,
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(22)),
          onTap: onTap,
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: Center(
              child: Text(
                'Забрать награду',
                style: RostokText.display(
                  size: 18,
                  weight: FontWeight.w700,
                  color: RostokColors.inkText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
