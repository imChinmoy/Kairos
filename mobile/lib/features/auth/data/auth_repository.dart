import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../domain/auth_state.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/push_notification_service.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<AuthState> login(String identifier, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'identifier': identifier,
        'password': password,
      });

      final data = response.data['data'];
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

      await SecureStorageService.saveTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );

      await SecureStorageService.saveUserInfo(
        userId: user.id,
        employeeId: user.employeeId,
        name: user.name,
        role: user.role,
      );

      return AuthState.authenticated(user);
    } on DioException catch (e) {
      final message = e.response?.data?['error']?['message']
          as String? ?? 'Login failed. Please try again.';
      return AuthState.error(message);
    } catch (e) {
      return const AuthState.error('An unexpected error occurred.');
    }
  }

  Future<AuthState> restoreSession() async {
    try {
      final hasSession = await SecureStorageService.hasValidSession();
      if (!hasSession) return const AuthState.unauthenticated();

      final response = await _dio.get('/auth/me');
      final user = UserModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
      return AuthState.authenticated(user);
    } catch (e) {
      await SecureStorageService.clearAll();
      return const AuthState.unauthenticated();
    }
  }

  Future<void> logout(String? refreshToken) async {
    try {
      if (refreshToken != null) {
        await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
      }
    } finally {
      await SecureStorageService.clearAll();
    }
  }
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await _dio.put('/auth/fcm-token', data: {'fcmToken': fcmToken});
    } catch (e) {
      debugPrint('Failed to update FCM token: $e');
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(DioClient.instance.dio);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  Future<void> initialize() async {
    state = const AuthState.loading();
    final restoredState = await _repository.restoreSession();
    state = restoredState;
    if (restoredState.isAuthenticated) {
      await _syncFcmToken();
    }
  }

  Future<void> login(String identifier, String password) async {
    state = const AuthState.loading();
    final loginState = await _repository.login(identifier, password);
    state = loginState;
    if (loginState.isAuthenticated) {
      await _syncFcmToken();
    }
  }

  Future<void> _syncFcmToken() async {
    final token = await PushNotificationService.instance.getToken();
    if (token != null) {
      await _repository.updateFcmToken(token);
    }
    PushNotificationService.instance.onTokenRefresh.listen((newToken) {
      _repository.updateFcmToken(newToken);
    });
  }

  Future<void> logout() async {
    final refreshToken = await SecureStorageService.getRefreshToken();
    await _repository.logout(refreshToken);
    state = const AuthState.unauthenticated();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
