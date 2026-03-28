import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity('panic_alerts')
export class AlertEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @Column('double precision')
  latitude: number;

  @Column('double precision')
  longitude: number;

  @Column({ name: 'photo_url', nullable: true })
  photoUrl: string | null;

  @Column({ default: 'active' })
  status: 'active' | 'resolved' | 'false_alarm' | 'cancelled';

  @CreateDateColumn({ name: 'triggered_at' })
  triggeredAt: Date;

  @Column({ name: 'resolved_at', nullable: true })
  resolvedAt: Date | null;
}
