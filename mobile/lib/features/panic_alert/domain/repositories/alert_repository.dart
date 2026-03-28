import 'package:dartz/dartz.dart';
import 'package:milojos_mobile/core/errors/failures.dart';
import 'package:milojos_mobile/features/panic_alert/domain/entities/alert_entity.dart';
import 'package:milojos_mobile/features/panic_alert/domain/usecases/trigger_panic_alert_usecase.dart';

/// Contrato del repositorio de alertas — capa de Domain.
///
/// Esta interfaz abstracta define QUÉ se puede hacer con alertas.
/// La implementación concreta (en data/) puede usar HTTP, WebSocket, etc.
///
/// Architect Agent (ADR-004): El repositorio usa WebSocket para disparar
/// la alerta y REST para operaciones secundarias.
abstract class AlertRepository {
  /// Dispara una alerta de pánico.
  /// Retorna la alerta creada o un Failure.
  Future<Either<Failure, AlertEntity>> triggerAlert({
    required TriggerPanicAlertParams params,
  });

  /// Cancela una alerta activa (disponible hasta 30s después de activar).
  Future<Either<Failure, bool>> cancelAlert({
    required String alertId,
    required String userId,
  });

  /// Marca una alerta como falsa alarma.
  Future<Either<Failure, void>> markFalseAlarm({
    required String alertId,
    required String userId,
  });

  /// Stream de alertas activas en tiempo real (WebSocket).
  Stream<AlertEntity> watchActiveAlerts();
}
