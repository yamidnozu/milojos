import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milojos_mobile/core/di/injection_container.dart';
import 'package:milojos_mobile/core/router/app_router.dart';
import 'package:milojos_mobile/core/theme/app_theme.dart';

// Mocks instanciados en GetIt idealmente, per para inyectarlo directo:
import 'package:milojos_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:milojos_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:milojos_mobile/features/panic_alert/presentation/bloc/panic_bloc.dart';
import 'package:milojos_mobile/features/panic_alert/domain/usecases/trigger_panic_alert_usecase.dart';
import 'package:milojos_mobile/features/panic_alert/data/repositories/alert_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:milojos_mobile/core/constants/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  // Inicializar inyección de dependencias
  await configureDependencies();

  runApp(const MilOjosApp());
}

class MilOjosApp extends StatelessWidget {
  const MilOjosApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicialización manual de Providers en la raíz
    // Sprint 1: Instancia temporal antes de inyección GetIt estricta
    final supabase = Supabase.instance.client;
    final authRepository = AuthRepositoryImpl(supabase: supabase);
    final alertRepository = AlertRepositoryImpl(authProvider: authRepository);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: authRepository),
        ),
        BlocProvider<PanicBloc>(
          create: (context) => PanicBloc(
            triggerPanicAlert: TriggerPanicAlertUseCase(repository: alertRepository),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'MilOjos',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
