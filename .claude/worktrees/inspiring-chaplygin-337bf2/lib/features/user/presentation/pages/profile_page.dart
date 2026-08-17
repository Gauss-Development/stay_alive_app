import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stay_alive/core/constants/app_routes.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_state.dart';
import 'package:stay_alive/features/user/presentation/cubit/user_profile_cubit.dart';
import 'package:stay_alive/features/user/presentation/cubit/user_profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<UserProfileCubit>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<UserProfileCubit, UserProfileState>(
        builder: (BuildContext context, UserProfileState state) {
          if (state is UserProfileLoading || state is UserProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UserProfileError) {
            return Center(child: Text(state.message));
          }
          if (state is! UserProfileLoaded) {
            return const SizedBox.shrink();
          }

          final profile = state.profile;
          final String weightText = profile.weightKg == null
              ? '—'
              : '${profile.weightKg!.toStringAsFixed(1)} kg';
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(
                profile.displayName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(profile.email),
              const SizedBox(height: 16),
              Text('Age: ${profile.age?.toString() ?? '—'}'),
              Text('Weight: $weightText'),
              if (profile.heightCm != null)
                Text('Height: ${profile.heightCm} cm'),
              if (profile.gender != null) Text('Gender: ${profile.gender}'),
              if (profile.preferredDiet != null)
                Text('Diet: ${profile.preferredDiet}'),
              Text('Locale: ${profile.locale}'),
              Text('Units: ${profile.unitsPreference}'),
              Text(
                'Onboarding completed: '
                '${profile.onboardingCompleted ? 'Yes' : 'No'}',
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.push(AppRoutes.progress),
                icon: const Icon(Icons.emoji_events_outlined),
                label: const Text('View Progress & Badges'),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const _DeleteAccountButton(),
            ],
          );
        },
      ),
    );
  }
}

class _DeleteAccountButton extends StatelessWidget {
  const _DeleteAccountButton();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
          previous != current &&
          (current is AuthError || current is AuthUnauthenticated),
      listener: (BuildContext context, AuthState state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not delete account: ${state.message}')),
          );
        }
      },
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.error,
          side: BorderSide(color: colors.error),
          minimumSize: const Size.fromHeight(48),
        ),
        icon: const Icon(Icons.delete_forever_outlined),
        label: const Text('Delete account'),
        onPressed: () => _confirm(context),
      ),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        final ColorScheme colors = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: const Text('Delete your account?'),
          content: const Text(
            'This permanently deletes your profile, daily logs, history, '
            'gamification progress, and subscription record. This cannot be '
            'undone.\n\nActive App Store / Play Store subscriptions are not '
            'cancelled by deleting the account — manage them in your store '
            'subscription settings.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: colors.error),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<AuthCubit>().deleteAccount();
  }
}
