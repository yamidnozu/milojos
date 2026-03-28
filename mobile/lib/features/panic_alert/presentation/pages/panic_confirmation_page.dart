import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milojos_mobile/features/panic_alert/presentation/bloc/panic_bloc.dart';
import 'package:milojos_mobile/features/panic_alert/presentation/bloc/panic_event.dart';
import 'package:milojos_mobile/features/panic_alert/presentation/bloc/panic_state.dart';

/// Pantalla de confirmación de alerta de pánico.
///
/// Aparece cuando [PanicBloc] emite [PanicConfirmationRequired].
/// El usuario tiene 3 segundos para confirmar.
/// Si no confirma → se regresa a [PanicIdle] (cancelación automática).
///
/// Product Agent (US-004): Ver flujo completo en Informe #4.
class PanicConfirmationPage extends StatefulWidget {
  const PanicConfirmationPage({super.key});

  @override
  State<PanicConfirmationPage> createState() => _PanicConfirmationPageState();
}

class _PanicConfirmationPageState extends State<PanicConfirmationPage>
    with TickerProviderStateMixin {
  Timer? _countdownTimer;
  int _secondsLeft = 3;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        timer.cancel();
        _cancel();
      }
    });
  }

  void _cancel() {
    if (!mounted) return;
    context.read<PanicBloc>().add(const CancelConfirmation());
  }

  Future<void> _confirm() async {
    _countdownTimer?.cancel();
    if (!mounted) return;

    // TODO Sprint 1: obtener GPS real + foto frontal silenciosa
    // Por ahora usamos coordenadas de Popayán como placeholder
    context.read<PanicBloc>().add(const ConfirmAlert(
          latitude: 2.4448,
          longitude: -76.6147,
          photoBase64: null, // Implementar en Sprint 1
        ));
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PanicBloc, PanicState>(
      listener: (context, state) {
        if (state is PanicIdle) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A0A0A),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Ícono pulsante ─────────────────────────────
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) => Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.15),
                    child: child,
                  ),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withOpacity(0.2),
                      border: Border.all(color: Colors.red, width: 3),
                    ),
                    child: const Icon(
                      Icons.warning_rounded,
                      color: Colors.red,
                      size: 60,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Título ─────────────────────────────────────
                const Text(
                  '¿Estás en peligro?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Se notificará a vecinos y autoridades\ncercanas a tu ubicación.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // ── Botón principal SÍ ─────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: Colors.red.withOpacity(0.5),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emergency, size: 28),
                        SizedBox(width: 12),
                        Text(
                          'SÍ, ESTOY EN PELIGRO',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Botón Cancelar con countdown ──────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _cancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white60,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Cancelar  ($_secondsLeft s)',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Barra de progreso countdown ───────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _secondsLeft / 3,
                    backgroundColor: Colors.white12,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.red),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
