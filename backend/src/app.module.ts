import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './modules/auth/auth.module';
import { AlertsModule } from './modules/alerts/alerts.module';
import { CamerasModule } from './modules/cameras/cameras.module';
import { UsersModule } from './modules/users/users.module';
import { SubscriptionsModule } from './modules/subscriptions/subscriptions.module';
import { NotificationsModule } from './modules/notifications/notifications.module';

@Module({
  imports: [
    // Configuración de variables de entorno
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),

    // Base de datos PostgreSQL + PostGIS
    TypeOrmModule.forRoot({
      type: 'postgres',
      url: process.env.DATABASE_URL,
      autoLoadEntities: true,
      synchronize: process.env.NODE_ENV === 'development', // NUNCA en producción
      logging: process.env.NODE_ENV === 'development',
    }),

    // Módulos de la aplicación
    AuthModule,
    AlertsModule,
    CamerasModule,
    UsersModule,
    SubscriptionsModule,
    NotificationsModule,
  ],
})
export class AppModule {}
