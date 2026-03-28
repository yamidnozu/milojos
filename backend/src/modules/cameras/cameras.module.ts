import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CamerasController } from './cameras.controller';
import { CamerasService } from './cameras.service';
import { CameraEntity } from './entities/camera.entity';

@Module({
  imports: [TypeOrmModule.forFeature([CameraEntity])],
  controllers: [CamerasController],
  providers: [CamerasService],
  exports: [CamerasService],
})
export class CamerasModule {}
