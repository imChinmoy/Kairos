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
      backgroundColor: const Color.fromARGB(255, 20, 58, 97).withOpacity(0.95),
      elevation: 0,
      toolbarHeight: 70,
      centerTitle: centerTitle,
      titleSpacing: centerTitle ? null : 24,
      automaticallyImplyLeading: showBackButton,
      iconTheme: const IconThemeData(color: KairosTheme.surfaceWhite),
      leading: leading ?? (showBackButton && Navigator.of(context).canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null),
      title: imageTitle != null
          ? Image.asset(
              imageTitle!,
              height: 50,
              fit: BoxFit.contain,
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    color: KairosTheme.surfaceWhite,
                    fontSize: subtitle == null ? 18 : 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: GoogleFonts.inter(
                      color: KairosTheme.surfaceWhite.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
