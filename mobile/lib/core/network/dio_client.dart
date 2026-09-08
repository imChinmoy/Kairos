import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../shared/constants/app_constants.dart';

class DioClient {
  static DioClient? _instance;
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

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

    _dio.interceptors.add(_AuthInterceptor(_secureStorage, _dio));
  }

  static DioClient get instance {
    _instance ??= DioClient._();
    return _instance!;
  }

  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;
  bool _isRefreshing = false;

  _AuthInterceptor(this._storage, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'access_token');
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
        final refreshToken = await _storage.read(key: 'refresh_token');
        if (refreshToken != null) {
          final response = await _dio.post(
            '/auth/refresh',
            data: {'refreshToken': refreshToken},
            options: Options(headers: {'Authorization': null}),
          );

          final newAccessToken = response.data['data']['accessToken'];
          final newRefreshToken = response.data['data']['refreshToken'];

          await _storage.write(key: 'access_token', value: newAccessToken);
          await _storage.write(key: 'refresh_token', value: newRefreshToken);

          // Retry original request
          err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          final retryResponse = await _dio.fetch(err.requestOptions);
          handler.resolve(retryResponse);
          return;
        }
      } catch (_) {
        // Refresh failed — clear tokens, user must log in again
        await _storage.deleteAll();
      } finally {
        _isRefreshing = false;
      }
    }
    handler.next(err);
  }
}
