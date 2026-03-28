import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { UseGuards, Logger } from '@nestjs/common';
import { Server, Socket } from 'socket.io';
import { AlertsService } from './alerts.service';
import { CreateAlertDto } from './dto/create-alert.dto';

/**
 * WebSocket Gateway para alertas de pánico en tiempo real.
 * 
 * TARGET SLA: Alerta entregada < 3 segundos end-to-end bajo 4G normal.
 * 
 * Compliance: Todos los payloads con ubicación son tratados como datos sensibles.
 * El log de acceso se registra en PostgreSQL (inmutable).
 */
@WebSocketGateway({
  namespace: '/alerts',
  cors: {
    origin: '*', // Restringir en producción
  },
})
export class AlertsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(AlertsGateway.name);

  constructor(private readonly alertsService: AlertsService) {}

  handleConnection(client: Socket): void {
    this.logger.log(`Cliente conectado: ${client.id}`);
  }

  handleDisconnect(client: Socket): void {
    this.logger.log(`Cliente desconectado: ${client.id}`);
  }

  /**
   * Evento: panic_trigger
   * Recibe: { userId, latitude, longitude, photoBase64, timestamp }
   * Emite: 'panic_confirmed' al cliente + FCM push a vecinos/policía/admin
   * 
   * Compliance: photoBase64 se envía a S3 con URL firmada (90 días).
   * La ubicación exacta NUNCA se comparte con vecinos, solo la zona aproximada.
   */
  @SubscribeMessage('panic_trigger')
  async handlePanicTrigger(
    @ConnectedSocket() client: Socket,
    @MessageBody() dto: CreateAlertDto,
  ): Promise<void> {
    try {
      this.logger.warn(`🚨 Alerta de pánico recibida de userId: ${dto.userId}`);

      // 1. Guardar alerta en PostgreSQL
      const alert = await this.alertsService.createAlert(dto);

      // 2. Obtener vecinos en radio vía PostGIS
      const neighbors = await this.alertsService.getNeighborsInRadius(
        dto.latitude,
        dto.longitude,
        500, // metros
      );

      // 3. Enviar FCM push a vecinos, policía y admin de institución
      await this.alertsService.notifyResponders(alert, neighbors);

      // 4. Confirmar al cliente
      client.emit('panic_confirmed', {
        alertId: alert.id,
        status: 'active',
        respondersNotified: neighbors.length,
        timestamp: new Date().toISOString(),
      });

      this.logger.log(
        `✅ Alerta ${alert.id} enviada a ${neighbors.length} respondedores`,
      );
    } catch (error) {
      this.logger.error(`❌ Error en panic_trigger: ${error.message}`);
      client.emit('panic_error', {
        message: 'Error al procesar la alerta. Llama al 123 directamente.',
        fallbackNumber: '123',
      });
    }
  }

  /**
   * Evento: cancel_alert
   * Cancela una alerta activa (disponible hasta 30s después de activar)
   */
  @SubscribeMessage('cancel_alert')
  async handleCancelAlert(
    @ConnectedSocket() client: Socket,
    @MessageBody() payload: { alertId: string; userId: string },
  ): Promise<void> {
    const result = await this.alertsService.cancelAlert(
      payload.alertId,
      payload.userId,
    );

    client.emit('alert_cancelled', { success: result });
  }

  /**
   * Evento: false_alarm
   * Marca una alerta como falsa alarma
   */
  @SubscribeMessage('false_alarm')
  async handleFalseAlarm(
    @ConnectedSocket() client: Socket,
    @MessageBody() payload: { alertId: string; userId: string },
  ): Promise<void> {
    await this.alertsService.markFalseAlarm(payload.alertId, payload.userId);
    client.emit('false_alarm_registered', { alertId: payload.alertId });
  }
}
