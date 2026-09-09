class InspectionReportModel {
  final String id;
  final String fastApiInvestigationId;
  final String status;
  final String? finding;
  final DateTime? submittedAt;
  final DateTime? updatedAt;
  final bool hasEvidence;

  InspectionReportModel({
    required this.id,
    required this.fastApiInvestigationId,
    required this.status,
    this.finding,
    this.submittedAt,
    this.updatedAt,
    this.hasEvidence = false,
  });

  factory InspectionReportModel.fromJson(Map<String, dynamic> json) {
    return InspectionReportModel(
      id: json['_id'] as String? ?? '',
      fastApiInvestigationId: json['fastApiInvestigationId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      finding: json['finding'] as String?,
      submittedAt: json['submittedAt'] != null ? DateTime.parse(json['submittedAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      hasEvidence: json['hasEvidence'] as bool? ?? false,
    );
  }
}
