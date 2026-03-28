import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milojos_mobile/core/errors/failures.dart';
import 'package:milojos_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:milojos_mobile/features/auth/presentation/bloc/auth_state.dart';
// Note: en un proyecto real importaríamos flutter_map o google_maps_flutter
// import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Pantalla donde el Vecino elige su casa en el Mapa para su registro en PostGIS
class OnboardingMapLocationPage extends StatefulWidget {
  const OnboardingMapLocationPage({super.key});

  @override
  State<OnboardingMapLocationPage> createState() => _OnboardingMapLocationPageState();
}

class _OnboardingMapLocationPageState extends State<OnboardingMapLocationPage> {
  // LatLng _currentSelectedLocation = const LatLng(2.4448, -76.6147); // Popayán, Cauca
  bool _isSaving = false;

  void _saveLocationToBackend(BuildContext context) async {
    setState(() => _isSaving = true);

    // Mock HTTP PUT a nuestro nuevo endpoint NestJS: /v1/users/:id/location
    // En Sprint 1 usamos DioClient() aquí
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isSaving = false);

    // UX: Redireccionar al Home del app.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Vivienda georreferenciada exitosamente en la red.'),
        backgroundColor: Colors.green,
      ),
    );
    // context.go('/home'); // GoRouter integration later
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final user = (state is Authenticated) ? state.user : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Ubica tu vivienda'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. EL MAPA (Mock para MVP/Sprint 1)
          Container(
            color: Colors.grey.shade200,
            width: double.infinity,
            height: double.infinity,
            child: InteractiveViewer(
              maxScale: 2.5,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Imagen mock del mapa
                  const Opacity(
                    opacity: 0.6,
                    child: Icon(Icons.map_rounded, size: 200, color: Colors.grey),
                  ),
                  // MOCK PIN de ubicación
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.shade900.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.home_rounded, color: Colors.white, size: 30),
                      ),
                      Container(width: 2, height: 20, color: Colors.red.shade900),
                      Container(width: 8, height: 4, decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.rectangle)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 2. PANEL INFERIOR CON INSTRUCCIONES
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '¡Hola ${user?.fullName?.split(' ').first ?? 'Vecino'}!',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'MilOjos funciona conectando vecinos a 500 metros a la redonda. Mueve el mapa hasta que el PIN rojo apunte a tu vivienda.',
                    style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  
                  // Aviso Legal de Compliance
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100)
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.privacy_tip_rounded, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'La ubicación de tu casa se almacena cifrada. No la mostraremos públicamente.',
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // BOTÓN GUARDAR
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : () => _saveLocationToBackend(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Confirmar Ubicación (Popayán)',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
