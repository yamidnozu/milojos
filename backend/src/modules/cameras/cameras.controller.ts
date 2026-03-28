import { Controller, Post, Body, UseGuards, Req, Request } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CamerasService } from './cameras.service';

@Controller('v1/cameras')
@UseGuards(JwtAuthGuard)
export class CamerasController {
  constructor(private readonly camerasService: CamerasService) {}

  /**
   * Un vecino (solo con suscripción activa Pro - a validarse posteriormente) 
   * envía un websocket o REST para solicitar el túnel WebRTC a una cámara cercana en pánico.
   */
  @Post(':id/transports')
  async createConsumerTransport(
    @Req() req: any,
    @Body('cameraId') cameraId: string
  ) {
    const userId = req.user.userId;
    // Esto se enlazaría con MediaSoup para generar parámetros DTLS y ICE del stream RTSP
    const transportConfig = await this.camerasService.getConsumerTransport(cameraId, userId);
    
    return {
      success: true,
      transportOptions: transportConfig
    };
  }
}
