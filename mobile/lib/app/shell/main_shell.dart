import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/kairos_theme.dart';

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

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: KairosTheme.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  isActive: currentIndex == 0,
                  onTap: () => context.go('/home'),
                ),
                _NavItem(
                  icon: Icons.map_outlined,
                  activeIcon: Icons.map,
                  label: 'Map',
                  isActive: currentIndex == 1,
                  onTap: () => context.go('/map'),
                ),
                // SOS — center prominent button
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.go('/sos'),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: KairosTheme.sosRed,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: KairosTheme.sosRed.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'SOS',
                              style: TextStyle(
                                color: KairosTheme.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Emergency',
                          style: TextStyle(
                            fontSize: 9,
                            color: KairosTheme.sosRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _NavItem(
                  icon: Icons.description_outlined,
                  activeIcon: Icons.description,
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
                      builder: (_) => const _MoreSheet(),
                    );
                  },
                ),
              ],
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
              color: isActive ? KairosTheme.oceanBlue : KairosTheme.textMuted,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? KairosTheme.oceanBlue : KairosTheme.textMuted,
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
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
