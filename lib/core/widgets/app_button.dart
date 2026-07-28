import 'package:flutter/material.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/animations/pressable_scale.dart';

enum AppButtonVariant {
  /// Dark CTA on light backgrounds.
  dark,

  /// Lime CTA on dark backgrounds (rewards, level up).
  lime,

  /// Subtle white button.
  light,
}

/// Primary rounded button of the design system.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.dark,
    this.icon,
    this.isLoading = false,
    this.height = 56,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? icon;
  final bool isLoading;
  final double height;

  @override
  Widget build(BuildContext context) {
    final Color background = switch (variant) {
      AppButtonVariant.dark => AppColors.dark,
      AppButtonVariant.lime => AppColors.lime,
      AppButtonVariant.light => AppColors.white,
    };

    final Color foreground = switch (variant) {
      AppButtonVariant.dark => AppColors.white,
      AppButtonVariant.lime => AppColors.dark,
      AppButtonVariant.light => AppColors.dark,
    };

    return PressableScale(
      enabled: onPressed != null && !isLoading,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: background,
            foregroundColor: foreground,
            disabledBackgroundColor: AppColors.border,
            disabledForegroundColor: AppColors.textMuted,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      variant == AppButtonVariant.dark
                          ? AppColors.lime
                          : AppColors.dark,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (icon != null) ...<Widget>[
                      icon!,
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Flexible(
                      child: Text(
                        text,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: foreground,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
