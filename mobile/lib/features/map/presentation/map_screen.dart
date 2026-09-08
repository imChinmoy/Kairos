import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../app/theme/kairos_theme.dart';
import '../../../core/gps/location_service.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();
  bool _isNavigating = false;

  // Demo source region (Arabian Sea) — in production comes from investigation
  static const _demoSourceCenter = LatLng(18.9388, 72.9153);

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(currentLocationProvider);

    return Scaffold(
      backgroundColor: KairosTheme.deepNavy,
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
              // OSM base tiles
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'in.ntro.kairos',
              ),

              // Source region uncertainty circle
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _demoSourceCenter,
                    radius: 5000, // 5 km radius in meters
                    color: KairosTheme.saffron.withOpacity(0.15),
                    borderColor: KairosTheme.saffron.withOpacity(0.6),
                    borderStrokeWidth: 2,
                    useRadiusInMeter: true,
                  ),
                ],
              ),

              // Source region polygon (center dot)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _demoSourceCenter,
                    width: 50,
                    height: 60,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: KairosTheme.navyBlue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Investigation\nArea',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Icon(Icons.location_pin,
                            color: KairosTheme.saffron, size: 24),
                      ],
                    ),
                  ),

                  // Officer location
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
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: KairosTheme.oceanBlue.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.navigation,
                            color: Colors.white, size: 18),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // App bar overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Layers button
                  _MapButton(
                    icon: Icons.layers_outlined,
                    onTap: () {},
                  ),
                  const Spacer(),
                  // Recenter button
                  _MapButton(
                    icon: Icons.my_location,
                    onTap: () async {
                      final loc = locationAsync.valueOrNull;
                      if (loc != null) {
                        _mapController.move(
                          LatLng(loc.latitude, loc.longitude),
                          12,
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  // Navigate to source
                  _MapButton(
                    icon: Icons.navigation_outlined,
                    onTap: () {
                      _mapController.move(_demoSourceCenter, 10);
                    },
                  ),
                ],
              ),
            ),
          ),

          // GPS accuracy warning
          if (locationAsync.valueOrNull?.isAccuracyPoor == true)
            Positioned(
              top: 80,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: KairosTheme.warning.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.gps_not_fixed, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'GPS accuracy: ±${locationAsync.valueOrNull!.accuracy!.toStringAsFixed(0)}m — Low accuracy. Wait for better signal.',
                        style: const TextStyle(color: Colors.white, fontSize: 11),
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
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: KairosTheme.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Distance / Bearing display
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
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _isNavigating = !_isNavigating),
                    icon: Icon(
                      _isNavigating ? Icons.stop : Icons.navigation,
                      size: 18,
                    ),
                    label: Text(
                      _isNavigating ? 'STOP NAVIGATION' : 'START NAVIGATION',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isNavigating
                          ? KairosTheme.error
                          : KairosTheme.oceanBlue,
                      minimumSize: const Size(double.infinity, 48),
                    ),
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: KairosTheme.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: KairosTheme.textPrimary, size: 20),
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
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: KairosTheme.textMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: KairosTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
