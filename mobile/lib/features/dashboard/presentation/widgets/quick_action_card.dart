import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/kairos_theme.dart';

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtext;
  final Color color;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.subtext,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: KairosTheme.spacing16, horizontal: KairosTheme.spacing8),
          decoration: BoxDecoration(
            color: KairosTheme.cardWhite,
            borderRadius: BorderRadius.circular(KairosTheme.radius16),
            border: Border.all(color: KairosTheme.borderGrey, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: KairosTheme.textPrimary.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(KairosTheme.spacing12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: KairosTheme.spacing12),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: KairosTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtext,
                style: GoogleFonts.inter(
                  color: KairosTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
