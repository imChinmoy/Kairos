import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/kairos_theme.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: KairosTheme.offWhite,
      appBar: AppBar(
        title: const Text('Inspection Reports'),
        backgroundColor: KairosTheme.navyBlue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Summary stat bar
          Row(
            children: [
              _StatCard(
                  label: 'Total', value: '5', color: KairosTheme.oceanBlue),
              const SizedBox(width: 10),
              _StatCard(
                  label: 'Confirmed', value: '2', color: KairosTheme.error),
              const SizedBox(width: 10),
              _StatCard(
                  label: 'Submitted', value: '4', color: KairosTheme.success),
            ],
          ),
          const SizedBox(height: 20),

          const Text(
            'Recent Reports',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 12),

          // Demo report cards
          _ReportCard(
            title: 'Oil Spill — Arabian Sea',
            investigationId: 'demo-inv-001',
            finding: 'OIL_CONFIRMED',
            submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
            hasEvidence: true,
          ),
          const SizedBox(height: 10),
          _ReportCard(
            title: 'Suspected Slick — Bay of Bengal',
            investigationId: 'demo-inv-002',
            finding: 'OIL_SUSPECTED',
            submittedAt: DateTime.now().subtract(const Duration(days: 1)),
            hasEvidence: true,
          ),
          const SizedBox(height: 10),
          _ReportCard(
            title: 'Routine Check — Andaman Islands',
            investigationId: 'demo-inv-004',
            finding: 'NO_OIL',
            submittedAt: DateTime.now().subtract(const Duration(days: 5)),
            hasEvidence: false,
          ),
        ],
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
              style: const TextStyle(
                  fontSize: 11, color: KairosTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String investigationId;
  final String finding;
  final DateTime submittedAt;
  final bool hasEvidence;

  const _ReportCard({
    required this.title,
    required this.investigationId,
    required this.finding,
    required this.submittedAt,
    required this.hasEvidence,
  });

  Color get _findingColor {
    switch (finding) {
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
    switch (finding) {
      case 'OIL_CONFIRMED':
        return 'Oil Confirmed';
      case 'OIL_SUSPECTED':
        return 'Oil Suspected';
      case 'NO_OIL':
        return 'No Oil Found';
      case 'INCONCLUSIVE':
        return 'Inconclusive';
      default:
        return finding;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                '${submittedAt.day} ${_month(submittedAt.month)} ${submittedAt.year}',
                style: const TextStyle(
                    fontSize: 11, color: KairosTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                investigationId.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontFamily: 'monospace',
                  color: KairosTheme.textMuted,
                ),
              ),
              if (hasEvidence) ...[
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
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('View Report', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {},
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
