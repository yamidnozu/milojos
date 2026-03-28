import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milojos_mobile/core/errors/failures.dart';
import 'package:milojos_mobile/features/panic_alert/domain/usecases/trigger_panic_alert_usecase.dart';
import 'package:milojos_mobile/features/panic_alert/presentation/bloc/panic_event.dart';
import 'package:milojos_mobile/features/panic_alert/presentation/bloc/panic_state.dart';

/// BLoC principal del sistema de alertas de pánico.
///
/// Flujo completo:
/// Shake → [ShakeDetected] → PanicConfirmationRequired
/// 3s sin acción / [CancelConfirmation] → PanicIdle
/// [ConfirmAlert] → PanicSending → PanicAlertSent | PanicAlertError
/// [ReportFalseAlarm] → PanicIdle (+ contador de falsas alarmas)
///
/// QA Agent (Informe #3): Los tests de este BLoC están en:
/// test/unit/presentation/blocs/panic_bloc_test.dart
///
/// Architect Agent (ADR-001): Este BLoC usa TriggerPanicAlertUseCase
/// inyectado como dependencia. NUNCA instancia repositorios directamente.
class PanicBloc extends Bloc<PanicEvent, PanicState> {
  PanicBloc({
    required TriggerPanicAlertUseCase triggerPanicAlert,
  })  : _triggerPanicAlert = triggerPanicAlert,
        super(const PanicIdle()) {
    on<ShakeDetected>(_onShakeDetected);
    on<ConfirmAlert>(_onConfirmAlert);
    on<CancelConfirmation>(_onCancelConfirmation);
    on<ReportFalseAlarm>(_onReportFalseAlarm);
    on<CancelActiveAlert>(_onCancelActiveAlert);
  }

  final TriggerPanicAlertUseCase _triggerPanicAlert;

  void _onShakeDetected(ShakeDetected event, Emitter<PanicState> emit) {
    if (state is PanicTemporarilyBlocked) return; // bloqueado → ignorar shake
    if (state is PanicSending) return; // ya enviando → ignorar

    emit(PanicConfirmationRequired(detectedAt: DateTime.now()));
  }

  Future<void> _onConfirmAlert(
    ConfirmAlert event,
    Emitter<PanicState> emit,
  ) async {
    emit(const PanicSending());

    // TODO Sprint 1: obtener userId del AuthBloc/Supabase
    const userId = 'current-user-id'; // placeholder

    final result = await _triggerPanicAlert(
      TriggerPanicAlertParams(
        userId: userId,
        latitude: event.latitude,
        longitude: event.longitude,
        photoBase64: event.photoBase64,
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      ),
    );

    result.fold(
      (failure) {
        if (failure is TooManyAlertsFailure) {
          emit(PanicTemporarilyBlocked(
            unblockedAt: DateTime.now().add(const Duration(minutes: 30)),
          ));
        } else {
          emit(PanicAlertError(
            message: failure.message,
            isOffline: failure is NetworkFailure,
          ));
        }
      },
      (alert) => emit(PanicAlertSent(
        alert: alert,
        respondersCount: alert.respondersCount,
      )),
    );
  }

  void _onCancelConfirmation(
    CancelConfirmation event,
    Emitter<PanicState> emit,
  ) {
    emit(const PanicIdle());
  }

  Future<void> _onReportFalseAlarm(
    ReportFalseAlarm event,
    Emitter<PanicState> emit,
  ) async {
    // TODO Sprint 1: llamar a repository.markFalseAlarm()
    // y verificar si el usuario debe ser bloqueado temporalmente
    emit(const PanicIdle());
  }

  Future<void> _onCancelActiveAlert(
    CancelActiveAlert event,
    Emitter<PanicState> emit,
  ) async {
    // TODO Sprint 1: llamar a repository.cancelAlert()
    emit(const PanicIdle());
  }
}
