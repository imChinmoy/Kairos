import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/kairos_theme.dart';
import '../../../shared/widgets/kairos_app_bar.dart';
import '../../../shared/widgets/kairos_loader.dart';
import '../data/report_repository.dart';
import '../domain/report_model.dart';
import '../services/pdf_service.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(inspectionReportsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: const KairosAppBar(
        title: 'INSPECTION REPORTS',
        showBackButton: false,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/auth_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: reportsAsync.when(
            data: (reports) {
              final total = reports.length;
              final confirmed = reports.where((r) => r.finding == 'OIL_CONFIRMED').length;
              final submitted = reports.where((r) => r.status == 'SUBMITTED').length;

              return RefreshIndicator(
                onRefresh: () => ref.refresh(inspectionReportsProvider.future),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Summary stat bar
                    Row(
                      children: [
                        _StatCard(label: 'Total', value: total.toString(), color: KairosTheme.oceanBlue),
                        const SizedBox(width: 10),
                        _StatCard(label: 'Confirmed', value: confirmed.toString(), color: KairosTheme.error),
                        const SizedBox(width: 10),
                        _StatCard(label: 'Submitted', value: submitted.toString(), color: KairosTheme.success),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'RECENT REPORTS',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700, 
                        fontSize: 12,
                        letterSpacing: 1.5,
                        color: KairosTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (reports.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'No reports found.',
                            style: GoogleFonts.inter(color: KairosTheme.primaryNavy.withOpacity(0.6)),
                          ),
                        ),
                      )
                    else
                      ...reports.map((report) => _ReportCard(report: report)),
                  ],
                ),
              );
            },
            loading: () => const Center(child: KairosLoader()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: KairosTheme.surfaceWhite.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: KairosTheme.surfaceWhite.withValues(alpha: 0.8), width: 1.5),
            ),
            child: Column(
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10, 
                    fontWeight: FontWeight.w600,
                    color: KairosTheme.primaryNavy.withValues(alpha: 0.7),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final InspectionReportModel report;

  const _ReportCard({required this.report});

  Color get _findingColor {
    switch (report.finding) {
      case 'OIL_CONFIRMED':
        return KairosTheme.error;
      case 'OIL_SUSPECTED':
        return KairosTheme.warning;
      case 'NO_OIL':
        return KairosTheme.success;
      default:
        return KairosTheme.textSecondary;
    }
  }

  String get _findingLabel {
    switch (report.finding) {
      case 'OIL_CONFIRMED':
        return 'Oil Confirmed';
      case 'OIL_SUSPECTED':
        return 'Oil Suspected';
      case 'NO_OIL':
        return 'No Oil Found';
      case 'INCONCLUSIVE':
        return 'Inconclusive';
      default:
        return report.finding ?? report.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = report.submittedAt ?? report.updatedAt ?? DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KairosTheme.surfaceWhite.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(16),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _findingColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _findingColor.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _findingColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _findingLabel.toUpperCase(),
                            style: GoogleFonts.inter(
                              color: _findingColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${date.day} ${_month(date.month)} ${date.year}',
                      style: GoogleFonts.inter(
                        fontSize: 11, 
                        fontWeight: FontWeight.w600,
                        color: KairosTheme.primaryNavy.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Field Inspection',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: KairosTheme.primaryNavy,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.tag_rounded, size: 12, color: KairosTheme.primaryNavy.withValues(alpha: 0.5)),
                    const SizedBox(width: 4),
                    Text(
                      report.id.length > 8 ? report.id.substring(report.id.length - 8).toUpperCase() : report.id.toUpperCase(),
                      style: GoogleFonts.robotoMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: KairosTheme.primaryNavy.withValues(alpha: 0.7),
                      ),
                    ),
                    if (report.hasEvidence) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: KairosTheme.teal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: KairosTheme.teal.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.camera_alt, size: 10, color: KairosTheme.teal),
                            const SizedBox(width: 4),
                            Text(
                              'EVIDENCE',
                              style: GoogleFonts.inter(
                                fontSize: 9, 
                                fontWeight: FontWeight.w700,
                                color: KairosTheme.teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.push('/reports/${report.id}', extra: report);
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          side: BorderSide(color: KairosTheme.primaryNavy.withValues(alpha: 0.2)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          backgroundColor: KairosTheme.surfaceWhite.withValues(alpha: 0.5),
                        ),
                        child: Text(
                          'View Report', 
                          style: GoogleFonts.inter(
                            fontSize: 12, 
                            fontWeight: FontWeight.w600,
                            color: KairosTheme.primaryNavy,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await PdfService.generateAndSharePdf(report);
                        },
                        icon: const Icon(Icons.share_outlined, size: 14, color: KairosTheme.cardWhite),
                        label: Text(
                          'Share PDF', 
                          style: GoogleFonts.inter(
                            fontSize: 12, 
                            fontWeight: FontWeight.w600,
                            color: KairosTheme.cardWhite,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          backgroundColor: KairosTheme.primaryNavy,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _month(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m];
  }
}
