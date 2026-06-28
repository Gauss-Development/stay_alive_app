import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_effect.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_cubit.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_state.dart';
import 'package:stay_alive/features/gamification/presentation/widgets/level_up_overlay.dart';

class GamificationCelebrationHost extends StatefulWidget {
  const GamificationCelebrationHost({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<GamificationCelebrationHost> createState() =>
      _GamificationCelebrationHostState();
}

class _GamificationCelebrationHostState
    extends State<GamificationCelebrationHost> {
  GamificationEffect? _activeEffect;

  @override
  Widget build(BuildContext context) {
    return BlocListener<GamificationCubit, GamificationState>(
      listenWhen: (GamificationState previous, GamificationState current) {
        if (current is! GamificationLoaded) {
          return false;
        }
        if (previous is! GamificationLoaded) {
          return current.pendingEffects.isNotEmpty;
        }
        return current.pendingEffects != previous.pendingEffects &&
            current.pendingEffects.isNotEmpty;
      },
      listener: (BuildContext context, GamificationState state) {
        if (state is! GamificationLoaded || state.pendingEffects.isEmpty) {
          return;
        }
        _showNextEffect(state.pendingEffects.first);
      },
      child: Stack(
        children: <Widget>[
          widget.child,
          if (_activeEffect is LevelUpEffect)
            Positioned.fill(
              child: LevelUpOverlay(
                level: (_activeEffect! as LevelUpEffect).level,
                onDismiss: _dismissActiveEffect,
              ),
            ),
        ],
      ),
    );
  }

  void _showNextEffect(GamificationEffect effect) {
    if (_activeEffect != null) {
      return;
    }

    if (effect is BadgeUnlockedEffect) {
      _showBadgeSnackBar(effect);
      context.read<GamificationCubit>().dismissEffect(effect);
      return;
    }

    if (effect is ChallengeCompletedEffect) {
      _showChallengeSnackBar(effect);
      context.read<GamificationCubit>().dismissEffect(effect);
      return;
    }

    setState(() {
      _activeEffect = effect;
    });
  }

  void _showBadgeSnackBar(BadgeUnlockedEffect effect) {
    final badge = effect.badge.definition;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${badge.emoji} Badge unlocked: ${badge.name}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _showChallengeSnackBar(ChallengeCompletedEffect effect) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Challenge complete: ${effect.challenge.title} (+${effect.challenge.xpReward} XP)',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _dismissActiveEffect() {
    final GamificationEffect? effect = _activeEffect;
    setState(() {
      _activeEffect = null;
    });
    if (effect != null) {
      context.read<GamificationCubit>().dismissEffect(effect);
    }
  }
}
