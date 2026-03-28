import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:milojos_mobile/features/panic_alert/presentation/bloc/panic_bloc.dart';
import 'package:milojos_mobile/features/panic_alert/presentation/bloc/panic_event.dart';

/// Parámetros de detección del gesto shake.
/// Calibrables desde el Panel Super Admin.
const double _kShakeThreshold = 24.5; // equivale a ~2.5g
const int _kShakeMinDurationMs = 500;
const int _kShakeDebounceMs = 1500;

/// Widget que escucha el acelerómetro en background y emite
/// [ShakeDetected] al [PanicBloc] cuando se detecta el gesto.
///
/// Filtros activos:
/// 1. Umbral de magnitud (2.5g)
/// 2. Duración mínima (500ms)
/// 3. Debounce (no re-disparar en 1.5s)
///
/// Se coloca como wrapper en la pantalla principal.
/// Ejemplo:
/// ```dart
/// ShakeDetectorWidget(child: HomeScreen())
/// ```
class ShakeDetectorWidget extends StatefulWidget {
  const ShakeDetectorWidget({super.key, required this.child});

  final Widget child;

  @override
  State<ShakeDetectorWidget> createState() => _ShakeDetectorWidgetState();
}

class _ShakeDetectorWidgetState extends State<ShakeDetectorWidget> {
  late final Stream<AccelerometerEvent> _accelerometerStream;

  int _shakeStartMs = 0;
  bool _shaking = false;
  int _lastEmittedMs = 0;

  @override
  void initState() {
    super.initState();
    _accelerometerStream = accelerometerEventStream();
  }

  double _getMagnitude(AccelerometerEvent event) {
    return sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    final magnitude = _getMagnitude(event) - 9.8; // quitar gravedad
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    if (magnitude.abs() >= _kShakeThreshold) {
      if (!_shaking) {
        _shaking = true;
        _shakeStartMs = nowMs;
      } else {
        final duration = nowMs - _shakeStartMs;
        final debounceOk = nowMs - _lastEmittedMs > _kShakeDebounceMs;

        if (duration >= _kShakeMinDurationMs && debounceOk) {
          _lastEmittedMs = nowMs;
          _shaking = false;
          _emitShake();
        }
      }
    } else {
      _shaking = false;
    }
  }

  void _emitShake() {
    if (!mounted) return;
    context.read<PanicBloc>().add(const ShakeDetected());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AccelerometerEvent>(
      stream: _accelerometerStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _onAccelerometerEvent(snapshot.data!);
        }
        return widget.child;
      },
    );
  }
}
