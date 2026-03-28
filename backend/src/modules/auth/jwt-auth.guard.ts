import { Injectable, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { WsException } from '@nestjs/websockets';
import { Observable } from 'rxjs';
import { Socket } from 'socket.io';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  canActivate(context: ExecutionContext): boolean | Promise<boolean> | Observable<boolean> {
    const isWebSocket = context.getType() === 'ws';
    
    // Si es WebSocket (como el Gateway HTTP de Alertas), la validación debe darse sobre el token enviado.
    if (isWebSocket) {
      const client: Socket = context.switchToWs().getClient();
      const token = this.extractTokenFromSocket(client);
      
      if (!token) {
        throw new WsException('No autorizado');
      }
      
      // Validación real delegada a la estrategia
      client.request.headers['authorization'] = `Bearer ${token}`;
      return super.canActivate(context);
    }
    
    // Para rutas HTTP (REST)
    return super.canActivate(context);
  }

  private extractTokenFromSocket(client: Socket): string | undefined {
    // 1. Extraer desde payload si vino en auth
    const authQuery = client.handshake.auth?.token;
    if (authQuery) return authQuery;
    
    // 2. Extraer desde el header convencional
    const authHeader = client.handshake.headers['authorization'];
    if (authHeader && authHeader.startsWith('Bearer ')) {
      return authHeader.split(' ')[1];
    }
    
    return undefined;
  }
}
