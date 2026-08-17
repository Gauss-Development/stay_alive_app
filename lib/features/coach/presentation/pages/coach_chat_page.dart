import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stay_alive/core/constants/app_routes.dart';
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
        title: 'AI-коуч',
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Чат с коучем — часть Stay Alive Pro',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Персональные советы, разборы недели и квесты сада. '
                'Это мотивация по Daily Dozen, не медицинские рекомендации.',
                style: AppTextStyles.bodyMedium,
              ),
              const Spacer(),
              AppButton(
                text: 'Открыть Premium',
                onPressed: () => context.push(AppRoutes.premium),
              ),
            ],
          ),
        ),
      );
    }

    return AppScaffold(
      title: 'AI-коуч',
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
              'Коуч помогает с привычкой Daily Dozen. Не заменяет врача.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
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
                        'Спроси, что добрать сегодня или как удержать серию.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium,
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
                          color: mine ? AppColors.green : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          msg.text,
                          style: AppTextStyles.bodyMedium.copyWith(
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
                      decoration: const InputDecoration(
                        hintText: 'Напиши коучу…',
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
