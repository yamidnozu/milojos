import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class SupabaseStrategy extends PassportStrategy(Strategy) {
  constructor(private readonly configService: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>('JWT_SECRET'),
    });
  }

  async validate(payload: any) {
    // Supabase usa 'sub' para el UUID del usuario
    if (!payload.sub) {
      throw new UnauthorizedException('Token inválido de Supabase');
    }
    
    // El payload retornado se adjunta a req.user en los controladores
    return {
      userId: payload.sub,
      email: payload.email,
      role: payload.role, 
    };
  }
}
