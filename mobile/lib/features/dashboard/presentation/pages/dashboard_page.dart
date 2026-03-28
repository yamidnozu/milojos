import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milojos_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:milojos_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:milojos_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:milojos_mobile/features/panic_alert/presentation/bloc/panic_bloc.dart';
import 'package:milojos_mobile/features/panic_alert/presentation/bloc/panic_event.dart';
import 'package:milojos_mobile/features/panic_alert/presentation/widgets/shake_detector_widget.dart';

/// Pantalla Principal (Dashboard)
/// Envuelve toda la vista principal con el Detector de Shake
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // El ShakeDetectorWidget activará el PanicBloc globalmente si agitamos
    return ShakeDetectorWidget(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MilOjos', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.red.shade700,
          elevation: 1,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.black54),
              onPressed: () {
                context.read<AuthBloc>().add(SignOutRequested());
              },
            )
          ],
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = state.user;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bienvenida
              Text(
                'Hola, ${user.fullName}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.shield_rounded, color: Colors.green.shade600, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Sistema Comunitario Activo',
                    style: TextStyle(fontSize: 14, color: Colors.green.shade700, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // BOTÓN PRINCIPAL DE PÁNICO (MANUAL)
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Acción manual equivalente a Agitar el teléfono
                    context.read<PanicBloc>().add(const ShakeDetected());
                  },
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Colors.red.shade400, Colors.red.shade800],
                        center: Alignment.topLeft,
                        radius: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.shade900.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.touch_app_rounded, color: Colors.white, size: 50),
                        SizedBox(height: 12),
                        Text(
                          'S.O.S',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Toca o Agita',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 56),

              // OPCIONES SECUNDARIAS
              const Text(
                'Accesos Rápidos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  _buildQuickAction(
                    context,
                    icon: Icons.videocam_rounded,
                    label: 'Cámaras IP',
                    color: Colors.blue.shade600,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Módulo de video: Sprint 2'))
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildQuickAction(
                    context,
                    icon: Icons.notifications_active_rounded,
                    label: 'Alertas Locales',
                    color: Colors.orange.shade600,
                    onTap: () {},
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}
