import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/core/l10n/l10n.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/animations/fade_slide_in.dart';
import 'package:stay_alive/core/widgets/animations/pressable_scale.dart';
import 'package:stay_alive/core/widgets/animations/scale_pop.dart';
import 'package:stay_alive/core/widgets/animations/sprout_growth_animation.dart';
import 'package:stay_alive/core/widgets/app_button.dart';
import 'package:stay_alive/core/widgets/diagonal_pattern.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_state.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: AppSpacing.sm),
                FadeSlideIn(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppColors.lime,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        context.l10n.authBrandName,
                        style: context.text.titleLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                ScalePop(
                  delay: const Duration(milliseconds: 120),
                  fromScale: 0.95,
                  child: DiagonalPattern(
                    background: AppColors.mutedGreen,
                    lineColor: AppColors.green,
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                    child: SizedBox(
                      height: 200,
                      child: Center(
                        child: Container(
                          width: 130,
                          height: 130,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            // Fixed brand plate on the green panel: stays
                            // white in both themes.
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const SproutGrowthAnimation(
                            size: 76,
                            delay: Duration(milliseconds: 350),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    context.l10n.onboardingTitle,
                    textAlign: TextAlign.center,
                    style: context.text.headlineLarge,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 400),
                  child: Text(
                    context.l10n.onboardingSubtitle,
                    textAlign: TextAlign.center,
                    style: context.text.bodyMedium,
                  ),
                ),
                const Spacer(),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 550),
                  offset: 24,
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (BuildContext context, AuthState state) {
                      return PressableScale(
                        child: AppButton(
                          text: context.l10n.onboardingStartButton,
                          isLoading: state is AuthLoading,
                          onPressed: () =>
                              context.read<AuthCubit>().completeOnboarding(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
