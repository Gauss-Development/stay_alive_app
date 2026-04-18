import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(profile.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(profile.email),
              const SizedBox(height: 16),
              Text('Age: ${profile.age}'),
              Text('Weight: ${profile.weightKg} kg'),
              if (profile.heightCm != null) Text('Height: ${profile.heightCm} cm'),
              if (profile.gender != null) Text('Gender: ${profile.gender}'),
              if (profile.preferredDiet != null) Text('Diet: ${profile.preferredDiet}'),
              Text('Locale: ${profile.locale ?? '—'}'),
              Text('Units: ${profile.unitsPreference ?? '—'}'),
              Text('Onboarding completed: ${profile.onboardingCompleted ? 'Yes' : 'No'}'),
            ],
          );
        },
      ),
    );
  }
}
