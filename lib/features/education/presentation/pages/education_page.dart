import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/core/l10n/l10n.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/app_states.dart';
import 'package:stay_alive/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:stay_alive/features/coach/domain/services/coach_context_builder.dart';
import 'package:stay_alive/features/coach/presentation/cubit/coach_cubit.dart';
import 'package:stay_alive/features/coach/presentation/cubit/coach_state.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:stay_alive/shared/widgets/app_scaffold.dart';

class EducationPage extends StatefulWidget {
  const EducationPage({required this.categoryId, super.key});

  final String categoryId;

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
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
      context.read<CoachCubit>().loadEducationTip(
        context: CoachContextBuilder.build(
          overview: null,
          categoryId: widget.categoryId,
        ),
        isPremium: isPremium,
      );
      context.read<AnalyticsCubit>().track(
        eventName: 'coach_education_tip',
        screenName: 'education',
        metadata: <String, dynamic>{'categoryId': widget.categoryId},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: context.l10n.educationTitle,
      body: BlocBuilder<CoachCubit, CoachState>(
        builder: (BuildContext context, CoachState state) {
          if (state is CoachLoading) {
            return AppLoadingState(message: context.l10n.educationLoading);
          }
          final String? tip = state is CoachLoaded ? state.educationTip : null;
          if (tip == null || tip.isEmpty) {
            return AppEmptyState(
              title: context.l10n.educationEmptyTitle,
              message: context.l10n.educationEmptyMessage(widget.categoryId),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screen),
            children: <Widget>[
              Text(widget.categoryId, style: context.text.headlineMedium),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.outlineVariant),
                ),
                child: Text(tip, style: context.text.bodyLarge),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                context.l10n.educationDisclaimer,
                style: context.text.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}
