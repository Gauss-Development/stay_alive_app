import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stay_alive/core/constants/app_routes.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/features/coach/domain/entities/coach_entities.dart';
import 'package:stay_alive/features/coach/presentation/cubit/coach_cubit.dart';
import 'package:stay_alive/features/coach/presentation/cubit/coach_state.dart';

/// Soft banner for free/premium nudges after logging.
class CoachNudgeBanner extends StatelessWidget {
  const CoachNudgeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoachCubit, CoachState>(
      buildWhen: (CoachState previous, CoachState current) {
        final CoachResponse? prev =
            previous is CoachLoaded ? previous.lastNudge : null;
        final CoachResponse? next =
            current is CoachLoaded ? current.lastNudge : null;
        return prev != next;
      },
      builder: (BuildContext context, CoachState state) {
        if (state is! CoachLoaded || state.lastNudge == null) {
          return const SizedBox.shrink();
        }
        final CoachResponse nudge = state.lastNudge!;
        return Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(Icons.spa_rounded, color: AppColors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Коуч Ростка', style: AppTextStyles.titleMedium),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => context.read<CoachCubit>().dismissNudge(),
                      icon: const Icon(Icons.close_rounded, size: 18),
                    ),
                  ],
                ),
                Text(nudge.message, style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(AppRoutes.coach),
                    child: const Text('Открыть чат'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
