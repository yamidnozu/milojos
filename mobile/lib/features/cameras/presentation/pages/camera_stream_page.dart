import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
// En la app real usaríamos el repositorio para pedir los transports (MediSoup client wrapper).
// import 'package:milojos_mobile/features/cameras/data/repositories/cameras_repository_impl.dart';

/// Sprint 2 (US-007): Pantalla UI WebRTC para transmisión en vivo 
/// desde cámaras IP hacia la App bajo latencia ultra-baja (Mediasoup).
class CameraStreamPage extends StatefulWidget {
  final String cameraId;
  const CameraStreamPage({super.key, required this.cameraId});

  @override
  State<CameraStreamPage> createState() => _CameraStreamPageState();
}

class _CameraStreamPageState extends State<CameraStreamPage> {
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _remoteRenderer.initialize();
    _connectToMediasoup();
  }

  Future<void> _connectToMediasoup() async {
    setState(() => _isLoading = true);

    try {
      // 1. Obtener "Device Transport" desde NestJS (simulado)
      // transportData = await camerasRepo.getConsumerTransport(cameraId: widget.cameraId);

      // 2. Aquí integraríamos un plugin de Mediasoup (mediasoup_client_flutter)
      // Device device = Device();
      // await device.load(routerRtpCapabilities: transportData.routerCapabilities);
      // final recvTransport = device.createRecvTransport(...);
      // Consumer consumer = await recvTransport.consume(...);

      // 3. Empalmar MediaStream con RTCVideoRenderer
      // _remoteRenderer.srcObject = consumer.stream;

      // Mock delay loading para Sprint 2:
      await Future<void>.delayed(const Duration(seconds: 3));
      
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error de red RTCP/UDP: $e');
    }
  }

  @override
  void dispose() {
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Cámara Vecinal en Vivo', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.red),
                  SizedBox(height: 16),
                  Text('Conectando por túnel WebRTC UDP...', style: TextStyle(color: Colors.white70)),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                   RTCVideoView(
                    _remoteRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                  // Overlay informativo mock 
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                      child: const Row(
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 12),
                          SizedBox(width: 8),
                          Text('LIVE (VP8)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
