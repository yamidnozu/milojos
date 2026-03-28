import 'package:equatable/equatable.dart';
import 'package:milojos_mobile/features/panic_alert/domain/entities/alert_entity.dart';

/// Estados del PanicBloc.
/// Sigue la máquina de estados definida por el QA Agent (Informe #3).
abstract class PanicState extends Equatable {
  const PanicState();

  @override
  List<Object?> get props => [];
}

/// Estado normal — app funcionando, esperando shake.
class PanicIdle extends PanicState {
  const PanicIdle();
}

/// Shake detectado — mostrando pantalla de confirmación (countdown 3s).
class PanicConfirmationRequired extends PanicState {
  const PanicConfirmationRequired({
    required this.detectedAt,
    this.countdownSeconds = 3,
  });

  final DateTime detectedAt;
  final int countdownSeconds;

  @override
  List<Object?> get props => [detectedAt, countdownSeconds];
}

/// Usuario confirmó — enviando alerta al backend vía WebSocket.
class PanicSending extends PanicState {
  const PanicSending();
}

/// Alerta enviada exitosamente.
class PanicAlertSent extends PanicState {
  const PanicAlertSent({
    required this.alert,
    required this.respondersCount,
  });

  final AlertEntity alert;
  final int respondersCount;

  @override
  List<Object?> get props => [alert, respondersCount];
}

/// Error al enviar la alerta.
class PanicAlertError extends PanicState {
  const PanicAlertError({
    required this.message,
    this.isOffline = false,
  });

  final String message;
  final bool isOffline;

  @override
  List<Object?> get props => [message, isOffline];
}

/// Usuario bloqueado temporalmente por 3 falsas alarmas en 1 hora.
class PanicTemporarilyBlocked extends PanicState {
  const PanicTemporarilyBlocked({required this.unblockedAt});

  final DateTime unblockedAt;

  /// Minutos restantes del bloqueo.
  int get minutesRemaining =>
      unblockedAt.difference(DateTime.now()).inMinutes.clamp(0, 30);

  @override
  List<Object?> get props => [unblockedAt];
}
