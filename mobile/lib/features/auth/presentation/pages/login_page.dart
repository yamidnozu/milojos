import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:milojos_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:milojos_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:milojos_mobile/features/auth/presentation/bloc/auth_state.dart';

/// Pantalla de Login Principal
/// Incluye integración para Vecinos (Google) y Estudiantes (QR)
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is Authenticated) {
            // Ir al Onboarding Maps (Simulación de 1era vez)
            context.go('/map');
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }
          
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // Logo interactivo
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        size: 64,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Títulos
                  Text(
                    'MilOjos',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: -1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'La red de seguridad comunitaria y escolar de Popayán.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 64),

                  // Botón Vecino (Google OAuth)
                  _buildLoginButton(
                    context: context,
                    icon: Icons.g_mobiledata_rounded,
                    label: 'Entrar como Vecino',
                    color: Colors.white,
                    textColor: Colors.black87,
                    isBordered: true,
                    onPressed: () {
                      context.read<AuthBloc>().add(SignInGoogleRequested());
                    },
                  ),
                  const SizedBox(height: 20),

                  // Separador
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'o matrícula escolar',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Botón Estudiante (QR)
                  _buildLoginButton(
                    context: context,
                    icon: Icons.qr_code_scanner_rounded,
                    label: 'Escanear QR de Estudiante',
                    color: Colors.red.shade600,
                    textColor: Colors.white,
                    isBordered: false,
                    onPressed: () {
                      context.push('/qr');
                    },
                  ),
                  const SizedBox(height: 40),

                  // Legal info (Compliance Agent Requirement)
                  Text(
                    'Al iniciar sesión aceptas nuestra Política de Tratamiento de Datos Personales registrada ante la SIC (Ley 1581).',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required bool isBordered,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        elevation: isBordered ? 0 : 4,
        shadowColor: color.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isBordered 
              ? BorderSide(color: Colors.grey.shade300) 
              : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

}
