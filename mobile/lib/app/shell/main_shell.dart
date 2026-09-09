import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/kairos_theme.dart';
import 'package:flutter/services.dart';
import '../../shared/widgets/kairos_app_background.dart';
import '../../shared/widgets/kairos_bottom_navigation.dart';

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

  void _onNavigationItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/map');
        break;
      case 2:
        context.go('/sos');
        break;
      case 3:
        context.go('/reports');
        break;
      case 4:
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => const _MoreSheet(),
        );
        break;
    }
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KairosTheme.radius12)),
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
      child: KairosAppBackground(
        child: Scaffold(
          extendBody: true,
          backgroundColor: Colors.transparent,
          body: child,
          bottomNavigationBar: KairosBottomNavigation(
            currentIndex: currentIndex,
            onTap: (index) => _onNavigationItemTapped(context, index),
          ),
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
        color: KairosTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(KairosTheme.radius16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: KairosTheme.spacing24),
          const Text('MORE OPTIONS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: KairosTheme.spacing16),
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
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}
