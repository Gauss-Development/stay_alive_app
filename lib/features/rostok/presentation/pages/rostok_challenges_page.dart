import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stay_alive/core/constants/app_routes.dart';
import 'package:stay_alive/features/gamification/domain/entities/category_mastery.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_challenge.dart';
import 'package:stay_alive/features/gamification/domain/entities/gamification_overview.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_cubit.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_state.dart';
import 'package:stay_alive/features/rostok/presentation/theme/rostok_colors.dart';
import 'package:stay_alive/features/rostok/presentation/theme/rostok_text.dart';
import 'package:stay_alive/features/rostok/presentation/widgets/rostok_primitives.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_cubit.dart';

/// Росток "Челленджи" screen.
///
/// The mockup's featured weekly challenge maps onto
/// [GamificationOverview.weeklyChallenge]; the "Ежедневные" list shows the real
/// [GamificationOverview.dailyChallenge]. Category-mastery progress fills the
/// rest of the list (the engine surfaces one daily + one weekly challenge, not
/// the mock's four quests).
class RostokChallengesPage extends StatefulWidget {
  const RostokChallengesPage({super.key});

  @override
  State<RostokChallengesPage> createState() => _RostokChallengesPageState();
}

class _RostokChallengesPageState extends State<RostokChallengesPage> {
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
      child: Column(
        children: <Widget>[
          const SizedBox(height: 8),
          RostokHeader(title: 'Челленджи', onBack: _back),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<GamificationCubit, GamificationState>(
              builder: (BuildContext context, GamificationState state) {
                if (state is! GamificationLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }
                final GamificationOverview overview = state.overview;
                return ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: <Widget>[
                    _FeaturedChallenge(challenge: overview.weeklyChallenge),
                    const SizedBox(height: 24),
                    Text('Ежедневные', style: RostokText.display(size: 18)),
                    const SizedBox(height: 12),
                    _QuestCard(
                      name: overview.dailyChallenge.title,
                      rewardLabel: '+${overview.dailyChallenge.xpReward} XP',
                      fraction: overview.dailyChallenge.progressFraction,
                      progressLabel:
                          '${overview.dailyChallenge.progress}/${overview.dailyChallenge.target}',
                    ),
                    if (overview.categoryMastery.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 24),
                      Text(
                        'Прогресс по категориям',
                        style: RostokText.display(size: 18),
                      ),
                      const SizedBox(height: 12),
                      for (final CategoryMastery mastery in overview.categoryMastery)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _QuestCard(
                            name: mastery.title,
                            rewardLabel: _tierLabel(mastery.tier),
                            fraction: mastery.progressToNextTier,
                            progressLabel: mastery.nextTierThreshold > 0
                                ? '${mastery.totalServings}/${mastery.nextTierThreshold}'
                                : 'MAX',
                          ),
                        ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _tierLabel(MasteryTier tier) {
    return switch (tier) {
      MasteryTier.none => 'Старт',
      MasteryTier.bronze => 'Бронза',
      MasteryTier.silver => 'Серебро',
      MasteryTier.gold => 'Золото',
      MasteryTier.platinum => 'Платина',
    };
  }
}

class _FeaturedChallenge extends StatelessWidget {
  const _FeaturedChallenge({required this.challenge});

  final GamificationChallenge challenge;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: RostokColors.ink,
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: RostokColors.accent.withValues(alpha: 0.18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const RostokAccentTag(
                  label: 'ЧЕЛЛЕНДЖ НЕДЕЛИ',
                  onDark: true,
                  uppercase: true,
                ),
                const SizedBox(height: 14),
                Text(
                  challenge.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: RostokText.display(
                    size: 24,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      '${challenge.progress} из ${challenge.target}',
                      style: RostokText.body(
                        size: 14,
                        color: RostokColors.textOnDarkMuted,
                      ),
                    ),
                    Text(
                      '+${challenge.xpReward} XP',
                      style: RostokText.display(
                        size: 16,
                        weight: FontWeight.w700,
                        color: RostokColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                RostokProgressBar(
                  fraction: challenge.progressFraction,
                  background: RostokColors.darkChip,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  const _QuestCard({
    required this.name,
    required this.rewardLabel,
    required this.fraction,
    required this.progressLabel,
  });

  final String name;
  final String rewardLabel;
  final double fraction;
  final String progressLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: const BoxDecoration(
        color: RostokColors.card,
        borderRadius: RostokDimens.row,
        boxShadow: RostokDimens.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RostokText.body(
                    size: 15,
                    weight: FontWeight.w700,
                    color: RostokColors.inkText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: const BoxDecoration(
                  color: RostokColors.chipBg,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Text(
                  rewardLabel,
                  style: RostokText.body(
                    size: 12,
                    weight: FontWeight.w700,
                    color: RostokColors.chipText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(child: RostokProgressBar(fraction: fraction, height: 10)),
              const SizedBox(width: 12),
              Text(
                progressLabel,
                style: RostokText.body(
                  size: 12,
                  weight: FontWeight.w700,
                  color: RostokColors.textFaint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
