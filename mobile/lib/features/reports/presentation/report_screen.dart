import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      backgroundColor: KairosTheme.offWhite,
      appBar: const KairosAppBar(
        title: 'INSPECTION REPORTS',
        showBackButton: false,
      ),
      body: reportsAsync.when(
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
                const SizedBox(height: 20),

                const Text(
                  'Recent Reports',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 12),

                if (reports.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No reports found.'),
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: KairosTheme.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: KairosTheme.borderGrey),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: KairosTheme.textSecondary),
            ),
          ],
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
        return KairosTheme.textMuted;
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KairosTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KairosTheme.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _findingColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _findingLabel,
                  style: TextStyle(
                    color: _findingColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${date.day} ${_month(date.month)} ${date.year}',
                style: const TextStyle(fontSize: 11, color: KairosTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Field Inspection — ${report.fastApiInvestigationId}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                report.id.length > 8 ? report.id.substring(report.id.length - 8).toUpperCase() : report.id.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontFamily: 'monospace',
                  color: KairosTheme.textMuted,
                ),
              ),
              if (report.hasEvidence) ...[
                const SizedBox(width: 10),
                const Icon(Icons.camera_alt, size: 12, color: KairosTheme.teal),
                const SizedBox(width: 2),
                const Text(
                  'Evidence attached',
                  style: TextStyle(fontSize: 10, color: KairosTheme.teal),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton(
                onPressed: () {
                  context.push('/reports/${report.id}', extra: report);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('View Report', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  await PdfService.generateAndSharePdf(report);
                },
                icon: const Icon(Icons.share_outlined, size: 14),
                label: const Text('Share', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),
        ],
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
