import { Controller, Get, Param, UseGuards } from '@nestjs/common';
import { DashboardService } from './dashboard.service';
import { SupabaseGuard } from '../../core/guards/supabase.guard';

@Controller('v1/dashboard')
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  @Get('institutions/:id/metrics')
  @UseGuards(SupabaseGuard) // Require JWT, ideally should check if user is admin of this institution
  async getInstitutionMetrics(@Param('id') institutionId: string) {
    return this.dashboardService.getInstitutionMetrics(institutionId);
  }

  @Get('police/map')
  @UseGuards(SupabaseGuard) // En prod: role === 'police' | 'superadmin'
  async getPoliceMapData() {
    return this.dashboardService.getPoliceMapAlerts();
  }
}
