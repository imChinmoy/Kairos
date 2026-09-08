import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/kairos_theme.dart';
import 'package:intl/intl.dart';

class OfflineStateCard extends StatelessWidget {
  final VoidCallback onRetry;
  final DateTime? lastSyncTime;
  final bool hasCachedData;

  const OfflineStateCard({
    super.key,
    required this.onRetry,
    this.lastSyncTime,
    this.hasCachedData = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KairosTheme.spacing16),
      decoration: BoxDecoration(
        color: KairosTheme.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(KairosTheme.radius16),
        border: Border.all(color: KairosTheme.error.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KairosTheme.spacing8),
                decoration: BoxDecoration(
                  color: KairosTheme.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cloud_off_rounded, color: KairosTheme.error, size: 20),
              ),
              const SizedBox(width: KairosTheme.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection unavailable',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: KairosTheme.error,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasCachedData
                          ? 'Showing cached investigations'
                          : 'Unable to fetch investigations',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: KairosTheme.error.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasCachedData && lastSyncTime != null) ...[
            const SizedBox(height: KairosTheme.spacing16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: KairosTheme.cardWhite,
                borderRadius: BorderRadius.circular(KairosTheme.radius12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.update_rounded, size: 14, color: KairosTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Last synchronized: ${DateFormat('h:mm a').format(lastSyncTime!)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: KairosTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: KairosTheme.spacing16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry Connection'),
              style: OutlinedButton.styleFrom(
                foregroundColor: KairosTheme.error,
                side: BorderSide(color: KairosTheme.error.withOpacity(0.3)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
