import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stay_alive/core/constants/app_routes.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/app_button.dart';
import 'package:stay_alive/features/coach/domain/entities/coach_entities.dart';
import 'package:stay_alive/features/coach/presentation/cubit/coach_cubit.dart';
import 'package:stay_alive/features/coach/presentation/cubit/coach_state.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_cubit.dart';

class WeeklyInsightSection extends StatelessWidget {
  const WeeklyInsightSection({
    required this.onRequestInsights,
    super.key,
  });

  final VoidCallback onRequestInsights;

  @override
  Widget build(BuildContext context) {
    final bool isPremium =
        context.watch<SubscriptionCubit>().state.isPremiumActive;

    return BlocBuilder<CoachCubit, CoachState>(
      builder: (BuildContext context, CoachState state) {
        final List<WeeklyInsightCard> cards =
            state is CoachLoaded ? state.weeklyInsights : const <WeeklyInsightCard>[];
        final String? error =
            state is CoachLoaded ? state.errorMessage : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Недельный разбор',
                    style: AppTextStyles.titleMedium,
                  ),
                ),
                if (isPremium)
                  TextButton(
                    onPressed: onRequestInsights,
                    child: const Text('Обновить'),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (!isPremium)
              AppButton(
                text: 'Инсайты в Stay Alive Pro',
                onPressed: () => context.push(AppRoutes.premium),
              )
            else if (cards.isEmpty)
              AppButton(
                text: 'Получить разбор недели',
                onPressed: onRequestInsights,
              )
            else
              ...cards.map(
                (WeeklyInsightCard card) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(card.title, style: AppTextStyles.titleMedium),
                        const SizedBox(height: 4),
                        Text(card.body, style: AppTextStyles.bodyMedium),
                        if (card.emphasis != null) ...<Widget>[
                          const SizedBox(height: 6),
                          Text(
                            card.emphasis!,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            if (error != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                error,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
              ),
            ],
          ],
        );
      },
    );
  }
}
