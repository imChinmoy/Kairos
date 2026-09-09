import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/kairos_theme.dart';

class KairosActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final bool isOutline;
  final bool isFullWidth;

  const KairosActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color,
    this.isOutline = false,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? KairosTheme.primaryNavy;
    
    Widget buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: KairosTheme.spacing4),
        Flexible(
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    if (isOutline) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveColor,
          side: BorderSide(color: effectiveColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KairosTheme.radius8)),
        ),
        child: buttonContent,
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveColor,
        foregroundColor: KairosTheme.surfaceWhite,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KairosTheme.radius8)),
      ),
      child: buttonContent,
    );
  }
}
