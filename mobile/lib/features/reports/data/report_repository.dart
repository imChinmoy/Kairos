import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/report_model.dart';

class ReportRepository {
  final Dio _dio;

  ReportRepository(this._dio);

  Future<List<InspectionReportModel>> getMyInspections() async {
    final res = await _dio.get('/inspections');
    final data = res.data['data'] as List;
    return data.map((e) => InspectionReportModel.fromJson(e)).toList();
  }
}

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(DioClient.instance.dio);
});

final inspectionReportsProvider = FutureProvider<List<InspectionReportModel>>((ref) async {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getMyInspections();
});
