import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('cameras')
export class CameraEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'institution_id' })
  institutionId: string;

  @Column({ name: 'rtsp_url' })
  rtspUrl: string;

  @Column('float')
  latitude: number;

  @Column('float')
  longitude: number;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
