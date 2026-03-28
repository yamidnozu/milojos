import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:milojos_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:milojos_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:milojos_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:milojos_mobile/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:milojos_mobile/features/map/presentation/pages/onboarding_map_location_page.dart';
import 'package:milojos_mobile/features/panic_alert/presentation/pages/panic_confirmation_page.dart';

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
        // FIXME: Lógica para saber si el usuario debe onboardear en el mapa.
        // Simularemos que todos van a '/map' una vez por Sprint 1, 
        // pero luego esto lo marca un booleano en UserEntity.
        
        // Si está en login y es auténtico: envíalo a Home.
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
      // Ruta extra para la Alerta en ModalFullScreen
      GoRoute(
        path: '/panic',
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: PanicConfirmationPage(),
        ),
      ),
    ],
  );
}
