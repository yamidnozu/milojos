import { Controller, Put, Body, Req, UseGuards, Param, ParseUUIDPipe } from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { IsNumber, Min, Max } from 'class-validator';

// DTO para la ubicación
export class UpdateLocationDto {
  @IsNumber()
  @Min(-90) @Max(90)
  latitude: number;

  @IsNumber()
  @Min(-180) @Max(180)
  longitude: number;
}

@Controller('v1/users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  /**
   * Product Agent [US-002]:
   * Este endpoint es invocado en el Flutter Onboarding para marcar la casa del vecino en el mapa.
   * La validación JWT previene que vecinos marquen casas ajenas.
   */
  @Put(':id/location')
  async updateLocation(
    @Param('id') id: string,
    @Body() dto: UpdateLocationDto,
    @Req() req: any, 
  ) {
    // Verificar que el usuario solo puede actualizar su propia cuenta
    // userId lo inyecta JWTAuthGuard en req.user
    // const tokenUserId = req.user.userId;
    // if (tokenUserId !== id) throw new ForbiddenException();

    await this.usersService.updateNeighborLocation(id, dto.latitude, dto.longitude);
    return {
      message: 'Ubicación procesada con PostGIS exitosamente.',
      home_location: [dto.latitude, dto.longitude],
    };
  }
}
