import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stay_alive/core/theme/app_colors.dart';
import 'package:stay_alive/core/theme/app_spacing.dart';
import 'package:stay_alive/core/theme/app_text_styles.dart';
import 'package:stay_alive/core/widgets/animations/pressable_scale.dart';
import 'package:stay_alive/features/daily_tracker/presentation/pages/home_page.dart';
import 'package:stay_alive/features/history/presentation/pages/history_page.dart';
import 'package:stay_alive/features/user/presentation/pages/profile_page.dart';

/// Main app shell with the soft «Росток» bottom navigation:
/// home, statistics, and profile.
class MainShellPage extends StatefulWidget {
  const MainShellPage({this.initialIndex = 0, super.key});

  /// `0` = home, `1` = statistics, `2` = profile.
  final int initialIndex;

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  late int _tabIndex;
  Widget? _homePage;
  Widget? _historyPage;
  Widget? _profilePage;

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialIndex.clamp(0, 2);
    _ensureTabInitialized(_tabIndex);
  }

  void _ensureTabInitialized(int index) {
    switch (index) {
      case 0:
        _homePage ??= const HomePage();
      case 1:
        _historyPage ??= const HistoryPage();
      case 2:
        _profilePage ??= const ProfilePage();
    }
  }

  void _onTabSelected(int index) {
    if (index == _tabIndex) {
      return;
    }
    HapticFeedback.selectionClick();
    _ensureTabInitialized(index);
    setState(() {
      _tabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = <Widget>[
      _homePage ?? const SizedBox.shrink(),
      _historyPage ?? const SizedBox.shrink(),
      _profilePage ?? const SizedBox.shrink(),
    ];
    return Scaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: <Widget>[
          // IndexedStack keeps every tab mounted, so a hidden tab's tickers
          // would otherwise animate forever against an invisible surface.
          for (int i = 0; i < tabs.length; i++)
            TickerMode(enabled: i == _tabIndex, child: tabs[i]),
        ],
      ),
      bottomNavigationBar: _RostokNavBar(
        index: _tabIndex,
        onSelected: _onTabSelected,
      ),
    );
  }
}

class _RostokNavBar extends StatelessWidget {
  const _RostokNavBar({required this.index, required this.onSelected});

  final int index;
  final ValueChanged<int> onSelected;

  static const List<(IconData, IconData, String)> _tabs =
      <(IconData, IconData, String)>[
        (Icons.eco_outlined, Icons.eco_rounded, 'Главная'),
        (Icons.insights_outlined, Icons.insights_rounded, 'Статистика'),
        (Icons.person_outline_rounded, Icons.person_rounded, 'Профиль'),
      ];

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        bottomInset > 0 ? bottomInset : AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < _tabs.length; i++)
            Expanded(
              child: _NavItem(
                icon: _tabs[i].$1,
                selectedIcon: _tabs[i].$2,
                label: _tabs[i].$3,
                selected: i == index,
                onTap: () => onSelected(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: PressableScale(
        onTap: onTap,
        pressedScale: 0.94,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppColors.lime : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Icon(
                selected ? selectedIcon : icon,
                size: 24,
                color: selected ? AppColors.dark : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 11,
                color: selected ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
