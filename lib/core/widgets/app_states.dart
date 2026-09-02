import 'package:flutter/material.dart';
import 'package:stay_alive/core/l10n/l10n.dart';
import 'package:stay_alive/core/motion/motion_config.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/animations/fade_slide_in.dart';
import 'package:stay_alive/core/widgets/animations/scale_pop.dart';
import 'package:stay_alive/core/widgets/app_button.dart';
import 'package:stay_alive/core/widgets/app_card.dart';
import 'package:stay_alive/core/widgets/sprout_icon.dart';

/// Branded loading state: pulsing sprout + optional message.
class AppLoadingState extends StatefulWidget {
  const AppLoadingState({this.message, super.key});

  final String? message;

  @override
  State<AppLoadingState> createState() => _AppLoadingStateState();
}

class _AppLoadingStateState extends State<AppLoadingState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  bool _configured = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_configured) {
      return;
    }
    _configured = true;
    if (MotionConfig.reduceMotionOf(context)) {
      _controller.value = 1;
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.05).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            ),
            child: const SproutIcon(size: 44),
          ),
          if (widget.message != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            Text(
              widget.message!,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

/// Friendly empty state with a sprout, short copy and an optional CTA.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const ScalePop(fromScale: 0.85, child: SproutEmblem(size: 96)),
            const SizedBox(height: AppSpacing.lg),
            FadeSlideIn(
              delay: const Duration(milliseconds: 120),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: context.text.titleMedium,
              ),
            ),
            if (message != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xl),
              FadeSlideIn(
                delay: const Duration(milliseconds: 280),
                child: SizedBox(
                  width: 220,
                  child: AppButton(text: actionLabel!, onPressed: onAction),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Calm error state: soft card, human copy and a retry button.
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    this.title,
    this.message,
    this.onRetry,
    this.retryLabel,
    super.key,
  });

  /// All three default to the generic `common*` strings when left null.
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: FadeSlideIn(
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            radius: AppRadius.xl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        theme.chipTheme.backgroundColor ??
                        theme.colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cloud_off_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  title ?? context.l10n.commonErrorTitle,
                  textAlign: TextAlign.center,
                  style: context.text.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message ?? context.l10n.commonErrorMessage,
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium,
                ),
                if (onRetry != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    text: retryLabel ?? context.l10n.commonRetry,
                    onPressed: onRetry,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded skeleton block for loading placeholders.
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    this.height = 64,
    this.width = double.infinity,
    this.radius = AppRadius.lg,
    super.key,
  });

  final double height;
  final double width;
  final double radius;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.55,
        end: 1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: theme.chipTheme.backgroundColor ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}
