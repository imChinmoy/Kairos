import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/kairos_theme.dart';

enum KairosConnectionState { secure, offline, syncing, error }

class ConnectionStatusPill extends StatelessWidget {
  final KairosConnectionState state;

  const ConnectionStatusPill({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    IconData icon;

    switch (state) {
      case KairosConnectionState.secure:
        color = KairosTheme.success;
        text = 'ONLINE & SECURE';
        icon = Icons.lock_outline_rounded;
        break;
      case KairosConnectionState.offline:
        color = KairosTheme.warning;
        text = 'OFFLINE';
        icon = Icons.cloud_off_rounded;
        break;
      case KairosConnectionState.syncing:
        color = KairosTheme.info;
        text = 'SYNCING';
        icon = Icons.sync_rounded;
        break;
      case KairosConnectionState.error:
        color = KairosTheme.error;
        text = 'ERROR';
        icon = Icons.warning_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KairosTheme.radius8),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

