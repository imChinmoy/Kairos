class GeoJsonGeometry {
  final String type;
  final dynamic coordinates;

  const GeoJsonGeometry({required this.type, required this.coordinates});

  factory GeoJsonGeometry.fromJson(Map<String, dynamic> json) {
    return GeoJsonGeometry(
      type: json['type'] as String,
      coordinates: json['coordinates'],
    );
  }

  /// Returns center point [lat, lng] for simple polygons
  List<double>? get center {
    if (type == 'Polygon' && coordinates is List) {
      final ring = (coordinates as List).first as List;
      double sumLat = 0, sumLng = 0;
      for (final pt in ring) {
        if (pt is List) {
          sumLng += (pt[0] as num).toDouble();
          sumLat += (pt[1] as num).toDouble();
        }
      }
      final count = ring.length;
      if (count > 0) return [sumLat / count, sumLng / count];
    }
    return null;
  }
}

class CandidateVessel {
  final int rank;
  final String vesselId;
  final String name;
  final String mmsi;
  final String vesselType;
  final double attributionScore;
  final String compatibility;
  final Map<String, double> evidence;
  final List<String> explanations;

  const CandidateVessel({
    required this.rank,
    required this.vesselId,
    required this.name,
    required this.mmsi,
    required this.vesselType,
    required this.attributionScore,
    required this.compatibility,
    required this.evidence,
    required this.explanations,
  });

  factory CandidateVessel.fromJson(Map<String, dynamic> json) {
    final ev = (json['evidence'] as Map<String, dynamic>?) ?? {};
    return CandidateVessel(
      rank: json['rank'] as int? ?? 0,
      vesselId: json['vesselId'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Vessel',
      mmsi: json['mmsi'] as String? ?? '',
      vesselType: json['vesselType'] as String? ?? '',
      attributionScore: (json['attributionScore'] as num?)?.toDouble() ?? 0,
      compatibility: json['compatibility'] as String? ?? 'LOW',
      evidence: {
        'spatial': (ev['spatial'] as num?)?.toDouble() ?? 0,
        'temporal': (ev['temporal'] as num?)?.toDouble() ?? 0,
        'drift': (ev['drift'] as num?)?.toDouble() ?? 0,
        'trajectory': (ev['trajectory'] as num?)?.toDouble() ?? 0,
        'aisQuality': (ev['aisQuality'] as num?)?.toDouble() ?? 0,
      },
      explanations: List<String>.from(json['explanations'] as List? ?? []),
    );
  }
}

class ModelConditions {
  final double? windSpeedKn;
  final String? windDirection;
  final double? currentSpeedKn;
  final String? currentDirection;

  const ModelConditions({
    this.windSpeedKn,
    this.windDirection,
    this.currentSpeedKn,
    this.currentDirection,
  });

  factory ModelConditions.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ModelConditions();
    return ModelConditions(
      windSpeedKn: (json['windSpeedKn'] as num?)?.toDouble(),
      windDirection: json['windDirection'] as String?,
      currentSpeedKn: (json['currentSpeedKn'] as num?)?.toDouble(),
      currentDirection: json['currentDirection'] as String?,
    );
  }

  String get windSummary {
    if (windSpeedKn == null) return 'N/A';
    final speedKmh = (windSpeedKn! * 1.852).toStringAsFixed(0);
    return '$speedKmh km/h ${windDirection ?? ''}';
  }

  String get currentSummary {
    if (currentSpeedKn == null) return 'N/A';
    return '${currentSpeedKn!.toStringAsFixed(1)} kn ${currentDirection ?? ''}';
  }
}

class InvestigationModel {
  final String id;
  final String? fastApiStatus;
  final String assignmentStatus;
  final String priority;
  final DateTime? assignedAt;
  final GeoJsonGeometry? sourceRegion;
  final List<double>? targetLocation;
  final GeoJsonGeometry? slickGeometry;
  final DateTime? releaseStart;
  final DateTime? releaseEnd;
  final double? sourceUncertaintyKm;
  final ModelConditions? modelConditions;
  final List<CandidateVessel> candidateVessels;
  final FieldInspectionSummary? fieldInspection;
  final double? detectionConfidence;
  final double? detectionAreaKm2;

  const InvestigationModel({
    required this.id,
    this.fastApiStatus,
    required this.assignmentStatus,
    required this.priority,
    this.assignedAt,
    this.sourceRegion,
    this.targetLocation,
    this.slickGeometry,
    this.releaseStart,
    this.releaseEnd,
    this.sourceUncertaintyKm,
    this.modelConditions,
    required this.candidateVessels,
    this.fieldInspection,
    this.detectionConfidence,
    this.detectionAreaKm2,
  });

  factory InvestigationModel.fromJson(Map<String, dynamic> json) {
    GeoJsonGeometry? parseGeometry(dynamic geo) {
      if (geo == null) return null;
      try { return GeoJsonGeometry.fromJson(geo as Map<String, dynamic>); }
      catch (_) { return null; }
    }

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      try { return DateTime.parse(val as String); }
      catch (_) { return null; }
    }

    final tw = json['releaseTimeWindow'] as Map<String, dynamic>?;

    return InvestigationModel(
      id: json['id'] as String? ?? '',
      fastApiStatus: json['fastApiStatus'] as String?,
      assignmentStatus: json['assignmentStatus'] as String? ?? 'ASSIGNED',
      priority: json['priority'] as String? ?? 'MEDIUM',
      assignedAt: parseDate(json['assignedAt']),
      sourceRegion: parseGeometry(json['sourceRegion']),
      targetLocation: json['targetLocation'] != null
          ? [
              (json['targetLocation']['latitude'] as num).toDouble(),
              (json['targetLocation']['longitude'] as num).toDouble(),
            ]
          : null,
      slickGeometry: parseGeometry(json['detection']?['geometry']),
      releaseStart: parseDate(tw?['start']),
      releaseEnd: parseDate(tw?['end']),
      sourceUncertaintyKm: (json['sourceUncertaintyKm'] as num?)?.toDouble(),
      modelConditions: ModelConditions.fromJson(
        json['modelConditions'] as Map<String, dynamic>?,
      ),
      candidateVessels: (json['candidateVessels'] as List? ?? [])
          .map((v) => CandidateVessel.fromJson(v as Map<String, dynamic>))
          .toList(),
      fieldInspection: json['fieldInspection'] != null
          ? FieldInspectionSummary.fromJson(
              json['fieldInspection'] as Map<String, dynamic>)
          : null,
      detectionConfidence:
          (json['detection']?['confidence'] as num?)?.toDouble(),
      detectionAreaKm2: (json['detection']?['areaKm2'] as num?)?.toDouble(),
    );
  }

  String get title {
    final confidence = detectionConfidence;
    if (confidence == null) return 'Oil Spill Investigation — $id';
    if (confidence > 0.85) return 'High Confidence Oil Spill';
    if (confidence > 0.6) return 'Probable Oil Spill';
    return 'Suspected Oil Spill';
  }

  bool get hasSourceRegion => sourceRegion != null;

  List<double>? get sourceCenter => targetLocation ?? sourceRegion?.center;
}

class FieldInspectionSummary {
  final String? id;
  final String status;
  final DateTime? startedAt;

  const FieldInspectionSummary({
    this.id,
    required this.status,
    this.startedAt,
  });

  factory FieldInspectionSummary.fromJson(Map<String, dynamic> json) {
    return FieldInspectionSummary(
      id: json['id'] as String?,
      status: json['status'] as String? ?? 'NOT_STARTED',
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'] as String)
          : null,
    );
  }
}
