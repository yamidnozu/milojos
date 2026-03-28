import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:milojos_mobile/core/constants/env.dart';
import 'package:milojos_mobile/core/errors/failures.dart';
import 'package:milojos_mobile/features/panic_alert/domain/entities/alert_entity.dart';
import 'package:milojos_mobile/features/panic_alert/domain/repositories/alert_repository.dart';
import 'package:milojos_mobile/features/panic_alert/domain/usecases/trigger_panic_alert_usecase.dart';

/// Implementación real del repositorio usando [socket.io-client]
/// para conectar con NestJS AlertsGateway y [dio] para peticiones REST de respaldo.
///
/// Architect Agent (ADR-004): 
/// Los pánicos se envían vía WebSocket para latencia < 3s real.
class AlertRepositoryImpl implements AlertRepository {
  AlertRepositoryImpl({required this.authProvider}) {
    _initSocket();
  }

  /// Proveedor de auth simulado para Sprint 1 (obtendría token JWT Supabase)
  final dynamic authProvider; 
  late IO.Socket _socket;

  final _activeAlertsController = StreamController<AlertEntity>.broadcast();

  void _initSocket() {
    // TODO: En un AuthState dinámico, el token JWT vendría del state actual
    final jwtToken = 'DUMMY_SUPABASE_TOKEN'; // authProvider.getToken();

    _socket = IO.io(
      '${Env.backendUrl}/alerts', 
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setAuth({'token': jwtToken})
        .enableAutoConnect()
        .build(),
    );

    _socket.onConnect((_) {
      print('✅ WS /alerts Conectado (${_socket.id})');
    });

    _socket.onConnectError((err) => print('❌ WS /alerts Error: $err'));
  }

  @override
  Future<Either<Failure, AlertEntity>> triggerAlert({
    required TriggerPanicAlertParams params,
  }) async {
    final completer = Completer<Either<Failure, AlertEntity>>();

    if (!_socket.connected) {
      _socket.connect();
    }

    // timeout protector de 5 segundos
    Timer(const Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        completer.complete(const Left(TimeoutFailure('Socket responde lento')));
      }
    });

    // Escuchar respuesta única de NestJS
    _socket.once('panic_confirmed', (data) {
      if (completer.isCompleted) return;

      final Map<String, dynamic> response = Map<String, dynamic>.from(data);
      final alertId = response['alertId'] as String;
      final respondersNotified = response['respondersNotified'] as int;
      final statusStr = response['status'] as String;

      final entity = AlertEntity(
        id: alertId,
        userId: params.userId,
        latitude: params.latitude,
        longitude: params.longitude,
        status: statusStr == 'active' ? AlertStatus.active : AlertStatus.resolved,
        triggeredAt: DateTime.parse(response['timestamp'] as String),
        respondersCount: respondersNotified,
        photoUrl: null, // S3 upload resuelto asincronamente
      );

      completer.complete(Right(entity));
    });

    _socket.once('panic_error', (error) {
      if (completer.isCompleted) return;
      
      final msg = error['message'] ?? 'Error desconocido';
      completer.complete(Left(ServerFailure(msg.toString())));
    });

    // Enviar DTO hacia NestJS (CreateAlertDto)
    _socket.emit('panic_trigger', {
      'userId': params.userId,
      'latitude': params.latitude,
      'longitude': params.longitude,
      'timestamp': params.timestamp,
      // La base64 de photoBase64 iría acá o mediante REST dependiendo del tamaño Mbytes
    });

    return completer.future;
  }

  @override
  Future<Either<Failure, bool>> cancelAlert({
    required String alertId,
    required String userId,
  }) async {
    // TODO: Implementar lógica "cancel_alert"
    return const Right(true);
  }

  @override
  Future<Either<Failure, void>> markFalseAlarm({
    required String alertId,
    required String userId,
  }) async {
    // TODO: Implementar lógica "false_alarm"
    return const Right(null);
  }

  @override
  Stream<AlertEntity> watchActiveAlerts() {
    return _activeAlertsController.stream;
  }

  void dispose() {
    _socket.dispose();
    _activeAlertsController.close();
  }
}
