import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/kairos_theme.dart';
import '../../../../shared/widgets/connection_status_pill.dart';

class KairosHeader extends StatelessWidget {
  final String greeting;
  final String officerName;
  final KairosConnectionState connectionState;
  final VoidCallback onProfileTap;

  const KairosHeader({
    super.key,
    required this.greeting,
    required this.officerName,
    required this.connectionState,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: KairosTheme.backgroundLight,
      padding: const EdgeInsets.fromLTRB(
        KairosTheme.spacing24,
        KairosTheme.spacing32,
        KairosTheme.spacing24,
        KairosTheme.spacing24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.satellite_alt_rounded, color: KairosTheme.teal, size: 20),
                  const SizedBox(width: KairosTheme.spacing8),
                  Text(
                    'KAIROS',
                    style: GoogleFonts.plusJakartaSans(
                      color: KairosTheme.primaryNavy,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  padding: const EdgeInsets.all(KairosTheme.spacing8),
                  decoration: BoxDecoration(
                    color: KairosTheme.cardWhite,
                    shape: BoxShape.circle,
                    border: Border.all(color: KairosTheme.borderGrey),
                  ),
                  child: const Icon(Icons.person_outline_rounded, color: KairosTheme.primaryNavy, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: KairosTheme.spacing24),
          Row(
            children: [
              ConnectionStatusPill(state: connectionState),
            ],
          ),
          const SizedBox(height: KairosTheme.spacing16),
          Text(
            greeting,
            style: GoogleFonts.plusJakartaSans(
              color: KairosTheme.teal,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            officerName,
            style: GoogleFonts.plusJakartaSans(
              color: KairosTheme.primaryNavy,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          const SizedBox(height: KairosTheme.spacing8),
          Text(
            'Secure connection established.\nAwaiting orders.',
            style: GoogleFonts.inter(
              color: KairosTheme.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
