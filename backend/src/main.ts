import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Validación global
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  // CORS
  app.enableCors({
    origin: process.env.CORS_ORIGIN || '*',
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  });

  // Prefijo global de API
  app.setGlobalPrefix('api/v1');

  // Swagger docs
  const config = new DocumentBuilder()
    .setTitle('MilOjos API')
    .setDescription('API de la Plataforma de Seguridad Colaborativa MilOjos — Popayán, Colombia')
    .setVersion('0.1.0')
    .addBearerAuth()
    .addTag('auth', 'Autenticación y autorización')
    .addTag('alerts', 'Alertas de pánico en tiempo real')
    .addTag('cameras', 'Red de cámaras IP comunitarias')
    .addTag('users', 'Gestión de usuarios y roles')
    .addTag('subscriptions', 'Suscripciones Google Play Billing')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  const port = process.env.PORT || 3000;
  await app.listen(port);
  console.log(`🛡️  MilOjos Backend running on: http://localhost:${port}/api/v1`);
  console.log(`📖  Swagger docs: http://localhost:${port}/api/docs`);
}

bootstrap();
