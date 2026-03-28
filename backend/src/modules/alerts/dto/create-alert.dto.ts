import { IsString, IsNumber, IsNotEmpty, Min, Max, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateAlertDto {
  @ApiProperty({ description: 'ID del usuario que activa la alerta' })
  @IsString()
  @IsNotEmpty()
  userId: string;

  @ApiProperty({ description: 'Latitud GPS', example: 2.4448 })
  @IsNumber()
  @Min(-90)
  @Max(90)
  latitude: number;

  @ApiProperty({ description: 'Longitud GPS', example: -76.6147 })
  @IsNumber()
  @Min(-180)
  @Max(180)
  longitude: number;

  @ApiProperty({ description: 'Foto frontal en base64 (dato sensible - Compliance)', required: false })
  @IsString()
  @IsOptional()
  photoBase64?: string;

  @ApiProperty({ description: 'Timestamp Unix UTC del momento del shake' })
  @IsNumber()
  @IsNotEmpty()
  timestamp: number;
}
