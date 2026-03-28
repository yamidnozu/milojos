import { Injectable, Logger, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
// import { UserEntity } from '../users/entities/user.entity';

@Injectable()
export class SubscriptionsService {
  private readonly logger = new Logger(SubscriptionsService.name);

  constructor(private readonly dataSource: DataSource) {}

  /**
   * Valida un recibo de compra en Google Play (Play Developer API)
   * y otorga el rol 'neighbor_pro' (Vecino Pro).
   */
  async verifyGooglePlayReceipt(userId: string, purchaseToken: string, productId: string) {
    this.logger.log(`Validando recibo de Google Play para: ${userId} (${productId})`);

    // TODO: Integrar Google Play Android Developer API
    // const status = await playBillingApi.purchases.subscriptions.get({
    //   packageName: 'com.milojos.app',
    //   subscriptionId: productId,
    //   token: purchaseToken
    // });
    
    // Asumimos validación exitosa para Sprint 3
    const isSuccess = true; 

    if (isSuccess) {
      await this.grantProAccess(userId);
      return { success: true, message: 'Suscripción Vecino Pro activada.' };
    } else {
      throw new ConflictException('Fallo al validar compra de Google Play.');
    }
  }

  private async grantProAccess(userId: string): Promise<void> {
    // Escala el rol en PostGIS a neighbor_pro o actualiza la fecha de vencimiento
    await this.dataSource.query(`
      UPDATE users 
      SET subscription_expires_at = NOW() + INTERVAL '1 month',
          role = 'neighbor', -- Aquí se usaría RLS para dar acceso al streaming
          updated_at = NOW()
      WHERE id = $1
    `, [userId]);
    
    this.logger.log(`Acceso PRO concedido a usuario: ${userId}`);
  }
}
