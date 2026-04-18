import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stay_alive/features/daily_tracker/presentation/pages/home_page.dart';
import 'package:stay_alive/features/user/presentation/pages/profile_page.dart';

/// Main app shell with bottom navigation: home, profile, and logout.
class MainShellPage extends StatefulWidget {
  const MainShellPage({this.initialIndex = 0, super.key});

  /// `0` = home, `1` = profile. Logout is not a tab index.
  final int initialIndex;

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  static const int _logoutDestinationIndex = 2;

  late int _tabIndex;
  Widget? _homePage;
  Widget? _profilePage;

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialIndex.clamp(0, 1);
    _ensureTabInitialized(_tabIndex);
  }

  void _ensureTabInitialized(int index) {
    if (index == 0) {
      _homePage ??= const HomePage();
      return;
    }

    if (index == 1) {
      _profilePage ??= const ProfilePage();
    }
  }

  Future<void> _onLogoutPressed() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    await context.read<AuthCubit>().logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: <Widget>[
          _homePage ?? const SizedBox.shrink(),
          _profilePage ?? const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (int index) {
          if (index == _logoutDestinationIndex) {
            _onLogoutPressed();
            return;
          }
          _ensureTabInitialized(index);
          setState(() {
            _tabIndex = index;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'My Profile',
          ),
          NavigationDestination(icon: Icon(Icons.logout), label: 'Log out'),
        ],
      ),
    );
  }
}
