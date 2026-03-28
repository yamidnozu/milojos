import { Injectable, Logger, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { AlertEntity } from './entities/alert.entity';
import { CreateAlertDto } from './dto/create-alert.dto';

@Injectable()
export class AlertsService {
  private readonly logger = new Logger(AlertsService.name);

  constructor(
    @InjectRepository(AlertEntity)
    private readonly alertRepository: Repository<AlertEntity>,
    private readonly dataSource: DataSource,
  ) {}

  async createAlert(dto: CreateAlertDto): Promise<AlertEntity> {
    const alert = this.alertRepository.create({
      userId: dto.userId,
      latitude: dto.latitude,
      longitude: dto.longitude,
      photoUrl: null, // TODO Sprint 1: upload to S3 here
      status: 'active',
    });
    return this.alertRepository.save(alert);
  }

  /**
   * Ejecuta la función PostGIS 'get_neighbors_in_radius' creada en init.sql
   * Retorna los usuarios vecinos activos (role='neighbor') dentro del radio, ordenados por proximidad.
   */
  async getNeighborsInRadius(
    latitude: number,
    longitude: number,
    radiusMeters: number,
  ): Promise<Array<{ user_id: string; distance_meters: number; fcm_token: string | null }>> {
    this.logger.log(`Buscando vecinos en radio ${radiusMeters}m de [${latitude}, ${longitude}]`);
    
    // Llamada SQL pura delegando el procesamiento geoespacial a PostGIS
    const query = `
      SELECT * FROM get_neighbors_in_radius(
        ST_GeographyFromText('POINT(${longitude} ${latitude})'),
        $1
      )
    `;
    
    try {
      const neighbors = await this.dataSource.query(query, [radiusMeters]);
      return neighbors;
    } catch (error) {
      this.logger.error(`Error PostGIS: ${error.message}`);
      return [];
    }
  }

  async notifyResponders(
    alert: AlertEntity,
    neighbors: Array<{ user_id: string; fcm_token: string | null }>,
  ): Promise<void> {
    const tokens = neighbors.map(n => n.fcm_token).filter(t => t);
    
    if (tokens.length === 0) {
      this.logger.warn(`No hay tokens FCM válidos para notificar la alerta ${alert.id}`);
      return;
    }

    this.logger.log(`Notificando a ${tokens.length} respondedores vía FCM para alerta ${alert.id}`);
    
    // TODO: Usar firebase-admin enviando mensaje multicast de prioridad ALTA (Canal de Emergencia)
    // El payload no debe contener coordenadas exactas, solo ID para abrir el mapa.
  }

  async cancelAlert(alertId: string, userId: string): Promise<boolean> {
    const alert = await this.alertRepository.findOne({ where: { id: alertId } });
    if (!alert) throw new NotFoundException('Alerta no encontrada');
    if (alert.userId !== userId) throw new ForbiddenException('No puedes cancelar esta alerta');

    const secondsSinceTrigger = (Date.now() - alert.triggeredAt.getTime()) / 1000;
    if (secondsSinceTrigger > 30) return false; // Ventana de cancelación de 30s expirada

    await this.alertRepository.update(alertId, { status: 'cancelled' });
    this.logger.log(`Alerta ${alertId} CANCELADA por usuario ${userId}`);
    return true;
  }

  async markFalseAlarm(alertId: string, userId: string): Promise<void> {
    const alert = await this.alertRepository.findOne({ where: { id: alertId } });
    if (!alert) throw new NotFoundException('Alerta no encontrada');

    await this.alertRepository.update(alertId, { status: 'false_alarm' });
    
    // Aplicar lógica de castigo según US-005 (3 falsas alarmas = 30 min bloqueo)
    await this.dataSource.query(`
      UPDATE users 
      SET false_alarm_count_last_hour = false_alarm_count_last_hour + 1,
          last_false_alarm_at = NOW(),
          temporarily_blocked_until = CASE 
            WHEN false_alarm_count_last_hour + 1 >= 3 THEN NOW() + INTERVAL '30 minutes'
            ELSE temporarily_blocked_until
          END
      WHERE id = $1
    `, [userId]);

    this.logger.warn(`Alerta ${alertId} marcada como FALSA ALARMA por usuario ${userId}`);
  }
}
