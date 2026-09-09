import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/kairos_theme.dart';
import '../data/investigation_repository.dart';
import '../domain/investigation_model.dart';
import '../../../shared/widgets/kairos_action_button.dart';
import '../../../shared/widgets/kairos_app_background.dart';

class InvestigationDetailScreen extends ConsumerWidget {
  final String investigationId;

  const InvestigationDetailScreen({super.key, required this.investigationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investigationAsync = ref.watch(
      investigationDetailProvider(investigationId),
    );

    return KairosAppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: investigationAsync.when(
          data: (inv) => _InvestigationDetailBody(investigation: inv),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: KairosTheme.error, size: 48),
                  const SizedBox(height: 12),
                  Text('Failed to load investigation', style: GoogleFonts.inter()),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text('GO BACK', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InvestigationDetailBody extends ConsumerWidget {
  final InvestigationModel investigation;

  const _InvestigationDetailBody({required this.investigation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inv = investigation;

    return CustomScrollView(
      slivers: [
        // App bar
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: KairosTheme.surfaceWhite.withOpacity(0.7),
          elevation: 0,
          foregroundColor: KairosTheme.primaryNavy,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'INV-${investigationId.substring(investigationId.length > 6 ? investigationId.length - 6 : 0).toUpperCase()}',
            style: GoogleFonts.inter(
              color: KairosTheme.primaryNavy,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 1.0,
            ),
          ),
          actions: [
            // Priority badge
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: KairosTheme.priorityColor(inv.priority).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: KairosTheme.priorityColor(inv.priority).withOpacity(0.6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: KairosTheme.priorityColor(inv.priority),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${inv.priority} PRIORITY',
                        style: GoogleFonts.inter(
                          color: KairosTheme.priorityColor(inv.priority),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: FlexibleSpaceBar(
                background: Container(
                  color: Colors.transparent,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inv.title.split(' — ').first,
                            style: GoogleFonts.plusJakartaSans(
                              color: KairosTheme.primaryNavy,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            investigationId,
                            style: GoogleFonts.inter(
                              color: KairosTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (inv.releaseStart != null)
                            Text(
                              'SATELLITE TIME: ${DateFormat('dd MMM yyyy, HH:mm').format(inv.releaseStart!)} UTC',
                              style: GoogleFonts.inter(
                                color: KairosTheme.primaryNavy.withOpacity(0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Tab content (Overview, Map, Notes)
        SliverToBoxAdapter(
          child: _DetailTabContent(investigation: inv),
        ),
      ],
    );
  }

  String get investigationId => investigation.id;
}

class _DetailTabContent extends StatefulWidget {
  final InvestigationModel investigation;

  const _DetailTabContent({required this.investigation});

  @override
  State<_DetailTabContent> createState() => _DetailTabContentState();
}

class _DetailTabContentState extends State<_DetailTabContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.investigation;

    return Column(
      children: [
        // Tab bar
        Container(
          color: Colors.transparent,
          child: TabBar(
            controller: _tabController,
            indicatorColor: KairosTheme.primaryNavy,
            labelColor: KairosTheme.primaryNavy,
            unselectedLabelColor: KairosTheme.primaryNavy.withOpacity(0.5),
            labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.5),
            tabs: const [
              Tab(text: 'OVERVIEW'),
              Tab(text: 'MAP'),
              Tab(text: 'NOTES'),
            ],
          ),
        ),

        // Tab views
        SizedBox(
          height: MediaQuery.of(context).size.height,
          child: TabBarView(
            controller: _tabController,
            children: [
              _OverviewTab(investigation: inv),
              _MapPreviewTab(investigation: inv),
              _NotesTab(investigation: inv),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final InvestigationModel investigation;

  const _OverviewTab({required this.investigation});

  @override
  Widget build(BuildContext context) {
    final inv = investigation;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Satellite image placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: KairosTheme.surfaceWhite.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: KairosTheme.surfaceWhite.withOpacity(0.4), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: KairosTheme.primaryNavy.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.satellite_alt_rounded,
                              color: KairosTheme.primaryNavy.withOpacity(0.6), size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'SAR Satellite Image',
                            style: GoogleFonts.inter(
                              color: KairosTheme.primaryNavy.withOpacity(0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Confidence badge
                    if (inv.detectionConfidence != null)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: KairosTheme.primaryNavy.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'CONFIDENCE: ${(inv.detectionConfidence! * 100).toStringAsFixed(0)}%',
                            style: GoogleFonts.inter(
                              color: KairosTheme.surfaceWhite,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Probable Investigation Area
          if (inv.sourceUncertaintyKm != null)
            _InfoCard(
              icon: Icons.radar,
              iconColor: KairosTheme.saffron,
              title: 'PROBABLE INVESTIGATION AREA',
              subtitle: 'Approx. ${inv.sourceUncertaintyKm!.toStringAsFixed(1)} km radius',
            ),
          const SizedBox(height: 12),

          // Key Information section
          Text(
            'KEY INFORMATION',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: KairosTheme.textSecondary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),

          if (inv.releaseStart != null && inv.releaseEnd != null)
            _KeyInfoRow(
              icon: Icons.schedule_outlined,
              label: 'ESTIMATED TIME WINDOW',
              value:
                  '${DateFormat('HH:mm').format(inv.releaseStart!)} – ${DateFormat('HH:mm UTC').format(inv.releaseEnd!)}',
            ),

          if (inv.modelConditions?.windSpeedKn != null)
            _KeyInfoRow(
              icon: Icons.air,
              label: 'WEATHER (APPROX)',
              value: inv.modelConditions!.windSummary.toUpperCase(),
            ),

          _KeyInfoRow(
            icon: Icons.directions_boat_outlined,
            label: 'CANDIDATE VESSELS',
            value: '${inv.candidateVessels.length} vessel${inv.candidateVessels.length != 1 ? 's' : ''} identified'.toUpperCase(),
          ),

          if (inv.detectionAreaKm2 != null)
            _KeyInfoRow(
              icon: Icons.layers_outlined,
              label: 'ESTIMATED SLICK AREA',
              value: '${inv.detectionAreaKm2!.toStringAsFixed(1)} KM²',
            ),

          const SizedBox(height: 24),

          // Candidate vessels
          if (inv.candidateVessels.isNotEmpty) ...[
            Text(
              'CANDIDATE VESSELS',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: KairosTheme.textSecondary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ranked by evidence compatibility. Candidates only.',
              style: GoogleFonts.inter(fontSize: 11, color: KairosTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            ...inv.candidateVessels.map(
              (v) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CandidateVesselCard(vessel: v),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Primary CTA — Navigate to Area
          KairosActionButton(
            label: 'NAVIGATE TO AREA',
            icon: Icons.navigation_rounded,
            color: KairosTheme.oceanBlue,
            onPressed: () => context.push('/map', extra: {'investigationId': investigation.id}),
          ),
          const SizedBox(height: 12),

          // Start Inspection CTA
          KairosActionButton(
            label: 'START FIELD INSPECTION',
            icon: Icons.assignment_rounded,
            color: KairosTheme.teal,
            onPressed: () => context.push('/investigations/${investigation.id}/inspect'),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(KairosTheme.radius12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: KairosTheme.surfaceWhite.withOpacity(0.15),
            borderRadius: BorderRadius.circular(KairosTheme.radius12),
            border: Border.all(color: KairosTheme.surfaceWhite.withOpacity(0.4), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: KairosTheme.primaryNavy.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, color: KairosTheme.primaryNavy, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}

class _KeyInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _KeyInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: KairosTheme.oceanBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 10, color: KairosTheme.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                Text(value,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, fontWeight: FontWeight.w700, color: KairosTheme.primaryNavy)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidateVesselCard extends StatelessWidget {
  final CandidateVessel vessel;

  const _CandidateVesselCard({required this.vessel});

  @override
  Widget build(BuildContext context) {
    final compatColor = KairosTheme.compatibilityColor(vessel.compatibility);

    return ClipRRect(
      borderRadius: BorderRadius.circular(KairosTheme.radius12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: KairosTheme.surfaceWhite.withOpacity(0.15),
            borderRadius: BorderRadius.circular(KairosTheme.radius12),
            border: Border.all(color: KairosTheme.surfaceWhite.withOpacity(0.4), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: KairosTheme.primaryNavy.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'CANDIDATE #${vessel.rank}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.5,
                  color: KairosTheme.primaryNavy,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: compatColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'COMPATIBILITY: ${vessel.compatibility}',
                  style: GoogleFonts.inter(
                    color: compatColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            vessel.name,
            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: KairosTheme.primaryNavy),
          ),
          Text(
            '${vessel.vesselType.toUpperCase()} · MMSI ${vessel.mmsi}',
            style: GoogleFonts.inter(
                fontSize: 12, color: KairosTheme.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          // Evidence scores
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _EvidenceChip(
                  label: 'Spatial',
                  value: vessel.evidence['spatial'] ?? 0),
              _EvidenceChip(
                  label: 'Temporal',
                  value: vessel.evidence['temporal'] ?? 0),
              _EvidenceChip(
                  label: 'Drift', value: vessel.evidence['drift'] ?? 0),
              _EvidenceChip(
                  label: 'Trajectory',
                  value: vessel.evidence['trajectory'] ?? 0),
              _EvidenceChip(
                  label: 'AIS Quality',
                  value: vessel.evidence['aisQuality'] ?? 0),
            ],
          ),
        ],
      ),
    ),
  ),
);
  }
}

class _EvidenceChip extends StatelessWidget {
  final String label;
  final double value;

  const _EvidenceChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final color = value >= 0.8
        ? KairosTheme.error
        : value >= 0.5
            ? KairosTheme.warning
            : KairosTheme.success;
    final rating = value >= 0.8
        ? 'HIGH'
        : value >= 0.5
            ? 'MED'
            : 'LOW';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: KairosTheme.surfaceGrey,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: KairosTheme.borderGrey),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 9, color: KairosTheme.textMuted)),
          Text(
            rating,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPreviewTab extends StatelessWidget {
  final InvestigationModel investigation;

  const _MapPreviewTab({required this.investigation});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map_outlined, size: 64, color: KairosTheme.textMuted),
          const SizedBox(height: 12),
          const Text('Map View',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          const Text(
            'Open the Map tab for full navigation',
            style: TextStyle(color: KairosTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context.go('/map'),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Open Map'),
          ),
        ],
      ),
    );
  }
}

class _NotesTab extends StatelessWidget {
  final InvestigationModel investigation;

  const _NotesTab({required this.investigation});

  @override
  Widget build(BuildContext context) {
    final inv = investigation;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field vs Model comparison
          const Text(
            'Model vs Field Comparison',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Compare model predictions against field observations recorded during inspection.',
            style: TextStyle(fontSize: 12, color: KairosTheme.textSecondary),
          ),
          const SizedBox(height: 16),

          _ComparisonRow(
            label: 'Wind',
            modelValue: inv.modelConditions?.windSummary ?? 'N/A',
            fieldValue: 'Not yet recorded',
          ),
          _ComparisonRow(
            label: 'Current',
            modelValue: inv.modelConditions?.currentSummary ?? 'N/A',
            fieldValue: 'Not yet recorded',
          ),

          const SizedBox(height: 24),

          if (inv.candidateVessels.isNotEmpty) ...[
            const Text(
              'Candidate Explanations',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...inv.candidateVessels.first.explanations.map(
              (exp) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        size: 14, color: KairosTheme.info),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(exp,
                          style: const TextStyle(
                              fontSize: 13, color: KairosTheme.textSecondary)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String label;
  final String modelValue;
  final String fieldValue;

  const _ComparisonRow({
    required this.label,
    required this.modelValue,
    required this.fieldValue,
  });

  bool get isRecorded => fieldValue != 'Not yet recorded';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KairosTheme.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: KairosTheme.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('MODEL',
                        style: TextStyle(
                            fontSize: 9,
                            color: KairosTheme.textMuted,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1)),
                    Text(modelValue,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 1,
                height: 32,
                color: KairosTheme.borderGrey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('FIELD',
                        style: TextStyle(
                            fontSize: 9,
                            color: KairosTheme.textMuted,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1)),
                    Text(
                      fieldValue,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isRecorded
                            ? KairosTheme.textPrimary
                            : KairosTheme.textMuted,
                        fontStyle: isRecorded ? FontStyle.normal : FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              if (isRecorded)
                const Icon(Icons.check_circle,
                    color: KairosTheme.success, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}
