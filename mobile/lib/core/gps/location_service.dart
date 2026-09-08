import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/app_constants.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? heading;
  final double? speed;
  final DateTime timestamp;
  final bool isAccuracyPoor;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.heading,
    this.speed,
    required this.timestamp,
    required this.isAccuracyPoor,
  });
}

class LocationService {
  static Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  static Future<LocationData?> getCurrentLocation() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: KairosConstants.gpsTimeoutSeconds),
      );

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        heading: position.heading,
        speed: position.speed,
        timestamp: position.timestamp,
        isAccuracyPoor:
            position.accuracy > KairosConstants.gpsAccuracyWarningMeters,
      );
    } catch (e) {
      return null;
    }
  }

  static Stream<LocationData> getLocationStream() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    return Geolocator.getPositionStream(locationSettings: settings).map(
      (pos) => LocationData(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        altitude: pos.altitude,
        heading: pos.heading,
        speed: pos.speed,
        timestamp: pos.timestamp,
        isAccuracyPoor: pos.accuracy > KairosConstants.gpsAccuracyWarningMeters,
      ),
    );
  }

  /// Calculate bearing from start to end in degrees (0–360)
  static double calculateBearing(
    double startLat, double startLng, double endLat, double endLng,
  ) {
    final lat1 = startLat * (math.pi / 180);
    final lat2 = endLat * (math.pi / 180);
    final dLng = (endLng - startLng) * (math.pi / 180);

    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    final bearing = math.atan2(y, x) * (180 / math.pi);
    return (bearing + 360) % 360;
  }

  /// Calculate distance between two lat/lng points in km
  static double calculateDistanceKm(
    double lat1, double lng1, double lat2, double lng2,
  ) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000;
  }

  static String bearingToDirection(double bearing) {
    const directions = [
      'North', 'NNE', 'NE', 'ENE',
      'East', 'ESE', 'SE', 'SSE',
      'South', 'SSW', 'SW', 'WSW',
      'West', 'WNW', 'NW', 'NNW',
    ];
    final index = ((bearing + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }
}

final currentLocationProvider = StreamProvider<LocationData?>((ref) {
  return LocationService.getLocationStream()
      .cast<LocationData?>()
      .handleError((_) => null);
});
