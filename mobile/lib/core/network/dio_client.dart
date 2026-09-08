import 'package:dio/dio.dart';
import '../../shared/constants/app_constants.dart';
import '../storage/secure_storage_service.dart';

class DioClient {
  static DioClient? _instance;
  late final Dio _dio;

  DioClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: '${KairosConstants.apiBaseUrl}${KairosConstants.apiVersion}',
        connectTimeout: const Duration(seconds: KairosConstants.apiTimeoutSeconds),
        receiveTimeout: const Duration(seconds: KairosConstants.apiTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(_AuthInterceptor(_dio));
  }

  static DioClient get instance {
    _instance ??= DioClient._();
    return _instance!;
  }

  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;

  _AuthInterceptor(this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorageService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await SecureStorageService.getRefreshToken();
        if (refreshToken != null) {
          final response = await _dio.post(
            '/auth/refresh',
            data: {'refreshToken': refreshToken},
            options: Options(headers: {'Authorization': null}),
          );

          final newAccessToken = response.data['data']['accessToken'];
          final newRefreshToken = response.data['data']['refreshToken'];

          await SecureStorageService.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );

          // Retry original request
          err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          final retryResponse = await _dio.fetch(err.requestOptions);
          handler.resolve(retryResponse);
          return;
        }
      } catch (_) {
        // Refresh failed — clear tokens, user must log in again
        await SecureStorageService.clearAll();
      } finally {
        _isRefreshing = false;
      }
    }
    handler.next(err);
  }
}
