import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/kairos_theme.dart';
import '../../features/investigations/data/investigation_repository.dart';
import '../../features/investigations/domain/investigation_model.dart';
import 'priority_badge.dart';

class InvestigationCard extends StatelessWidget {
  final InvestigationListItem item;
  final VoidCallback onTap;

  const InvestigationCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final priorityColor = KairosTheme.priorityColor(item.priority);
    final dateStr = item.assignedAt != null
        ? DateFormat('dd MMM yyyy • HH:mm').format(item.assignedAt!)
        : 'Unknown Date';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: KairosTheme.cardWhite,
          borderRadius: BorderRadius.circular(KairosTheme.radius16),
          border: Border.all(color: KairosTheme.borderGrey, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: KairosTheme.textPrimary.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(KairosTheme.radius16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Priority Accent Line
                Container(
                  width: 4,
                  color: priorityColor,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(KairosTheme.spacing16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Priority Badge & Ref
                        Row(
                          children: [
                            PriorityBadge(priority: item.priority),
                            const Spacer(),
                            Text(
                              'INV-${item.id.substring(item.id.length > 4 ? item.id.length - 4 : 0).toUpperCase()}',
                              style: GoogleFonts.inter(
                                color: KairosTheme.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: KairosTheme.spacing12),
                        
                        // Title
                        Text(
                          _getTitle(item),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: KairosTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: KairosTheme.spacing12),
                        
                        // Location & Date
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: KairosTheme.secondaryBlue),
                            const SizedBox(width: 4),
                            Text(
                              _getRegion(item.id),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: KairosTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: KairosTheme.spacing8),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 14, color: KairosTheme.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              '$dateStr UTC',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: KairosTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: KairosTheme.spacing16),
                        
                        // Status Action
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Field inspection pending',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: KairosTheme.textPrimary,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: KairosTheme.primaryNavy,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTitle(InvestigationListItem item) {
    if (item.priority == 'CRITICAL') return 'Critical Oil Spill Alert';
    if (item.priority == 'HIGH') return 'Suspected Oil Spill';
    return 'Possible Maritime Debris / Slick';
  }

  String _getRegion(String id) {
    const regions = ['Arabian Sea', 'Bay of Bengal', 'Lakshadweep', 'Andaman', 'Gujarat Coast'];
    return regions[id.hashCode.abs() % regions.length];
  }
}
