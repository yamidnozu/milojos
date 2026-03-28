import { Injectable } from '@nestjs/common';
import { DataSource } from 'typeorm';

@Injectable()
export class DashboardService {
  constructor(private readonly dataSource: DataSource) {}

  /**
   * Obtiene las métricas en tiempo real para el Panel Administrativo de una Institución Educativa.
   * US-011 Dashboard Institucional
   */
  async getInstitutionMetrics(institutionId: string) {
    const rawData = await this.dataSource.query(
      `
      SELECT 
        (SELECT COUNT(*) FROM users WHERE institution_id = $1 AND role = 'student') as total_students,
        (SELECT COUNT(*) FROM panic_alerts WHERE status = 'active' AND user_id IN (SELECT id FROM users WHERE institution_id = $1)) as active_alerts,
        (SELECT COUNT(*) FROM cameras WHERE is_active = true AND institution_id = $1) as active_cameras
      `,
      [institutionId],
    );

    return {
      institutionId,
      metrics: {
        totalStudents: Number(rawData[0].total_students),
        activeAlerts: Number(rawData[0].active_alerts),
        activeCameras: Number(rawData[0].active_cameras),
      },
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * Obtiene las alertas georreferenciadas activas para el Puesto de Mando (PMU) de la Policía.
   * US-012 Panel de Monitoreo Policial
   */
  async getPoliceMapAlerts() {
    const alerts = await this.dataSource.query(
      `
      SELECT 
        pa.id as alert_id,
        pa.triggered_at,
        ST_Y(pa.location::geometry) as latitude,
        ST_X(pa.location::geometry) as longitude,
        u.full_name as victim_name,
        u.role as victim_role,
        u.phone as victim_phone
      FROM panic_alerts pa
      JOIN users u ON u.id = pa.user_id
      WHERE pa.status = 'active'
      ORDER BY pa.triggered_at DESC
      LIMIT 100
      `
    );

    return {
      activeCount: alerts.length,
      alerts: alerts.map((row: any) => ({
        id: row.alert_id,
        latitude: row.latitude,
        longitude: row.longitude,
        timestamp: row.triggered_at,
        victim: {
          name: row.victim_name,
          role: row.victim_role,
          phone: row.victim_phone,
        }
      }))
    };
  }
}
