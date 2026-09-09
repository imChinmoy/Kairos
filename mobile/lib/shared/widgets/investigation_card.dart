import 'dart:ui';
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(KairosTheme.radius12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: KairosTheme.surfaceWhite.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(KairosTheme.radius12),
              border: Border.all(color: KairosTheme.surfaceWhite.withValues(alpha: 0.4), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: KairosTheme.primaryNavy.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
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
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: KairosTheme.surfaceWhite.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'INV-${item.id.substring(item.id.length > 4 ? item.id.length - 4 : 0).toUpperCase()}',
                                  style: GoogleFonts.inter(
                                    color: KairosTheme.primaryNavy,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
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
                              fontWeight: FontWeight.w700,
                              color: KairosTheme.primaryNavy,
                            ),
                          ),
                          const SizedBox(height: KairosTheme.spacing12),
                          
                          // Location & Date
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 14, color: KairosTheme.primaryNavy.withValues(alpha: 0.7)),
                              const SizedBox(width: 6),
                              Text(
                                _getRegion(item.id).toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: KairosTheme.primaryNavy.withValues(alpha: 0.8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded, size: 14, color: KairosTheme.primaryNavy.withValues(alpha: 0.7)),
                              const SizedBox(width: 6),
                              Text(
                                '$dateStr UTC',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: KairosTheme.primaryNavy.withValues(alpha: 0.8),
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
                                'FIELD INSPECTION REQUIRED',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: KairosTheme.primaryNavy,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
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
