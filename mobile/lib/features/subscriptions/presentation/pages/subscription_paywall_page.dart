import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:go_router/go_router.dart';

const String _kProSubscriptionId = 'com.milojos.app.subscription.pro';

/// Pantalla Paywall del Sprint 3 (Monetización).
/// Muestra los beneficios y utiliza InAppPurchase para cobrar.
class SubscriptionPaywallPage extends StatefulWidget {
  const SubscriptionPaywallPage({super.key});

  @override
  State<SubscriptionPaywallPage> createState() => _SubscriptionPaywallPageState();
}

class _SubscriptionPaywallPageState extends State<SubscriptionPaywallPage> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initStoreInfo();
    
    // Escuchar el Google Play Billing Client
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // Manejar error de conexión nativo
    });
  }

  Future<void> _initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _isLoading = false;
      });
      return;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      final ProductDetailsResponse productDetailResponse = 
          await _inAppPurchase.queryProductDetails({_kProSubscriptionId});
          
      setState(() {
        _isAvailable = true;
        _products = productDetailResponse.productDetails;
        _isLoading = false;
      });
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Mostramos UI cargando pago
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          _verifyWithNestJs(purchaseDetails);
        }
        
        // Finalizar transacción en Google Play In-App
        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> _verifyWithNestJs(PurchaseDetails purchaseDetails) async {
    // LLamada a backend: POST /v1/subscriptions/verify
    // String token = purchaseDetails.verificationData.serverVerificationData;
    
    // Simulación de validación exitosa:
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Compra verificada! Ahora eres Vecino Pro.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green)
    );
    context.go('/home'); // Volver al inicio como PRO
  }

  void _buyProPlan() {
    if (_products.isEmpty) return;
    
    // Lanzar el Flow de Android Google Play Billing
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: _products.first);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('MilOjos PRO', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.amber.shade400, Colors.orange.shade600]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))]
              ),
              child: const Column(
                children: [
                  Icon(Icons.star_rounded, size: 64, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Mejora la Seguridad Radial',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildFeatureRow(Icons.videocam_rounded, 'Visualiza todas las Cámaras IP a tu alrededor durante emergencias en tiempo real.'),
            const SizedBox(height: 16),
            _buildFeatureRow(Icons.history_rounded, 'Revisa el historial de incidentes hasta por 30 días.'),
            const SizedBox(height: 16),
            _buildFeatureRow(Icons.family_restroom_rounded, 'Añade 3 cuentas familiares más protegidas bajo tu radio.'),
            
            const Spacer(),
            
            // Botón de Pago In-App (US$5/mes)
            if (!_isAvailable)
              const Text('Google Play / App Store no disponible en este dispositivo.', style: TextStyle(color: Colors.red)),
              
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isAvailable ? _buyProPlan : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  _products.isNotEmpty ? 'Suscribirse por ${_products.first.price}/mes' : 'Suscribirse por USD 5.00/mes',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(child: Text('Cancela en cualquier momento. Cobro cifrado por Google Play.', style: TextStyle(fontSize: 12, color: Colors.black54))),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.orange.shade700, size: 28),
        const SizedBox(width: 16),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16, height: 1.4))),
      ],
    );
  }
}
