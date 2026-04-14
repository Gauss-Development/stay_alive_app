import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stay_alive/core/constants/app_routes.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stay_alive/features/auth/presentation/cubit/app_startup_cubit.dart';
import 'package:stay_alive/features/auth/presentation/cubit/app_startup_state.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppStartupCubit, AppStartupState>(
      listenWhen: (AppStartupState previous, AppStartupState current) =>
          previous.destination != current.destination,
      listener: (BuildContext context, AppStartupState state) {
        switch (state.destination) {
          case StartupDestination.login:
            context.go(AppRoutes.login);
          case StartupDestination.onboarding:
            if (state.user != null) {
              context.read<AuthCubit>().restoreAuthenticatedUser(state.user!);
            }
            context.go(AppRoutes.onboarding);
          case StartupDestination.home:
            if (state.user != null) {
              context.read<AuthCubit>().restoreAuthenticatedUser(state.user!);
            }
            context.go(AppRoutes.home);
          case StartupDestination.none:
            break;
        }
      },
      child: Scaffold(
        body: Center(
          child: BlocBuilder<AppStartupCubit, AppStartupState>(
            builder: (BuildContext context, AppStartupState state) {
              if (state.status == StartupStatus.error) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.message ?? 'Could not initialize app.',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Preparing your daily tracker...'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
