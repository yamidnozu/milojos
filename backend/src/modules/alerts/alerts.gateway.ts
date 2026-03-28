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
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

/**
 * WebSocket Gateway para alertas de pánico en tiempo real.
 * Reúne la autenticación de Supabase + la lógica de PostGIS.
 */
@WebSocketGateway({
  namespace: '/alerts',
  cors: { origin: '*' }, // Restringir en prod
})
export class AlertsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(AlertsGateway.name);

  constructor(private readonly alertsService: AlertsService) {}

  handleConnection(client: Socket): void {
    // Al conectarse se pueden agregar al room general si es necesario, 
    // pero por privacidad preferimos la notificación FCM segmentada por PostGIS.
    this.logger.log(`Cliente conectado: ${client.id}`);
  }

  handleDisconnect(client: Socket): void {
    this.logger.log(`Cliente desconectado: ${client.id}`);
  }

  /**
   * Evento: panic_trigger
   * Con validación de token JWT desde Flutter (Supabase)
   */
  @UseGuards(JwtAuthGuard)
  @SubscribeMessage('panic_trigger')
  async handlePanicTrigger(
    @ConnectedSocket() client: Socket,
    @MessageBody() dto: CreateAlertDto,
  ): Promise<void> {
    try {
      this.logger.warn(`🚨 Alerta de pánico recibida de userId: ${dto.userId}`);

      // 1. Guardar alerta en PostgreSQL usando TypeORM
      const alert = await this.alertsService.createAlert(dto);

      // 2. Ejecutar la función PostGIS 'get_neighbors_in_radius' para buscar a <=500m
      const neighbors = await this.alertsService.getNeighborsInRadius(
        dto.latitude,
        dto.longitude,
        500, // metros
      );

      // 3. Enviar FCM push a los teléfonos de esos vecinos
      await this.alertsService.notifyResponders(alert, neighbors);

      // 4. Confirmar al dispositivo local que la mandó
      client.emit('panic_confirmed', {
        alertId: alert.id,
        status: 'active',
        respondersNotified: neighbors.length,
        timestamp: new Date().toISOString(),
      });

      this.logger.log(`✅ Alerta ${alert.id} procesada con ${neighbors.length} respondedores en radio de 500m.`);
    } catch (error) {
      this.logger.error(`❌ Error en panic_trigger: ${error.message}`);
      client.emit('panic_error', {
        message: 'Error al procesar la alerta. Llama al 123 directamente.',
        fallbackNumber: '123',
      });
    }
  }

  @UseGuards(JwtAuthGuard)
  @SubscribeMessage('cancel_alert')
  async handleCancelAlert(
    @ConnectedSocket() client: Socket,
    @MessageBody() payload: { alertId: string; userId: string },
  ): Promise<void> {
    const result = await this.alertsService.cancelAlert(
      payload.alertId,
      payload.userId, // Validamos que quien cancela sea el mismo que generó (desde JWT req idealmente)
    );

    client.emit('alert_cancelled', { success: result });
  }

  @UseGuards(JwtAuthGuard)
  @SubscribeMessage('false_alarm')
  async handleFalseAlarm(
    @ConnectedSocket() client: Socket,
    @MessageBody() payload: { alertId: string; userId: string },
  ): Promise<void> {
    await this.alertsService.markFalseAlarm(payload.alertId, payload.userId);
    client.emit('false_alarm_registered', { alertId: payload.alertId });
  }
}
