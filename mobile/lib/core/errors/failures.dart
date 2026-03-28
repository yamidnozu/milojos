import 'package:equatable/equatable.dart';

/// Clase base para todos los fallos de la capa de dominio.
/// Se usa con Either<Failure, T> (dartz).
///
/// Compliance: Los failures relacionados con datos sensibles
/// deben ser genéricos (no revelar detalles internos al cliente).
abstract class Failure extends Equatable {
  const Failure([this.message = '']);
  final String message;

  @override
  List<Object?> get props => [message];
}

// ── Fallos de Red ────────────────────────────────────────────
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a internet']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'La conexión tardó demasiado']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error en el servidor']);
}

// ── Fallos de Autenticación ──────────────────────────────────
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'No autorizado']);
}

class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure([super.message = 'Sesión expirada']);
}

// ── Fallos de Alertas de Pánico ──────────────────────────────

/// Se lanza cuando el usuario ha reportado 3 falsas alarmas en 1 hora.
/// El usuario queda bloqueado temporalmente por 30 minutos.
class TooManyAlertsFailure extends Failure {
  const TooManyAlertsFailure(
      [super.message =
          'Función pausada temporalmente. Llama al 123 en emergencias.']);
}

class AlertNotFoundFailure extends Failure {
  const AlertNotFoundFailure([super.message = 'Alerta no encontrada']);
}

class AlertCancellationExpiredFailure extends Failure {
  const AlertCancellationExpiredFailure(
      [super.message =
          'La ventana de cancelación expiró (30 segundos). Marca "Estoy bien" en su lugar.']);
}

// ── Fallos de Cámaras ────────────────────────────────────────
class CameraNotFoundFailure extends Failure {
  const CameraNotFoundFailure([super.message = 'Cámara no encontrada']);
}

class CameraAccessDeniedFailure extends Failure {
  const CameraAccessDeniedFailure(
      [super.message = 'Sin acceso a esta cámara en este momento']);
}

// ── Fallos de Suscripción ────────────────────────────────────
class SubscriptionRequiredFailure extends Failure {
  const SubscriptionRequiredFailure(
      [super.message = 'Esta función requiere una suscripción activa']);
}

class PaymentFailure extends Failure {
  const PaymentFailure([super.message = 'Error al procesar el pago']);
}

// ── Fallos de Permisos ───────────────────────────────────────
class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure([super.message = 'Permiso denegado']);
}

class LocationPermissionFailure extends Failure {
  const LocationPermissionFailure(
      [super.message = 'Se necesita acceso a la ubicación para continuar']);
}

class CameraPermissionFailure extends Failure {
  const CameraPermissionFailure(
      [super.message = 'Se necesita acceso a la cámara para continuar']);
}

// ── Fallos de Caché ──────────────────────────────────────────
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error al leer datos locales']);
}

// ── Fallos de Validación ─────────────────────────────────────
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Datos inválidos']);
}

// ── Fallos de Consentimiento (Compliance) ────────────────────

/// Se lanza cuando se intenta operar con datos de un menor
/// cuyo padre no ha firmado el consentimiento.
class ConsentRequiredFailure extends Failure {
  const ConsentRequiredFailure(
      [super.message =
          'Se requiere el consentimiento del representante legal']);
}
