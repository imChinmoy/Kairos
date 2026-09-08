import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/kairos_theme.dart';
import 'package:flutter/services.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location == '/home') return 0;
    if (location == '/map') return 1;
    if (location == '/sos') return 2;
    if (location == '/reports') return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Exit KAIROS?'),
            content: const Text('Are you sure you want to exit the application?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('EXIT', style: TextStyle(color: KairosTheme.error)),
              ),
            ],
          ),
        );
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        extendBody: true,
        body: child,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: KairosTheme.spacing16, right: KairosTheme.spacing16, bottom: KairosTheme.spacing24),
          child: Container(
            decoration: BoxDecoration(
              color: KairosTheme.cardWhite,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: KairosTheme.borderGrey, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: KairosTheme.textPrimary.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    _NavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: 'Home',
                      isActive: currentIndex == 0,
                      onTap: () => context.go('/home'),
                    ),
                    _NavItem(
                      icon: Icons.map_outlined,
                      activeIcon: Icons.map_rounded,
                      label: 'Map',
                      isActive: currentIndex == 1,
                      onTap: () => context.go('/map'),
                    ),
                    // SOS — center prominent button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.go('/sos'),
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: KairosTheme.sosRed,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.sos_rounded,
                              color: KairosTheme.cardWhite,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _NavItem(
                      icon: Icons.description_outlined,
                      activeIcon: Icons.description_rounded,
                      label: 'Reports',
                      isActive: currentIndex == 3,
                      onTap: () => context.go('/reports'),
                    ),
                    _NavItem(
                      icon: Icons.more_horiz,
                      activeIcon: Icons.more_horiz,
                      label: 'More',
                      isActive: false,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const _MoreSheet(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? KairosTheme.primaryNavy : KairosTheme.textMuted,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? KairosTheme.primaryNavy : KairosTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreSheet extends StatelessWidget {
  const _MoreSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KairosTheme.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          const Text('More Options', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 16),
          _MoreItem(
            icon: Icons.list_alt_outlined,
            label: 'All Investigations',
            onTap: () { context.pop(); context.go('/investigations'); },
          ),
          _MoreItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () => context.pop(),
          ),
          _MoreItem(
            icon: Icons.info_outline,
            label: 'About KAIROS',
            onTap: () => context.pop(),
          ),
        ],
      ),
    );
  }
}

class _MoreItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MoreItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: KairosTheme.oceanBlue),
      title: Text(label),
      onTap: onTap,
    );
  }
}
