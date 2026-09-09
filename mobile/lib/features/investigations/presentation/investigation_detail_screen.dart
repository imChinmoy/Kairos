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
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
                  Text('Failed to load investigation',
                      style: GoogleFonts.inter()),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text('GO BACK',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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
          pinned: true,
          backgroundColor: KairosTheme.primaryNavy,
          elevation: 0,
          foregroundColor: KairosTheme.surfaceWhite,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'INV-${investigationId.substring(investigationId.length > 6 ? investigationId.length - 6 : 0).toUpperCase()}',
            style: GoogleFonts.inter(
              color: KairosTheme.surfaceWhite,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: KairosTheme.priorityColor(inv.priority)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: KairosTheme.priorityColor(inv.priority)
                          .withValues(alpha: 0.6),
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
                      padding: const EdgeInsets.fromLTRB(20, 600, 20, 20),
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
                          // const SizedBox(height: 6),
                          // Text(
                          //   investigationId,
                          //   style: GoogleFonts.inter(
                          //     color: KairosTheme.textSecondary,
                          //     fontSize: 13,
                          //     fontWeight: FontWeight.w500,
                          //   ),
                          // ),
                          const SizedBox(height: 12),
                          if (inv.releaseStart != null)
                            Text(
                              'SATELLITE TIME: ${DateFormat('dd MMM yyyy, HH:mm').format(inv.releaseStart!)} UTC',
                              style: GoogleFonts.inter(
                                color: KairosTheme.primaryNavy.withValues(alpha: 0.8),
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
            unselectedLabelColor: KairosTheme.primaryNavy.withValues(alpha: 0.5),
            labelStyle: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.5),
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

class _ExpandableDetails extends StatefulWidget {
  final InvestigationModel inv;
  const _ExpandableDetails({required this.inv});

  @override
  State<_ExpandableDetails> createState() => _ExpandableDetailsState();
}

class _ExpandableDetailsState extends State<_ExpandableDetails> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          onPressed: () => setState(() => _isExpanded = !_isExpanded),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isExpanded ? 'HIDE DETAILS' : 'SEE MORE DETAILS',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: KairosTheme.oceanBlue),
                ),
                Icon(_isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: KairosTheme.oceanBlue),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 16),
          Text(
              'Detection Confidence: ${(widget.inv.detectionConfidence != null ? (widget.inv.detectionConfidence! * 100).toStringAsFixed(1) : '--')}%',
              style: GoogleFonts.inter(color: KairosTheme.textSecondary)),
          const SizedBox(height: 8),
          Text('Reconstruction Window:',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600, color: KairosTheme.primaryNavy)),
          Text(
              widget.inv.releaseStart != null && widget.inv.releaseEnd != null
                  ? '${DateFormat('dd MMM yyyy HH:mm').format(widget.inv.releaseStart!)} - ${DateFormat('HH:mm').format(widget.inv.releaseEnd!)} UTC'
                  : 'N/A',
              style: GoogleFonts.inter(color: KairosTheme.textSecondary)),
        ],
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
          Text(
            inv.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: KairosTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 16),
          // Satellite image placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: KairosTheme.surfaceWhite.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: KairosTheme.surfaceWhite.withValues(alpha: 0.4),
                      width: 1.0),
                ),
                child: inv.sarImageUrl != null
                    ? Image.network(
                        inv.sarImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                          child: Icon(Icons.broken_image,
                              color: KairosTheme.textMuted, size: 40),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.satellite_alt_rounded,
                          color: KairosTheme.surfaceWhite,
                          size: 40,
                        ),
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
              subtitle:
                  'Approx. ${inv.sourceUncertaintyKm!.toStringAsFixed(1)} km radius',
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
            value:
                '${inv.candidateVessels.length} vessel${inv.candidateVessels.length != 1 ? 's' : ''} identified'
                    .toUpperCase(),
          ),

          if (inv.detectionAreaKm2 != null)
            _KeyInfoRow(
              icon: Icons.layers_outlined,
              label: 'ESTIMATED SLICK AREA',
              value: '${inv.detectionAreaKm2!.toStringAsFixed(1)} KM²',
            ),

          const SizedBox(height: 24),

          // Primary CTA — Navigate to Area
          KairosActionButton(
            label: 'NAVIGATE TO AREA',
            icon: Icons.navigation_rounded,
            color: KairosTheme.oceanBlue,
            onPressed: () => context
                .go('/map', extra: {'investigationId': investigation.id}),
          ),
          const SizedBox(height: 12),

          // Start Inspection CTA
          KairosActionButton(
            label: 'START FIELD INSPECTION',
            icon: Icons.assignment_rounded,
            color: KairosTheme.teal,
            onPressed: () =>
                context.push('/investigations/${investigation.id}/inspect'),
          ),
          const SizedBox(height: 12),
          _ExpandableDetails(inv: inv),
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
            color: KairosTheme.surfaceWhite.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(KairosTheme.radius12),
            border: Border.all(
                color: KairosTheme.surfaceWhite.withValues(alpha: 0.4), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: KairosTheme.primaryNavy.withValues(alpha: 0.02),
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
                  color: iconColor.withValues(alpha: 0.1),
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
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: KairosTheme.primaryNavy,
                            fontWeight: FontWeight.w600)),
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
                        fontSize: 10,
                        color: KairosTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5)),
                Text(value,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: KairosTheme.primaryNavy)),
              ],
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MiniMapCard(investigation: investigation),
          const SizedBox(height: 24),
          _CandidateVesselsTable(vessels: investigation.candidateVessels),
          const SizedBox(height: 60),
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
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
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
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
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
                        fontStyle:
                            isRecorded ? FontStyle.normal : FontStyle.italic,
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

class _MiniMapCard extends StatelessWidget {
  final InvestigationModel investigation;

  const _MiniMapCard({required this.investigation});

  @override
  Widget build(BuildContext context) {
    // Prefer sourceRegion, fallback to slickGeometry
    final geo = investigation.sourceRegion ?? investigation.slickGeometry;
    if (geo == null) return const SizedBox();

    final centerCoord = geo.center;
    final centerPoint = centerCoord != null
        ? LatLng(centerCoord[0], centerCoord[1])
        : const LatLng(18.9388, 72.9153);

    final points = geo.polygonPoints;
    final polygon = points != null
        ? Polygon(
            points: points.map((p) => LatLng(p[0], p[1])).toList(),
            color: KairosTheme.saffron.withValues(alpha: 0.3),
            borderColor: KairosTheme.saffron,
            borderStrokeWidth: 2,
            
          )
        : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(KairosTheme.radius12),
      child: Container(
        height: 450,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(KairosTheme.radius12),
          border: Border.all(
              color: KairosTheme.surfaceWhite.withValues(alpha: 0.3)),
        ),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: centerPoint,
            initialZoom: 10,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'in.ntro.kairos',
            ),
            if (polygon != null)
              PolygonLayer(polygons: [polygon])
            else if (investigation.sourceUncertaintyKm != null)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: centerPoint,
                    radius: investigation.sourceUncertaintyKm! * 1000,
                    color: KairosTheme.saffron.withValues(alpha: 0.3),
                    borderColor: KairosTheme.saffron,
                    borderStrokeWidth: 2,
                    useRadiusInMeter: true,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CandidateVesselsTable extends StatelessWidget {
  final List<CandidateVessel> vessels;

  const _CandidateVesselsTable({required this.vessels});

  @override
  Widget build(BuildContext context) {
    if (vessels.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CANDIDATE VESSELS',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: KairosTheme.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: KairosTheme.surfaceWhite.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: KairosTheme.surfaceWhite.withValues(alpha: 0.4)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: KairosTheme.primaryNavy,
              ),
              dataTextStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: KairosTheme.primaryNavy,
              ),
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text('RANK')),
                DataColumn(label: Text('VESSEL NAME')),
                DataColumn(label: Text('MMSI')),
                DataColumn(label: Text('TYPE')),
                DataColumn(label: Text('COMPATIBILITY')),
              ],
              rows: vessels.map((v) {
                final compatColor =
                    KairosTheme.compatibilityColor(v.compatibility);
                return DataRow(cells: [
                  DataCell(Text('#${v.rank}')),
                  DataCell(Text(v.name)),
                  DataCell(Text(v.mmsi)),
                  DataCell(Text(v.vesselType)),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: compatColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        v.compatibility,
                        style: TextStyle(
                          color: compatColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
