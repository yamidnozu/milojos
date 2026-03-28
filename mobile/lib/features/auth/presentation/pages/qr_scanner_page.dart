import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:milojos_mobile/features/auth/presentation/bloc/auth_bloc.dart';
// import 'package:milojos_mobile/features/auth/presentation/bloc/auth_event.dart';

/// Sprint 1 (US-001): Escáner de Carnet QR para Estudiantes.
/// Utiliza `mobile_scanner` para leer el código cifrado del plantel.
class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      final String code = barcodes.first.rawValue!;
      
      setState(() {
        _isProcessing = true;
      });

      // Detener cámara al detectar
      await cameraController.stop();

      // MOCK validación del Edge Function (Supabase)
      await _validateQrCode(code);
    }
  }

  Future<void> _validateQrCode(String code) async {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Validando QR: $code...')));
    
    // Simular latencia de red contra Supabase Edge Function
    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Aquí llamaríamos al AuthBloc para ejecutar el Sign In
    // context.read<AuthBloc>().add(QrSignInRequested(qrToken: code));

    // Mock asumiendo éxito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Autenticación de Estudiante Exitosa'),
        backgroundColor: Colors.green,
      ),
    );

    // Navegar al Dashboard / Home de Estudiantes (Sprint 1)
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Carnet Estudiantil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            color: Colors.grey,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          
          // UI Lector Framework
          Positioned.fill(
            child: Container(
              decoration: ShapeDecoration(
                shape: QrScannerOverlayShape(
                  borderColor: Colors.red.shade600,
                  borderRadius: 16,
                  borderLength: 40,
                  borderWidth: 10,
                  cutOutSize: 280,
                ),
              ),
            ),
          ),
          
          if (_isProcessing)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Validando identidad en Base de Datos...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            
          if (!_isProcessing)
            const Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Centra el código QR del carnet escolar aquí',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Utility Class para dibujar el cuadrado oscuro semitransparente con un hueco
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10.0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(
        rect.right,
        rect.bottom,
      )
      ..lineTo(
        rect.left,
        rect.bottom,
      )
      ..lineTo(
        rect.left,
        rect.top,
      );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final _borderLength = borderLength > cutOutSize / 2 + borderWidthSize ? borderWidthSize / 2 : borderLength;
    final _cutOutSize = cutOutSize;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - _cutOutSize / 2 + borderOffset,
      rect.top + height / 2 - _cutOutSize / 2 + borderOffset,
      _cutOutSize - borderOffset * 2,
      _cutOutSize - borderOffset * 2,
    );

    canvas
      ..saveLayer(rect, backgroundPaint)
      ..drawRect(rect, backgroundPaint)
      ..drawRRect(
        RRect.fromRectAndCorners(
          cutOutRect,
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
        boxPaint,
      )
      ..restore();

    canvas
      ..drawRRect(
        RRect.fromRectAndCorners(
          cutOutRect,
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
        borderPaint,
      );
  }

  @override
  ShapeBorder scale(double t) => QrScannerOverlayShape(
        borderColor: borderColor,
        borderWidth: borderWidth,
        overlayColor: overlayColor,
      );
}
