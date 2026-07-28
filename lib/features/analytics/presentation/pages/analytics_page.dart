import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/app_states.dart';
import 'package:stay_alive/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:stay_alive/features/analytics/presentation/cubit/analytics_state.dart';
import 'package:stay_alive/shared/widgets/app_scaffold.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Аналитика',
      body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
        builder: (BuildContext context, AnalyticsState state) {
          if (state is AnalyticsLoading) {
            return const AppLoadingState();
          }

          if (state is AnalyticsError) {
            return AppErrorState(message: state.message);
          }

          if (state is AnalyticsTracked) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Событие: ${state.event.name}',
                style: AppTextStyles.bodyMedium,
              ),
            );
          }

          return const AppEmptyState(
            title: 'Пока пусто',
            message: 'В этой сессии ещё не было событий аналитики.',
          );
        },
      ),
    );
  }
}
