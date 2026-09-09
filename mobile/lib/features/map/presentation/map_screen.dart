import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/kairos_theme.dart';
import '../../../core/gps/location_service.dart';
import '../../../shared/widgets/kairos_app_bar.dart';
import '../../investigations/data/investigation_repository.dart';
import '../../investigations/domain/investigation_model.dart';
import '../../../shared/widgets/kairos_action_button.dart';

class MapScreen extends ConsumerStatefulWidget {
  final String? initialInvestigationId;
  const MapScreen({super.key, this.initialInvestigationId});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();
  String? _selectedInvestigationId;
  bool _didInitialize = false;
  bool _isNavigating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitialize) {
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      if (extra != null && extra['investigationId'] != null) {
        _selectedInvestigationId = extra['investigationId'] as String;
      } else {
        _selectedInvestigationId = widget.initialInvestigationId;
      }
      _didInitialize = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(currentLocationProvider);
    final investigationsAsync = ref.watch(investigationsProvider);

    return Scaffold(
      backgroundColor: KairosTheme.backgroundLight,
      appBar: const KairosAppBar(
        title: 'KAIROS',
        subtitle: 'Map Operations',
        showBackButton: true,
      ),
      body: Stack(
        children: [
          // If selected, watch detail
          if (_selectedInvestigationId != null)
            ref.watch(investigationDetailProvider(_selectedInvestigationId!)).when(
              data: (inv) => _buildMapContent(inv, locationAsync),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading details: $e')),
            )
          else
            _buildMapContent(null, locationAsync),

          // Dropdown Overlay
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: KairosTheme.surfaceWhite.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: KairosTheme.primaryNavy.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: investigationsAsync.when(
                data: (list) {
                  return DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedInvestigationId,
                      hint: Text('Select Investigation', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      items: list.map((inv) {
                        return DropdownMenuItem(
                          value: inv.id,
                          child: Text('Investigation ${inv.id.substring(inv.id.length - 6).toUpperCase()}', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedInvestigationId = val;
                        });
                      },
                    ),
                  );
                },
                loading: () => const Padding(padding: EdgeInsets.all(12), child: LinearProgressIndicator()),
                error: (e, _) => const Padding(padding: EdgeInsets.all(12), child: Text('Failed to load investigations')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapContent(InvestigationModel? inv, AsyncValue locationAsync) {
    // Determine map center and geometry
    LatLng centerPoint = const LatLng(18.9388, 72.9153);
    Polygon? polygon;
    double? radius;

    if (inv != null) {
      final geo = inv.sourceRegion ?? inv.slickGeometry;
      final cCoord = geo?.center;
      if (cCoord != null) {
        centerPoint = LatLng(cCoord[0], cCoord[1]);
      }
      
      final pts = geo?.polygonPoints;
      if (pts != null) {
        polygon = Polygon(
          points: pts.map((p) => LatLng(p[0], p[1])).toList(),
          color: KairosTheme.saffron.withValues(alpha: 0.3),
          borderColor: KairosTheme.saffron,
          borderStrokeWidth: 2,
          isFilled: true,
        );
      } else if (inv.sourceUncertaintyKm != null) {
        radius = inv.sourceUncertaintyKm! * 1000;
      }
    }

    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: centerPoint,
                  initialZoom: 8,
                  minZoom: 3,
                  maxZoom: 18,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'in.ntro.kairos',
                  ),
                  if (polygon != null)
                    PolygonLayer(polygons: [polygon])
                  else if (radius != null)
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: centerPoint,
                          radius: radius,
                          color: KairosTheme.saffron.withValues(alpha: 0.15),
                          borderColor: KairosTheme.saffron.withValues(alpha: 0.6),
                          borderStrokeWidth: 2,
                          useRadiusInMeter: true,
                        ),
                      ],
                    ),
                  
                  // Location marker
                  if (locationAsync.hasValue && locationAsync.value != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            locationAsync.value!.latitude,
                            locationAsync.value!.longitude,
                          ),
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: KairosTheme.primaryNavy,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: KairosTheme.primaryNavy.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.navigation, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              
              // Bottom Sheet / Controls overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: KairosTheme.surfaceWhite,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: KairosTheme.primaryNavy.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: KairosTheme.success.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: KairosTheme.success,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'GPS ACTIVE',
                                      style: GoogleFonts.inter(
                                        color: KairosTheme.success,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              if (locationAsync.hasValue && locationAsync.value != null)
                                Text(
                                  'ACCURACY: ${(locationAsync.value!.accuracy).toStringAsFixed(1)}m',
                                  style: GoogleFonts.inter(
                                    color: KairosTheme.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _NavStat(
                                  label: 'SPEED',
                                  value: locationAsync.hasValue && locationAsync.value != null
                                      ? '${(locationAsync.value!.speed * 3.6).toStringAsFixed(1)} km/h'
                                      : '--',
                                ),
                              ),
                              Container(width: 1, height: 40, color: KairosTheme.borderGrey),
                              Expanded(
                                child: _NavStat(
                                  label: 'HEADING',
                                  value: locationAsync.hasValue && locationAsync.value != null
                                      ? '${locationAsync.value!.heading.toStringAsFixed(0)}°'
                                      : '--',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          KairosActionButton(
                            label: _isNavigating ? 'STOP NAVIGATION' : 'START NAVIGATION TO AREA',
                            icon: _isNavigating ? Icons.stop_rounded : Icons.navigation_rounded,
                            color: _isNavigating ? KairosTheme.error : KairosTheme.oceanBlue,
                            onPressed: () {
                              setState(() {
                                _isNavigating = !_isNavigating;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Current location FAB
              Positioned(
                right: 20,
                bottom: 260,
                child: FloatingActionButton(
                  backgroundColor: KairosTheme.surfaceWhite,
                  onPressed: () {
                    if (locationAsync.hasValue && locationAsync.value != null) {
                      _mapController.move(
                        LatLng(
                          locationAsync.value!.latitude,
                          locationAsync.value!.longitude,
                        ),
                        14.0,
                      );
                    }
                  },
                  child: const Icon(Icons.my_location, color: KairosTheme.primaryNavy),
                ),
              ),
            ],
          ),
        ),
        
        // Candidate Vessels mini-table below the map if available
        if (inv != null && inv.candidateVessels.isNotEmpty)
          Expanded(
            flex: 3,
            child: Container(
              color: KairosTheme.surfaceWhite,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CANDIDATE VESSELS',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: KairosTheme.primaryNavy),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingTextStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: KairosTheme.primaryNavy),
                          dataTextStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: KairosTheme.primaryNavy),
                          columnSpacing: 24,
                          columns: const [
                            DataColumn(label: Text('RANK')),
                            DataColumn(label: Text('VESSEL NAME')),
                            DataColumn(label: Text('MMSI')),
                            DataColumn(label: Text('COMPATIBILITY')),
                          ],
                          rows: inv.candidateVessels.map((v) {
                            final compatColor = KairosTheme.compatibilityColor(v.compatibility);
                            return DataRow(cells: [
                              DataCell(Text('#${v.rank}')),
                              DataCell(Text(v.name)),
                              DataCell(Text(v.mmsi)),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: compatColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    v.compatibility,
                                    style: TextStyle(color: compatColor, fontSize: 10, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _NavStat extends StatelessWidget {
  final String label;
  final String value;

  const _NavStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: KairosTheme.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            color: KairosTheme.primaryNavy,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
