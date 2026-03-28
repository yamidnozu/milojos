import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:milojos_mobile/core/errors/failures.dart';
import 'package:milojos_mobile/core/usecase/usecase.dart';
import 'package:milojos_mobile/features/panic_alert/domain/entities/alert_entity.dart';
import 'package:milojos_mobile/features/panic_alert/domain/repositories/alert_repository.dart';

/// Use Case: Disparar alerta de pánico.
///
/// TDD (QA Agent): Los tests de este UseCase están en:
/// test/unit/domain/usecases/trigger_panic_alert_usecase_test.dart
///
/// Flujo (Product Agent — US-004):
/// 1. Shake detectado → ConfirmAlert event en PanicBloc
/// 2. PanicBloc llama a este UseCase con foto + GPS
/// 3. UseCase delega al AlertRepository (WebSocket → Backend)
/// 4. Retorna AlertEntity con status 'active' o Failure
///
/// Compliance: Este UseCase maneja datos sensibles (foto + GPS).
/// Privacy Clearance requerida antes del merge. Issue: #2
class TriggerPanicAlertUseCase
    implements UseCase<AlertEntity, TriggerPanicAlertParams> {
  const TriggerPanicAlertUseCase({required this.repository});

  final AlertRepository repository;

  @override
  Future<Either<Failure, AlertEntity>> call(
      TriggerPanicAlertParams params) async {
    return repository.triggerAlert(params: params);
  }
}

/// Parámetros para [TriggerPanicAlertUseCase].
///
/// Compliance:
/// - [photoBase64]: foto frontal silenciosa, dato crítico. Solo enviar al backend,
///   nunca persistir en el dispositivo ni mostrar a otros usuarios.
/// - [latitude] y [longitude]: ubicación exacta en el momento del shake.
///   El backend la almacena cifrada y solo comparte zona aproximada con vecinos.
class TriggerPanicAlertParams extends Equatable {
  const TriggerPanicAlertParams({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.photoBase64,
  });

  final String userId;
  final double latitude;
  final double longitude;
  final int timestamp;

  /// Foto frontal en Base64 — dato sensible (Compliance Informe #1).
  /// Nullable: si la cámara falla, se puede enviar la alerta sin foto.
  final String? photoBase64;

  @override
  List<Object?> get props => [userId, latitude, longitude, timestamp];
}
