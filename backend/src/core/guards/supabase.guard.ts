import { Injectable, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class SupabaseGuard extends AuthGuard('jwt') {
  canActivate(context: ExecutionContext) {
    // Aquí puedes agregar lógica adicional como obtener metadatos de "roles"
    return super.canActivate(context);
  }

  handleRequest(err, user, info) {
    if (err || !user) {
      throw err || new UnauthorizedException('Token de Supabase inválido o expirado. Acceso denegado (Security Agent).');
    }
    // Retorna el payload del usuario inyectado
    return user;
  }
}
