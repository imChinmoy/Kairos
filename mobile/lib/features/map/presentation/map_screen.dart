import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/kairos_theme.dart';
import '../../../core/gps/location_service.dart';
import '../../../shared/widgets/kairos_app_bar.dart';
import '../../../shared/widgets/kairos_action_button.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();
  bool _isNavigating = false;

  // Demo source region (Arabian Sea)
  static const _demoSourceCenter = LatLng(18.9388, 72.9153);

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(currentLocationProvider);

    return Scaffold(
      backgroundColor: KairosTheme.backgroundLight,
      appBar: const KairosAppBar(
        title: 'KAIROS',
        subtitle: 'Map Operations',
        showBackButton: false,
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _demoSourceCenter,
              initialZoom: 8,
              minZoom: 3,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'in.ntro.kairos',
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _demoSourceCenter,
                    radius: 5000,
                    color: KairosTheme.saffron.withOpacity(0.15),
                    borderColor: KairosTheme.saffron.withOpacity(0.6),
                    borderStrokeWidth: 2,
                    useRadiusInMeter: true,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _demoSourceCenter,
                    width: 50,
                    height: 60,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: KairosTheme.primaryNavy,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PROBABLE\nSOURCE',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: KairosTheme.surfaceWhite,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Icon(Icons.location_pin, color: KairosTheme.saffron, size: 24),
                      ],
                    ),
                  ),
                  if (locationAsync.valueOrNull != null)
                    Marker(
                      point: LatLng(
                        locationAsync.valueOrNull!.latitude,
                        locationAsync.valueOrNull!.longitude,
                      ),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: KairosTheme.oceanBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: KairosTheme.surfaceWhite, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: KairosTheme.oceanBlue.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.navigation, color: KairosTheme.surfaceWhite, size: 18),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Floating Action Buttons for Map Control
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                _MapButton(
                  icon: Icons.layers_outlined,
                  onTap: () {},
                ),
                const SizedBox(height: KairosTheme.spacing12),
                _MapButton(
                  icon: Icons.my_location,
                  onTap: () async {
                    final loc = locationAsync.valueOrNull;
                    if (loc != null) {
                      _mapController.move(LatLng(loc.latitude, loc.longitude), 12);
                    }
                  },
                ),
                const SizedBox(height: KairosTheme.spacing12),
                _MapButton(
                  icon: Icons.navigation_outlined,
                  onTap: () {
                    _mapController.move(_demoSourceCenter, 10);
                  },
                ),
              ],
            ),
          ),

          // GPS accuracy warning
          if (locationAsync.valueOrNull?.isAccuracyPoor == true)
            Positioned(
              top: 16,
              left: 16,
              right: 72,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: KairosTheme.warning.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(KairosTheme.radius8),
                  boxShadow: [
                    BoxShadow(color: KairosTheme.textPrimary.withOpacity(0.1), blurRadius: 4),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.gps_not_fixed, color: KairosTheme.surfaceWhite, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'GPS accuracy: ±${locationAsync.valueOrNull!.accuracy!.toStringAsFixed(0)}m — Low accuracy.',
                        style: GoogleFonts.inter(color: KairosTheme.surfaceWhite, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom navigation card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: KairosTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(KairosTheme.radius12),
                border: Border.all(color: KairosTheme.borderGrey, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: KairosTheme.textPrimary.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NavStat(
                        label: 'DISTANCE',
                        value: locationAsync.when(
                          data: (loc) {
                            if (loc == null) return '--';
                            final dist = LocationService.calculateDistanceKm(
                              loc.latitude,
                              loc.longitude,
                              _demoSourceCenter.latitude,
                              _demoSourceCenter.longitude,
                            );
                            return '${dist.toStringAsFixed(1)} km';
                          },
                          loading: () => '--',
                          error: (_, __) => '--',
                        ),
                      ),
                      _NavStat(
                        label: 'BEARING',
                        value: locationAsync.when(
                          data: (loc) {
                            if (loc == null) return '--';
                            final bearing = LocationService.calculateBearing(
                              loc.latitude,
                              loc.longitude,
                              _demoSourceCenter.latitude,
                              _demoSourceCenter.longitude,
                            );
                            return '${bearing.toStringAsFixed(0)}°';
                          },
                          loading: () => '--',
                          error: (_, __) => '--',
                        ),
                      ),
                      _NavStat(
                        label: 'DIRECTION',
                        value: locationAsync.when(
                          data: (loc) {
                            if (loc == null) return '--';
                            final bearing = LocationService.calculateBearing(
                              loc.latitude,
                              loc.longitude,
                              _demoSourceCenter.latitude,
                              _demoSourceCenter.longitude,
                            );
                            return LocationService.bearingToDirection(bearing);
                          },
                          loading: () => '--',
                          error: (_, __) => '--',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  KairosActionButton(
                    label: _isNavigating ? 'STOP NAVIGATION' : 'NAVIGATE',
                    icon: _isNavigating ? Icons.stop_rounded : Icons.navigation_rounded,
                    color: _isNavigating ? KairosTheme.error : KairosTheme.oceanBlue,
                    onPressed: () => setState(() => _isNavigating = !_isNavigating),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: KairosTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(KairosTheme.radius8),
          border: Border.all(color: KairosTheme.borderGrey, width: 1),
          boxShadow: [
            BoxShadow(
              color: KairosTheme.textPrimary.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: KairosTheme.primaryNavy, size: 20),
      ),
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
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: KairosTheme.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: KairosTheme.primaryNavy,
          ),
        ),
      ],
    );
  }
}
