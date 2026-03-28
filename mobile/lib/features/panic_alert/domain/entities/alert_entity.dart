import 'package:equatable/equatable.dart';

/// Entidad de Alerta de Pánico — capa de Domain (Dart puro).
///
/// Compliance (Informe #1):
/// - [photoUrl] es una URL firmada de S3 con expiración de 90 días.
/// - [latitude] y [longitude] son datos sensibles — nunca
///   mostrar la ubicación exacta a vecinos, solo zona aproximada.
/// - Esta entidad NUNCA debe tener referencias a Flutter widgets.
class AlertEntity extends Equatable {
  const AlertEntity({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.triggeredAt,
    this.photoUrl,
    this.resolvedAt,
    this.respondersCount = 0,
  });

  final String id;
  final String userId;

  /// Ubicación exacta — dato sensible (Compliance).
  /// Solo compartir zona aproximada con vecinos.
  final double latitude;
  final double longitude;

  final AlertStatus status;
  final DateTime triggeredAt;

  /// URL firmada S3 (expira en 90 días) — dato crítico (Compliance).
  final String? photoUrl;

  final DateTime? resolvedAt;
  final int respondersCount;

  bool get isActive => status == AlertStatus.active;
  bool get canBeCancelled =>
      isActive &&
      DateTime.now().difference(triggeredAt).inSeconds <= 30;

  @override
  List<Object?> get props => [
        id,
        userId,
        latitude,
        longitude,
        status,
        triggeredAt,
        photoUrl,
        resolvedAt,
        respondersCount,
      ];
}

enum AlertStatus {
  active,
  resolved,
  falseAlarm,
  cancelled;

  bool get isActive => this == AlertStatus.active;
}
