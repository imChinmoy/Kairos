import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/dashboard/presentation/home_screen.dart';
import '../features/investigations/presentation/investigation_list_screen.dart';
import '../features/investigations/presentation/investigation_detail_screen.dart';
import '../features/map/presentation/map_screen.dart';
import '../features/inspection/presentation/inspection_screen.dart';
import '../features/inspection/presentation/observation_screen.dart';
import '../features/evidence/presentation/evidence_capture_screen.dart';
import '../features/sos/presentation/sos_screen.dart';
import '../features/reports/presentation/report_screen.dart';
import 'shell/main_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final location = state.uri.path;

      if (isLoading) return '/splash';

      if (!isAuthenticated && location != '/login') {
        return '/login';
      }

      if (isAuthenticated && (location == '/login' || location == '/splash')) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/map', builder: (_, __) => const MapScreen()),
          GoRoute(path: '/sos', builder: (_, __) => const SosScreen()),
          GoRoute(path: '/reports', builder: (_, __) => const ReportScreen()),
          GoRoute(
            path: '/investigations',
            builder: (_, __) => const InvestigationListScreen(),
          ),
        ],
      ),
      // Full-screen routes (no shell)
      GoRoute(
        path: '/investigations/:id',
        builder: (_, state) => InvestigationDetailScreen(
          investigationId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/investigations/:id/inspect',
        builder: (_, state) => InspectionScreen(
          investigationId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/inspections/:id/observe',
        builder: (_, state) => ObservationScreen(
          inspectionId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/inspections/:id/capture',
        builder: (_, state) => EvidenceCaptureScreen(
          inspectionId: state.pathParameters['id']!,
          investigationId: state.uri.queryParameters['invId'] ?? '',
        ),
      ),
    ],
  );
});
