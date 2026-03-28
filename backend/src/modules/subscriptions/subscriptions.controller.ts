import { Controller, Post, Body, UseGuards, Req } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { SubscriptionsService } from './subscriptions.service';

@Controller('v1/subscriptions')
@UseGuards(JwtAuthGuard)
export class SubscriptionsController {
  constructor(private readonly subService: SubscriptionsService) {}

  @Post('verify')
  async verifySubscription(
    @Req() req: any,
    @Body('purchaseToken') token: string,
    @Body('productId') productId: string
  ) {
    const userId = req.user.userId;
    // Llama al servicio que verifica directamente con la API de Google
    return this.subService.verifyGooglePlayReceipt(userId, token, productId);
  }
}
