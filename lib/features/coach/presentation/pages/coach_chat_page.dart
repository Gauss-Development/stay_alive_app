import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/features/subscription/presentation/paywall.dart';
import 'package:stay_alive/core/l10n/l10n.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/app_button.dart';
import 'package:stay_alive/features/coach/domain/services/coach_context_builder.dart';
import 'package:stay_alive/features/coach/presentation/cubit/coach_cubit.dart';
import 'package:stay_alive/features/coach/presentation/cubit/coach_state.dart';
import 'package:stay_alive/features/daily_tracker/presentation/cubit/daily_tracker_cubit.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_cubit.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_state.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:stay_alive/shared/widgets/app_scaffold.dart';

class CoachChatPage extends StatefulWidget {
  const CoachChatPage({super.key});

  @override
  State<CoachChatPage> createState() => _CoachChatPageState();
}

class _CoachChatPageState extends State<CoachChatPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPremium =
        context.watch<SubscriptionCubit>().state.isPremiumActive;

    if (!isPremium) {
      return AppScaffold(
        title: context.l10n.coachTitle,
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                context.l10n.coachPaywallTitle,
                style: context.text.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.l10n.coachPaywallDescription,
                style: context.text.bodyMedium,
              ),
              const Spacer(),
              AppButton(
                text: context.l10n.coachPaywallCta,
                onPressed: () => showPaywall(context),
              ),
            ],
          ),
        ),
      );
    }

    return AppScaffold(
      title: context.l10n.coachTitle,
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.sm,
              AppSpacing.screen,
              0,
            ),
            child: Text(
              context.l10n.coachChatDisclaimer,
              style: context.text.bodySmall,
            ),
          ),
          Expanded(
            child: BlocBuilder<CoachCubit, CoachState>(
              builder: (BuildContext context, CoachState state) {
                if (state is CoachLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = state is CoachLoaded
                    ? state.messages
                    : const [];
                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.screen),
                      child: Text(
                        context.l10n.coachChatEmptyHint,
                        textAlign: TextAlign.center,
                        style: context.text.bodyMedium,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.screen),
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final msg = messages[index];
                    final bool mine = msg.role == 'user';
                    return Align(
                      alignment:
                          mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
                        ),
                        decoration: BoxDecoration(
                          color: mine
                              ? AppColors.green
                              : context.colors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          msg.text,
                          // The green bubble is a fixed brand chip in both
                          // themes, so its ink stays white.
                          style: context.text.bodyMedium?.copyWith(
                            color: mine ? Colors.white : null,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                0,
                AppSpacing.screen,
                AppSpacing.md,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: context.l10n.coachChatInputHint,
                      ),
                      onSubmitted: (_) => _send(isPremium),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _send(isPremium),
                    icon: const Icon(Icons.send_rounded),
                    color: AppColors.green,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _send(bool isPremium) {
    final String text = _controller.text;
    _controller.clear();
    final gState = context.read<GamificationCubit>().state;
    context.read<CoachCubit>().sendChat(
          message: text,
          context: CoachContextBuilder.build(
            overview: gState is GamificationLoaded ? gState.overview : null,
            todayLog: context.read<DailyTrackerCubit>().state.log,
            userMessage: text,
          ),
          isPremium: isPremium,
        );
  }
}
