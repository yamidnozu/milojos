import { Controller, Get, Param } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { AlertsService } from './alerts.service';

@ApiTags('alerts')
@Controller('alerts')
export class AlertsController {
  constructor(private readonly alertsService: AlertsService) {}

  @Get('health')
  @ApiOperation({ summary: 'Health check del servicio de alertas' })
  health(): { status: string } {
    return { status: 'ok' };
  }
}
