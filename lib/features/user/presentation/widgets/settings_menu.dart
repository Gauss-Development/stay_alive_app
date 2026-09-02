import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stay_alive/core/l10n/l10n.dart';
import 'package:stay_alive/core/settings/app_settings.dart';
import 'package:stay_alive/core/settings/settings_cubit.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/app_card.dart';
import 'package:stay_alive/core/widgets/app_section_header.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:stay_alive/features/subscription/presentation/cubit/subscription_state.dart';
import 'package:stay_alive/features/subscription/presentation/paywall.dart';
import 'package:url_launcher/url_launcher.dart';

/// Language names stay in their own language on every screen — a Spanish
/// speaker looking for their language scans for "Español", not "Испанский".
const Map<String, String> _languageEndonyms = <String, String>{
  'ru': 'Русский',
  'en': 'English',
  'es': 'Español',
  'fr': 'Français',
  'de': 'Deutsch',
};

/// User menu on the profile screen: language, theme, account, subscription.
class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final AppSettings settings = context.watch<SettingsCubit>().state;
    final SubscriptionState subscription =
        context.watch<SubscriptionCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppSectionHeader(title: context.l10n.settingsTitle),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: <Widget>[
              _SettingsRow(
                icon: Icons.language_rounded,
                label: context.l10n.settingsLanguage,
                value: settings.locale == null
                    ? context.l10n.settingsSystemDefault
                    : _languageEndonyms[settings.locale!.languageCode] ??
                        settings.locale!.languageCode,
                onTap: () => _showLanguageSheet(context),
              ),
              const _RowDivider(),
              _SettingsRow(
                icon: Icons.brightness_6_rounded,
                label: context.l10n.settingsTheme,
                value: _themeLabel(context, settings.themeMode),
                onTap: () => _showThemeSheet(context),
              ),
              const _RowDivider(),
              _SettingsRow(
                icon: Icons.workspace_premium_rounded,
                label: context.l10n.settingsSubscription,
                value: subscription.isPremiumActive
                    ? context.l10n.settingsSubscriptionActive
                    : context.l10n.settingsSubscriptionFree,
                onTap: () => _showSubscriptionSheet(context),
              ),
              const _RowDivider(),
              _SettingsRow(
                icon: Icons.manage_accounts_rounded,
                label: context.l10n.settingsAccount,
                onTap: () => _showAccountSheet(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _themeLabel(BuildContext context, ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => context.l10n.settingsSystemDefault,
      ThemeMode.light => context.l10n.settingsThemeLight,
      ThemeMode.dark => context.l10n.settingsThemeDark,
    };
  }

  Future<void> _showLanguageSheet(BuildContext context) {
    final SettingsCubit cubit = context.read<SettingsCubit>();
    final Locale? current = cubit.state.locale;
    return _showSheet(
      context,
      title: context.l10n.settingsLanguage,
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _ChoiceRow(
            label: sheetContext.l10n.settingsSystemDefault,
            selected: current == null,
            onTap: () {
              cubit.setLocale(null);
              Navigator.of(sheetContext).pop();
            },
          ),
          for (final Locale locale in supportedLocales)
            _ChoiceRow(
              label: _languageEndonyms[locale.languageCode] ??
                  locale.languageCode,
              selected: current?.languageCode == locale.languageCode,
              onTap: () {
                cubit.setLocale(locale);
                Navigator.of(sheetContext).pop();
              },
            ),
        ],
      ),
    );
  }

  Future<void> _showThemeSheet(BuildContext context) {
    final SettingsCubit cubit = context.read<SettingsCubit>();
    final ThemeMode current = cubit.state.themeMode;
    return _showSheet(
      context,
      title: context.l10n.settingsTheme,
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final ThemeMode mode in ThemeMode.values)
            _ChoiceRow(
              label: _themeLabel(sheetContext, mode),
              selected: current == mode,
              onTap: () {
                cubit.setThemeMode(mode);
                Navigator.of(sheetContext).pop();
              },
            ),
        ],
      ),
    );
  }

  Future<void> _showSubscriptionSheet(BuildContext context) {
    final SubscriptionCubit cubit = context.read<SubscriptionCubit>();
    final SubscriptionState state = cubit.state;
    final DateTime? expiresAt = state.info.expiresAt;
    final String? managementUrl = state.info.managementUrl;

    return _showSheet(
      context,
      title: context.l10n.settingsSubscription,
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              state.isPremiumActive
                  ? sheetContext.l10n.settingsSubscriptionActive
                  : sheetContext.l10n.settingsSubscriptionFree,
              style: sheetContext.text.titleMedium,
            ),
          ),
          if (state.isPremiumActive && expiresAt != null) ...<Widget>[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                sheetContext.l10n.settingsSubscriptionExpires(
                  DateFormat.yMMMd().format(expiresAt),
                ),
                style: sheetContext.text.bodySmall,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          if (!state.isPremiumActive)
            _ActionRow(
              icon: Icons.workspace_premium_rounded,
              label: sheetContext.l10n.coachPaywallCta,
              onTap: () {
                Navigator.of(sheetContext).pop();
                showPaywall(context);
              },
            ),
          // The store owns cancellation and plan changes; RevenueCat hands us
          // the deep link into the right App Store / Play page.
          _ActionRow(
            icon: Icons.open_in_new_rounded,
            label: sheetContext.l10n.settingsManageSubscription,
            enabled: managementUrl != null,
            subtitle: managementUrl == null
                ? sheetContext.l10n.settingsManageUnavailable
                : null,
            onTap: () async {
              final NavigatorState navigator = Navigator.of(sheetContext);
              final bool opened = await launchUrl(
                Uri.parse(managementUrl!),
                mode: LaunchMode.externalApplication,
              );
              navigator.pop();
              if (!opened && context.mounted) {
                _toast(context, context.l10n.profileLinkOpenFailed);
              }
            },
          ),
          _ActionRow(
            icon: Icons.restore_rounded,
            label: sheetContext.l10n.settingsRestorePurchases,
            onTap: () {
              Navigator.of(sheetContext).pop();
              cubit.restore();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showAccountSheet(BuildContext context) {
    final AuthCubit authCubit = context.read<AuthCubit>();
    return _showSheet(
      context,
      title: context.l10n.settingsAccount,
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _ActionRow(
            icon: Icons.logout_rounded,
            label: sheetContext.l10n.settingsSignOut,
            onTap: () async {
              Navigator.of(sheetContext).pop();
              final bool confirmed = await _confirm(
                context,
                title: context.l10n.settingsSignOutConfirmTitle,
                body: context.l10n.settingsSignOutConfirmBody,
                confirmLabel: context.l10n.settingsSignOut,
              );
              if (confirmed) {
                await authCubit.logout();
              }
            },
          ),
          _ActionRow(
            icon: Icons.delete_outline_rounded,
            label: sheetContext.l10n.profileDeleteAccount,
            destructive: true,
            onTap: () async {
              Navigator.of(sheetContext).pop();
              final bool confirmed = await _confirm(
                context,
                title: context.l10n.profileDeleteAccountConfirmTitle,
                body: context.l10n.profileDeleteAccountConfirmBody,
                confirmLabel: context.l10n.commonDelete,
                destructive: true,
              );
              if (confirmed) {
                await authCubit.deleteAccount();
              }
            },
          ),
        ],
      ),
    );
  }
}

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(dialogContext.l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            confirmLabel,
            style: destructive
                ? const TextStyle(color: AppColors.error)
                : null,
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<void> _showSheet(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext sheetContext) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Text(title, style: sheetContext.text.titleLarge),
            ),
            builder(sheetContext),
          ],
        ),
      ),
    ),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 22, color: context.colors.onSurfaceVariant),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(label, style: context.text.bodyLarge)),
            if (value != null)
              Flexible(
                child: Text(
                  value!,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium,
                ),
              ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: context.colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: AppSpacing.lg, endIndent: 0);
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: context.text.bodyLarge),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: AppColors.green)
          : null,
      onTap: onTap,
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.enabled = true,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final bool enabled;
  final bool destructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = destructive
        ? context.colors.error
        : context.colors.onSurface;
    final Color disabled = context.colors.onSurfaceVariant;
    return ListTile(
      enabled: enabled,
      leading: Icon(icon, color: enabled ? color : disabled),
      title: Text(
        label,
        style: context.text.bodyLarge?.copyWith(
          color: enabled ? color : disabled,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: context.text.bodySmall),
      onTap: enabled ? onTap : null,
    );
  }
}
