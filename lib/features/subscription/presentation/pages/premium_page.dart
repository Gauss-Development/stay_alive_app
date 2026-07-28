import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/animations/fade_slide_in.dart';
import 'package:stay_alive/core/widgets/animations/pressable_scale.dart';
import 'package:stay_alive/core/widgets/animations/scale_pop.dart';
import 'package:stay_alive/core/widgets/animations/staggered_list.dart';
import 'package:stay_alive/core/widgets/app_badge.dart';
import 'package:stay_alive/core/widgets/app_button.dart';
import 'package:stay_alive/core/widgets/app_icon_button.dart';
import 'package:stay_alive/core/widgets/diagonal_pattern.dart';
import 'package:stay_alive/core/widgets/sprout_icon.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_package.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_state.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SubscriptionCubit>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<SubscriptionCubit, SubscriptionState>(
          listenWhen: (SubscriptionState previous, SubscriptionState current) =>
              previous.errorMessage != current.errorMessage &&
              current.errorMessage != null,
          listener: (BuildContext context, SubscriptionState state) {
            final String? message = state.errorMessage;
            if (message != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
            }
          },
          builder: (BuildContext context, SubscriptionState state) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                AppSpacing.xl,
              ),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    AppIconButton(
                      icon: Icons.chevron_left_rounded,
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        }
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: Text('Premium', style: AppTextStyles.titleLarge),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const ScalePop(
                  delay: Duration(milliseconds: 60),
                  fromScale: 0.96,
                  child: _PremiumHeroCard(),
                ),
                const SizedBox(height: AppSpacing.xl),
                const StaggeredFadeSlide(
                  index: 0,
                  baseDelay: Duration(milliseconds: 200),
                  child: _BenefitTile(
                    icon: Icons.query_stats_rounded,
                    tint: AppColors.blue,
                    title: 'Вся история твоего прогресса',
                    description:
                        'Графики за неделю, месяц и год — каждый полезный '
                        'выбор становится заметным.',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const StaggeredFadeSlide(
                  index: 1,
                  baseDelay: Duration(milliseconds: 200),
                  child: _BenefitTile(
                    icon: Icons.local_fire_department_rounded,
                    tint: AppColors.softYellow,
                    title: 'Серии, которые не обрываются',
                    description:
                        'Инсайты помогают понять, что держит привычку, '
                        'плюс заморозки для сложных дней.',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const StaggeredFadeSlide(
                  index: 2,
                  baseDelay: Duration(milliseconds: 200),
                  child: _BenefitTile(
                    icon: Icons.workspace_premium_rounded,
                    tint: AppColors.purple,
                    title: 'Больше очков за каждый день',
                    description:
                        'Бонусный множитель очков, эксклюзивные челленджи '
                        'и награды.',
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 420),
                  child: _SubscriptionPanel(state: state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PremiumHeroCard extends StatelessWidget {
  const _PremiumHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lime.withValues(alpha: 0.14),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const AppBadge(label: 'РОСТОК PREMIUM', onDark: true),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Расти быстрее',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Статистика, бонусные очки и челленджи',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.lime,
                    shape: BoxShape.circle,
                  ),
                  child: const SproutIcon(size: 28, color: AppColors.dark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({
    required this.icon,
    required this.tint,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: AppColors.textPrimary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(description, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionPanel extends StatelessWidget {
  const _SubscriptionPanel({required this.state});

  final SubscriptionState state;

  @override
  Widget build(BuildContext context) {
    final List<SubscriptionPackage> packages = state.offering.packages;

    if (state.isPremiumActive) {
      return const _PremiumActiveBanner();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (state.status == SubscriptionViewStatus.loading && packages.isEmpty)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.green),
            ),
          )
        else
          for (final SubscriptionPackage package in packages)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _PlanTile(
                package: package,
                isSelected: state.selectedPackageId == package.id,
                isBusy:
                    state.status == SubscriptionViewStatus.purchasing &&
                    state.selectedPackageId == package.id,
                onTap: () =>
                    context.read<SubscriptionCubit>().selectPackage(package.id),
              ),
            ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          text: state.selectedPackage == null
              ? 'Выбери план'
              : 'Продолжить за ${state.selectedPackage!.priceLabel}',
          isLoading: state.status == SubscriptionViewStatus.purchasing,
          onPressed: state.selectedPackage == null
              ? null
              : () =>
                    context.read<SubscriptionCubit>().purchaseSelectedPackage(),
        ),
        TextButton(
          onPressed: state.status == SubscriptionViewStatus.restoring
              ? null
              : () => context.read<SubscriptionCubit>().restore(),
          child: const Text('Восстановить покупки'),
        ),
        if (!state.offering.isConfigured)
          Text(
            'Продукты RevenueCat должны быть настроены до живых покупок.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
          ),
      ],
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.package,
    required this.isSelected,
    required this.isBusy,
    required this.onTap,
  });

  final SubscriptionPackage package;
  final bool isSelected;
  final bool isBusy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.dark : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.dark : AppColors.white,
                border: Border.all(
                  color: isSelected ? AppColors.dark : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: AppColors.lime,
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    package.title,
                    style: AppTextStyles.bodyLarge.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${package.periodLabel} · ${package.description}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (isBusy)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.green,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(package.priceLabel, style: AppTextStyles.titleMedium),
                  if (package.savingsLabel.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lime,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        package.savingsLabel,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.dark,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _PremiumActiveBanner extends StatelessWidget {
  const _PremiumActiveBanner();

  @override
  Widget build(BuildContext context) {
    return DiagonalPattern(
      background: AppColors.mutedGreen,
      lineColor: AppColors.green,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_rounded, color: AppColors.green),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Premium активен. Вся статистика открыта!',
                style: AppTextStyles.bodyLarge.copyWith(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
