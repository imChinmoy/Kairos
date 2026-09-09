import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/kairos_theme.dart';

class KairosAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final String? imageTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final bool centerTitle;

  const KairosAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.imageTitle,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0D253F).withValues(alpha: 0.85),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(color: Colors.transparent),
        ),
      ),
      elevation: 0,
      toolbarHeight: 70,
      centerTitle: centerTitle,
      titleSpacing: centerTitle ? null : 16,
      automaticallyImplyLeading: showBackButton,
      iconTheme: const IconThemeData(color: KairosTheme.surfaceWhite),
      leading: leading ?? (showBackButton && Navigator.of(context).canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imageTitle != null) ...[
            Image.asset(
              imageTitle!,
              height: 36,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Container(
              height: 24,
              width: 1,
              color: KairosTheme.surfaceWhite.withValues(alpha: 0.2),
            ),
            const SizedBox(width: 12),
          ],
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              'assets/images/logo.jpeg',
              height: 28,
              width: 28,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  color: KairosTheme.surfaceWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: GoogleFonts.inter(
                    color: KairosTheme.surfaceWhite.withValues(alpha: 0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
