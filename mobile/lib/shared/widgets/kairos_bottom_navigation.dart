import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/kairos_theme.dart';

class KairosBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const KairosBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      margin: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: bottomPadding == 0 ? 20 : bottomPadding + 8,
      ),
      decoration: BoxDecoration(
        color: KairosTheme.surfaceWhite.withOpacity(0.85),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: KairosTheme.primaryNavy.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: onTap,
              backgroundColor: Colors.transparent,
              selectedItemColor: KairosTheme.oceanBlue,
              unselectedItemColor: KairosTheme.textSecondary,
              selectedLabelStyle: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.dashboard_outlined)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.dashboard_rounded)),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.map_outlined)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.map_rounded)),
              label: 'MAP',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.warning_amber_rounded, color: KairosTheme.error)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.warning_rounded, color: KairosTheme.error)),
              label: 'SOS',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.assignment_outlined)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.assignment_rounded)),
              label: 'REPORTS',
            ),
            BottomNavigationBarItem(
              icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.menu_rounded)),
              activeIcon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.menu_rounded)),
              label: 'MORE',
            ),
          ],
        ),
      ),
    ),
  ),
);
  }
}
