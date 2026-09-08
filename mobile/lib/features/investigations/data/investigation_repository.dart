import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/investigation_model.dart';

class InvestigationRepository {
  final Dio _dio;

  InvestigationRepository(this._dio);

  Future<List<InvestigationListItem>> getInvestigations({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final response = await _dio.get('/investigations', queryParameters: {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
      'sortBy': 'assignedAt',
      'sortOrder': 'desc',
    });

    final data = response.data['data'] as List? ?? [];
    return data
        .map((j) => InvestigationListItem.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<InvestigationModel> getInvestigation(String id) async {
    final response = await _dio.get('/investigations/$id');
    return InvestigationModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> getMapData(String id) async {
    final response = await _dio.get('/investigations/$id/map');
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<void> acceptInvestigation(String id) async {
    await _dio.post('/investigations/$id/accept');
  }

  Future<void> startInvestigation(String id) async {
    await _dio.post('/investigations/$id/start');
  }
}

class InvestigationListItem {
  final String id;
  final String? assignmentId;
  final String assignmentStatus;
  final String priority;
  final DateTime? assignedAt;
  final String? fastApiStatus;

  const InvestigationListItem({
    required this.id,
    this.assignmentId,
    required this.assignmentStatus,
    required this.priority,
    this.assignedAt,
    this.fastApiStatus,
  });

  factory InvestigationListItem.fromJson(Map<String, dynamic> json) {
    return InvestigationListItem(
      id: json['id'] as String? ?? '',
      assignmentId: json['assignmentId'] as String?,
      assignmentStatus: json['assignmentStatus'] as String? ?? 'ASSIGNED',
      priority: json['priority'] as String? ?? 'MEDIUM',
      assignedAt: json['assignedAt'] != null
          ? DateTime.tryParse(json['assignedAt'] as String)
          : null,
      fastApiStatus: json['fastApiStatus'] as String?,
    );
  }
}

final investigationRepositoryProvider = Provider<InvestigationRepository>((ref) {
  return InvestigationRepository(DioClient.instance.dio);
});

final investigationsProvider = FutureProvider.autoDispose<List<InvestigationListItem>>((ref) {
  return ref.watch(investigationRepositoryProvider).getInvestigations();
});

final investigationDetailProvider = FutureProvider.autoDispose
    .family<InvestigationModel, String>((ref, id) {
  return ref.watch(investigationRepositoryProvider).getInvestigation(id);
});
