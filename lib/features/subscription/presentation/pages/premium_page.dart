import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/features/subscription/domain/entities/subscription_package.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_state.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stay Alive Premium')),
      body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
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
          return SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (int value) {
                      setState(() {
                        _pageIndex = value;
                      });
                    },
                    children: const <Widget>[
                      _PaywallBenefitPage(
                        icon: Icons.query_stats,
                        title: 'See your full nutrition story',
                        description:
                            'Unlock complete weekly, monthly, and yearly stats '
                            'so every healthy choice becomes visible.',
                      ),
                      _PaywallBenefitPage(
                        icon: Icons.local_fire_department,
                        title: 'Build streaks that last',
                        description:
                            'Premium insights show what keeps your fruit, '
                            'vegetable, grain, and bean habits consistent.',
                      ),
                      _PaywallBenefitPage(
                        icon: Icons.workspace_premium,
                        title: 'Turn tracking into progress',
                        description:
                            'Level up with gamified progress, badges, and '
                            'deeper trends built for long-term motivation.',
                      ),
                    ],
                  ),
                ),
                _PageDots(activeIndex: _pageIndex, count: 3),
                _SubscriptionPanel(state: state),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PaywallBenefitPage extends StatelessWidget {
  const _PaywallBenefitPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 72, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.activeIndex,
    required this.count,
  });

  final int activeIndex;
  final int count;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: index == activeIndex ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: index == activeIndex
                ? activeColor
                : activeColor.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _SubscriptionPanel extends StatelessWidget {
  const _SubscriptionPanel({
    required this.state,
  });

  final SubscriptionState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<SubscriptionPackage> packages = state.offering.packages;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: <BoxShadow>[
          BoxShadow(
            blurRadius: 24,
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (state.isPremiumActive)
            const _PremiumActiveBanner()
          else ...<Widget>[
            if (state.status == SubscriptionStatus.loading &&
                packages.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else
              ...packages.map(
                (SubscriptionPackage package) => _PlanTile(
                  package: package,
                  isSelected: state.selectedPackageId == package.id,
                  isBusy: state.status == SubscriptionStatus.purchasing &&
                      state.selectedPackageId == package.id,
                  onTap: () => context
                      .read<SubscriptionCubit>()
                      .selectPackage(package.id),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: state.selectedPackage == null ||
                        state.status == SubscriptionStatus.purchasing
                    ? null
                    : () => context
                        .read<SubscriptionCubit>()
                        .purchaseSelectedPackage(),
                child: state.status == SubscriptionStatus.purchasing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        state.selectedPackage == null
                            ? 'Choose a plan'
                            : 'Continue with ${state.selectedPackage!.priceLabel}',
                      ),
              ),
            ),
            TextButton(
              onPressed: state.status == SubscriptionStatus.restoring
                  ? null
                  : () => context.read<SubscriptionCubit>().restore(),
              child: const Text('Restore purchases'),
            ),
            if (!state.offering.isConfigured)
              Text(
                'RevenueCat products must be configured before live purchases.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
          ],
        ],
      ),
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
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: isSelected ? 3 : 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: RadioListTile<String>(
        value: package.id,
        groupValue: isSelected ? package.id : null,
        onChanged: (_) => onTap(),
        title: Row(
          children: <Widget>[
            Expanded(child: Text(package.title)),
            Text(package.priceLabel),
          ],
        ),
        subtitle: Text('${package.periodLabel} • ${package.description}'),
        secondary: isBusy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : package.savingsLabel.isEmpty
                ? null
                : Chip(label: Text(package.savingsLabel)),
      ),
    );
  }
}

class _PremiumActiveBanner extends StatelessWidget {
  const _PremiumActiveBanner();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: <Widget>[
            Icon(Icons.verified),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Premium is active. Full statistics are unlocked.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
