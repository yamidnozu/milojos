import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';

// Usaremos Active-Record y QueryBuilder para modificar la ubicación (PostGIS)
// TODO Sprint 1: Integrar `UserEntity` en TypeORM (Por ahora usamos DataSource puro para PostGIS)

@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);

  constructor(private readonly dataSource: DataSource) {}

  /**
   * Actualiza la ubicación (vivienda) de un Vecino.
   * Utiliza Funciones PostGIS para guardar un GEOMETRY(POINT).
   */
  async updateNeighborLocation(userId: string, latitude: number, longitude: number): Promise<void> {
    try {
      this.logger.log(`Actualizando ubicación de casa para Vecino ${userId} a [${latitude}, ${longitude}]`);
      
      const query = `
        UPDATE users 
        SET home_location = ST_SetSRID(ST_MakePoint($1, $2), 4326),
            updated_at = NOW()
        WHERE id = $3 AND role = 'neighbor'
      `;
      
      const result = await this.dataSource.query(query, [longitude, latitude, userId]);
      
      if (result[1] === 0) {
        throw new NotFoundException('Usuario vecino no encontrado');
      }
      
    } catch (error) {
      this.logger.error(`Error procesando Geometría PostGIS en users: ${error.message}`);
      throw error;
    }
  }
}
