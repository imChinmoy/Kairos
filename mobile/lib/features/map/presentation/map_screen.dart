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
  LatLng? _mockStartLocation;

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
            ref
                .watch(investigationDetailProvider(_selectedInvestigationId!))
                .when(
                  data: (inv) => _buildMapContent(inv, locationAsync),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Center(child: Text('Error loading details: $e')),
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
                  BoxShadow(
                      color: KairosTheme.primaryNavy.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: investigationsAsync.when(
                data: (list) {
                  return DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedInvestigationId,
                      hint: Text('Select Investigation',
                          style:
                              GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      items: list.map((inv) {
                        return DropdownMenuItem(
                          value: inv.id,
                          child: Text(
                              'Investigation ${inv.id.substring(inv.id.length - 6).toUpperCase()}',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
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
                loading: () => const Padding(
                    padding: EdgeInsets.all(12),
                    child: LinearProgressIndicator()),
                error: (e, _) => const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Failed to load investigations')),
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
        );
      } else if (inv.sourceUncertaintyKm != null) {
        radius = inv.sourceUncertaintyKm! * 1000;
      }
    }

    String distanceStr = '--';
    String directionStr = '--';
    
    if (locationAsync.hasValue && locationAsync.value != null) {
      double dist = LocationService.calculateDistanceKm(
          locationAsync.value!.latitude, locationAsync.value!.longitude,
          centerPoint.latitude, centerPoint.longitude);
      double bearing = LocationService.calculateBearing(
          locationAsync.value!.latitude, locationAsync.value!.longitude,
          centerPoint.latitude, centerPoint.longitude);
      
      distanceStr = '${dist.toStringAsFixed(1)} km';
      directionStr = LocationService.bearingToDirection(bearing);
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: centerPoint,
            initialZoom: 8,
            minZoom: 3,
            maxZoom: 18,
            onTap: (tapPosition, point) {
              if (!_isNavigating) {
                setState(() {
                  _mockStartLocation = point;
                });
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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

            if (_mockStartLocation != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [_mockStartLocation!, centerPoint],
                    color: KairosTheme.oceanBlue,
                    strokeWidth: 4,
                  ),
                ],
              ),

            if (inv != null && inv.candidateVessels.isNotEmpty)
              MarkerLayer(
                markers: inv.candidateVessels
                    .where((v) => v.location != null)
                    .map((v) {
                  return Marker(
                    point: LatLng(v.location![0], v.location![1]),
                    width: 40,
                    height: 40,
                    child: Transform.rotate(
                      angle: (v.heading ?? 0) * (3.14159 / 180),
                      child: Icon(Icons.navigation,
                          color: KairosTheme.saffron, size: 28),
                    ),
                  );
                }).toList(),
              ),

            if (_mockStartLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _mockStartLocation!,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isNavigating
                            ? KairosTheme.oceanBlue
                            : KairosTheme.saffron,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: KairosTheme.primaryNavy
                                .withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                          _isNavigating
                              ? Icons.navigation
                              : Icons.person_pin_circle,
                          color: Colors.white,
                          size: 20),
                    ),
                  ),
                ],
              )
            else if (locationAsync.hasValue &&
                locationAsync.value != null)
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
                            color: KairosTheme.primaryNavy
                                .withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.navigation,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
          ],
        ),

        Positioned(
          right: 20,
          top: 90,
          child: FloatingActionButton(
            backgroundColor: KairosTheme.surfaceWhite,
            mini: true,
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
            child: const Icon(Icons.my_location,
                color: KairosTheme.primaryNavy),
          ),
        ),

        DraggableScrollableSheet(
          initialChildSize: 0.28,
          minChildSize: 0.15,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: KairosTheme.surfaceWhite,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: KairosTheme.primaryNavy.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: KairosTheme.borderGrey,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: KairosTheme.success
                                  .withValues(alpha: 0.1),
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
                          if (locationAsync.hasValue &&
                              locationAsync.value != null)
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
                              label: 'DISTANCE',
                              value: distanceStr,
                            ),
                          ),
                          Container(
                              width: 1,
                              height: 40,
                              color: KairosTheme.borderGrey),
                          Expanded(
                            child: _NavStat(
                              label: 'DIRECTION',
                              value: directionStr,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (!_isNavigating)
                        KairosActionButton(
                          label: 'SET START FROM GPS',
                          icon: Icons.my_location,
                          color: KairosTheme.saffron,
                          onPressed: () {
                            setState(() {
                              if (locationAsync.hasValue &&
                                  locationAsync.value != null) {
                                _mockStartLocation = LatLng(
                                    locationAsync.value!.latitude,
                                    locationAsync.value!.longitude);
                              } else {
                                _mockStartLocation = LatLng(
                                    centerPoint.latitude - 0.05,
                                    centerPoint.longitude - 0.05);
                              }
                              _mapController.move(
                                  _mockStartLocation!, 12.0);
                            });
                          },
                        ),
                      const SizedBox(height: 12),
                      KairosActionButton(
                        label: _isNavigating
                            ? 'STOP NAVIGATION'
                            : 'START NAVIGATION TO AREA',
                        icon: _isNavigating
                            ? Icons.stop_rounded
                            : Icons.navigation_rounded,
                        color: _isNavigating
                            ? KairosTheme.error
                            : KairosTheme.oceanBlue,
                        onPressed: () {
                          if (_mockStartLocation == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Please tap on map or Set Start from GPS first')));
                            return;
                          }
                          setState(() {
                            _isNavigating = !_isNavigating;
                            if (_isNavigating) {
                              _mapController.move(
                                  _mockStartLocation!, 14.0);
                            }
                          });
                        },
                      ),
                      if (inv != null && inv.candidateVessels.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        Text(
                          'CANDIDATE VESSELS',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: KairosTheme.primaryNavy),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingTextStyle: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: KairosTheme.primaryNavy),
                            dataTextStyle: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: KairosTheme.primaryNavy),
                            columnSpacing: 24,
                            columns: const [
                              DataColumn(label: Text('RANK')),
                              DataColumn(label: Text('VESSEL NAME')),
                              DataColumn(label: Text('MMSI')),
                              DataColumn(label: Text('COMPATIBILITY')),
                            ],
                            rows: inv.candidateVessels.map((v) {
                              final compatColor =
                                  KairosTheme.compatibilityColor(v.compatibility);
                              return DataRow(cells: [
                                DataCell(Text('#${v.rank}')),
                                DataCell(Text(v.name)),
                                DataCell(Text(v.mmsi)),
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
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
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
