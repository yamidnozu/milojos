import { Injectable, Logger, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AlertEntity } from './entities/alert.entity';
import { CreateAlertDto } from './dto/create-alert.dto';

@Injectable()
export class AlertsService {
  private readonly logger = new Logger(AlertsService.name);

  constructor(
    @InjectRepository(AlertEntity)
    private readonly alertRepository: Repository<AlertEntity>,
  ) {}

  async createAlert(dto: CreateAlertDto): Promise<AlertEntity> {
    const alert = this.alertRepository.create({
      userId: dto.userId,
      latitude: dto.latitude,
      longitude: dto.longitude,
      photoUrl: null, // TODO Sprint 1: upload to S3
      status: 'active',
    });
    return this.alertRepository.save(alert);
  }

  async getNeighborsInRadius(
    latitude: number,
    longitude: number,
    radiusMeters: number,
  ): Promise<Array<{ userId: string; distanceMeters: number }>> {
    // TODO Sprint 1: PostGIS query via raw SQL / get_neighbors_in_radius()
    this.logger.log(`Buscando vecinos en radio ${radiusMeters}m de [${latitude}, ${longitude}]`);
    return [];
  }

  async notifyResponders(
    alert: AlertEntity,
    neighbors: Array<{ userId: string }>,
  ): Promise<void> {
    // TODO Sprint 1: FCM push via NotificationsService
    this.logger.log(`Notificando ${neighbors.length} respondedores para alerta ${alert.id}`);
  }

  async cancelAlert(alertId: string, userId: string): Promise<boolean> {
    const alert = await this.alertRepository.findOne({ where: { id: alertId } });
    if (!alert) throw new NotFoundException('Alerta no encontrada');
    if (alert.userId !== userId) throw new ForbiddenException('No puedes cancelar esta alerta');

    const secondsSinceTrigger = (Date.now() - alert.triggeredAt.getTime()) / 1000;
    if (secondsSinceTrigger > 30) return false; // Ventana de cancelación expirada

    await this.alertRepository.update(alertId, { status: 'cancelled' });
    return true;
  }

  async markFalseAlarm(alertId: string, userId: string): Promise<void> {
    await this.alertRepository.update(alertId, { status: 'false_alarm' });
    // TODO Sprint 1: incrementar contador de falsas alarmas del usuario
  }
}
