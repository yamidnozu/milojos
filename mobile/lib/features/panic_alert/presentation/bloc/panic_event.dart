import 'package:equatable/equatable.dart';

/// Eventos del PanicBloc.
abstract class PanicEvent extends Equatable {
  const PanicEvent();
}

/// El acelerómetro detectó un gesto shake válido.
/// Filtrado previamente por KalmanFilter + ThresholdFilter.
class ShakeDetected extends PanicEvent {
  const ShakeDetected();

  @override
  List<Object?> get props => [];
}

/// El usuario presionó "SÍ, ESTOY EN PELIGRO".
class ConfirmAlert extends PanicEvent {
  const ConfirmAlert({
    required this.latitude,
    required this.longitude,
    this.photoBase64,
  });

  final double latitude;
  final double longitude;

  /// Foto frontal capturada silenciosamente — dato sensible (Compliance).
  final String? photoBase64;

  @override
  List<Object?> get props => [latitude, longitude];
}

/// El usuario canceló o expiró el countdown de 3 segundos.
class CancelConfirmation extends PanicEvent {
  const CancelConfirmation();

  @override
  List<Object?> get props => [];
}

/// El usuario presionó "Estoy bien / Falsa alarma".
class ReportFalseAlarm extends PanicEvent {
  const ReportFalseAlarm({required this.alertId});

  final String alertId;

  @override
  List<Object?> get props => [alertId];
}

/// Cancelar alerta activa (dentro de los primeros 30 segundos).
class CancelActiveAlert extends PanicEvent {
  const CancelActiveAlert({required this.alertId});

  final String alertId;

  @override
  List<Object?> get props => [alertId];
}
