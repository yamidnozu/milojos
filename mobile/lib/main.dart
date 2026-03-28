import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milojos_mobile/core/di/injection_container.dart';
import 'package:milojos_mobile/core/router/app_router.dart';
import 'package:milojos_mobile/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar inyección de dependencias
  await configureDependencies();

  runApp(const MilOjosApp());
}

class MilOjosApp extends StatelessWidget {
  const MilOjosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MilOjos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
