import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:milojos_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:milojos_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:milojos_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:milojos_mobile/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:milojos_mobile/features/map/presentation/pages/onboarding_map_location_page.dart';
import 'package:milojos_mobile/features/panic_alert/presentation/pages/panic_confirmation_page.dart';

import 'package:milojos_mobile/features/cameras/presentation/pages/camera_stream_page.dart';
import 'package:milojos_mobile/features/subscriptions/presentation/pages/subscription_paywall_page.dart';
import 'package:milojos_mobile/features/auth/presentation/pages/qr_scanner_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    // Middleware de redirección (Guards de rutas)
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      
      final isLoggingIn = state.uri.toString() == '/login';
      
      // Si el estado es aún Init, lo dejamos en splash/login
      if (authState is AuthInitial || authState is AuthLoading) {
        return null; // GoRouter se mantiene donde está o muestra loader (si hubiera pantalla)
      }
      
      // Si no está autenticado, siempre mandarlo a /login
      if (authState is Unauthenticated) {
        return isLoggingIn ? null : '/login';
      }
      
      // Si está autenticado
      if (authState is Authenticated) {
        // En un caso real se usa bool hasSeenOnboarding, iteramos al Home desde Login por brevedad
        if (isLoggingIn) return '/home';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const OnboardingMapLocationPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/panic',
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: PanicConfirmationPage(),
        ),
      ),
      GoRoute(
        path: '/qr',
        builder: (context, state) => const QrScannerPage(),
      ),
      GoRoute(
        path: '/camera/:id',
        builder: (context, state) => CameraStreamPage(
          cameraId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionPaywallPage(),
      ),
    ],
  );
}
