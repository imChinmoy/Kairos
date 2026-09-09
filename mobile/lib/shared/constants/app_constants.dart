/// App-wide constants for KAIROS
class KairosConstants {
  KairosConstants._();

  // API
  static const String apiBaseUrl = 'https://kairos-mobile.onrender.com';
  static const String apiVersion = '/api/v1';
  static const int apiTimeoutSeconds = 60;

  // App info
  static const String appName = 'KAIROS';
  static const String appTagline = 'Field Intelligence for Safer Seas';
  static const String appSubTagline = 'Clean Seas | Secure Coasts | Stronger India';
  static const String appOrg = 'Ministry of Ports, Shipping and Waterways\nGovernment of India';

  // Hive box names
  static const String authBox = 'auth_box';
  static const String investigationBox = 'investigation_box';
  static const String inspectionBox = 'inspection_box';
  static const String observationBox = 'observation_box';
  static const String evidenceBox = 'evidence_box';
  static const String syncQueueBox = 'sync_queue_box';
  static const String settingsBox = 'settings_box';

  // GPS
  static const double gpsAccuracyWarningMeters = 50.0;
  static const int gpsTimeoutSeconds = 30;

  // Sync
  static const int maxRetryCount = 5;
  static const int initialRetryDelaySeconds = 10;
  static const int syncIntervalSeconds = 30;

  // Navigation
  static const double earthRadiusKm = 6371.0;

  // Demo
  static const bool isDemoMode = true;
  static const String demoLabel = '[DEMO DATA]';

  // Hive type IDs
  static const int investigationCacheTypeId = 0;
  static const int inspectionDraftTypeId = 1;
  static const int localEvidenceTypeId = 2;
  static const int syncQueueItemTypeId = 3;
  static const int localObservationTypeId = 4;
}
