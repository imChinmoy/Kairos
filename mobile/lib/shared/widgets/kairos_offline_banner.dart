import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/kairos_theme.dart';

class KairosOfflineBanner extends StatelessWidget {
  final bool isOnline;

  const KairosOfflineBanner({
    super.key,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    if (isOnline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: KairosTheme.spacing8),
      color: KairosTheme.warning.withOpacity(0.9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, color: KairosTheme.surfaceWhite, size: 14),
          const SizedBox(width: KairosTheme.spacing8),
          Text(
            'OFFLINE - OPERATING IN FIELD MODE',
            style: GoogleFonts.inter(
              color: KairosTheme.surfaceWhite,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
