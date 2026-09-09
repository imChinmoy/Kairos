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
    final isCompleted = item.assignmentStatus == 'COMPLETED' || item.assignmentStatus == 'FIELD_INSPECTED';
    final priorityColor = isCompleted ? KairosTheme.success : KairosTheme.priorityColor(item.priority);
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
              border: Border.all(color: KairosTheme.primaryNavy.withValues(alpha: 0.15), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: KairosTheme.primaryNavy.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Gradient Accent
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [priorityColor, priorityColor.withValues(alpha: 0.1)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
                Padding(
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
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: KairosTheme.surfaceWhite.withValues(alpha: 0.25),
                              border: Border.all(color: KairosTheme.surfaceWhite.withValues(alpha: 0.5)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.tag_rounded, size: 10, color: KairosTheme.primaryNavy.withValues(alpha: 0.6)),
                                const SizedBox(width: 4),
                                Text(
                                  item.id.substring(item.id.length > 6 ? item.id.length - 6 : 0).toUpperCase(),
                                  style: GoogleFonts.robotoMono(
                                    color: KairosTheme.primaryNavy,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: KairosTheme.spacing16),
                      
                      // Title
                      Text(
                        _getTitle(item),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: KairosTheme.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: KairosTheme.spacing16),
                      
                      // Structured Meta Information Grid
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: KairosTheme.primaryNavy.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: KairosTheme.primaryNavy.withValues(alpha: 0.06)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'LOCATION',
                                    style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: KairosTheme.primaryNavy.withValues(alpha: 0.5), letterSpacing: 0.5),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.my_location_rounded, size: 12, color: KairosTheme.primaryNavy.withValues(alpha: 0.8)),
                                      const SizedBox(width: 4),
                                      Text(
                                        _getRegion(item.id).toUpperCase(),
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: KairosTheme.primaryNavy,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 28, color: KairosTheme.primaryNavy.withValues(alpha: 0.1)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'LOGGED',
                                    style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: KairosTheme.primaryNavy.withValues(alpha: 0.5), letterSpacing: 0.5),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.schedule_rounded, size: 12, color: KairosTheme.primaryNavy.withValues(alpha: 0.8)),
                                      const SizedBox(width: 4),
                                      Text(
                                        dateStr,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: KairosTheme.primaryNavy,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Action Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(isCompleted ? Icons.check_circle_outline_rounded : Icons.radar_rounded, size: 14, color: isCompleted ? KairosTheme.success : KairosTheme.oceanBlue),
                              const SizedBox(width: 6),
                              Text(
                                isCompleted ? 'INSPECTION COMPLETE' : 'AWAITING INSPECTION',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isCompleted ? KairosTheme.success : KairosTheme.oceanBlue,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: KairosTheme.primaryNavy,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 10,
                              color: KairosTheme.cardWhite,
                            ),
                          ),
                        ],
                      ),
                    ],
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
