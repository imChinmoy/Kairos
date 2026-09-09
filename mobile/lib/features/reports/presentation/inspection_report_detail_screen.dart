import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/kairos_theme.dart';
import '../../../shared/widgets/kairos_app_bar.dart';
import '../domain/report_model.dart';
import '../services/pdf_service.dart';

class InspectionReportDetailScreen extends ConsumerWidget {
  final InspectionReportModel report;

  const InspectionReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: KairosTheme.offWhite,
      appBar: KairosAppBar(
        title: 'REPORT ${report.id.length > 6 ? report.id.substring(report.id.length - 6).toUpperCase() : report.id.toUpperCase()}',
        subtitle: 'Investigation: ${report.fastApiInvestigationId}',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KairosTheme.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('FINDINGS & STATUS'),
            _buildDetailsCard(),
            const SizedBox(height: 24),
            if (report.hasEvidence) ...[
              _buildSectionTitle('EVIDENCE'),
              _buildEvidenceCard(),
              const SizedBox(height: 24),
            ],
            ElevatedButton.icon(
              onPressed: () async {
                await PdfService.generateAndSharePdf(report);
              },
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text('GENERATE & SHARE PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: KairosTheme.primaryNavy,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: KairosTheme.textSecondary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: KairosTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KairosTheme.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_turned_in, color: KairosTheme.oceanBlue, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Official Field Report',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: KairosTheme.primaryNavy,
                      ),
                    ),
                    Text(
                      'Submitted: ${report.submittedAt?.toString().split('.').first ?? 'Pending'}',
                      style: GoogleFonts.inter(fontSize: 12, color: KairosTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: KairosTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KairosTheme.borderGrey),
      ),
      child: Column(
        children: [
          _buildDetailRow('Status', report.status),
          const Divider(height: 30),
          _buildDetailRow('Primary Finding', report.finding ?? 'N/A', isHighlight: true),
          const Divider(height: 30),
          _buildDetailRow('Investigation ID', report.fastApiInvestigationId),
          const Divider(height: 30),
          _buildDetailRow('Report ID', report.id),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: KairosTheme.textSecondary,
          ),
        ),
        Text(
          value.replaceAll('_', ' '),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
            color: isHighlight ? KairosTheme.error : KairosTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildEvidenceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: KairosTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KairosTheme.borderGrey),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: KairosTheme.teal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt_rounded, color: KairosTheme.teal),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Media Evidence Attached',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: KairosTheme.textPrimary,
                  ),
                ),
                Text(
                  'Photos/Videos are securely stored on the server.',
                  style: GoogleFonts.inter(fontSize: 11, color: KairosTheme.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
