import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nexsys_app/core/utils/utils.dart';

import '../providers/search_lectura_qr_provider.dart';

class QrScannerSheet extends ConsumerStatefulWidget {
  const QrScannerSheet({super.key});

  @override
  ConsumerState<QrScannerSheet> createState() => _QrScannerSheetState();
}

class _QrScannerSheetState extends ConsumerState<QrScannerSheet>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isProcessing = false;
  bool _flashOn = false;
  late AnimationController _laserController;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _audioPlayer.setSourceAsset('sounds/beep.mp3');
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    _laserController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcode = capture.barcodes.first;
    if (barcode.rawValue == null) return;

    _isProcessing = true;
    await _controller.stop();
    await _audioPlayer.resume();
    HapticFeedback.lightImpact();

    final code = barcode.rawValue!;
    await ref.read(searchLecturaQrProvider.notifier).searchByQr(code);
    final state = ref.read(searchLecturaQrProvider);

    if (!mounted) return;

    if (state.status == SearchLecturaQrStatus.success) {
      Navigator.pop(context);
      Notifications.success(context, 'Medidor encontrado: ${state.lectura!.id}');
       context.push('/lecturas/detalle', extra: state.lectura);
    } else if (state.status == SearchLecturaQrStatus.error) {
      Notifications.error(context, state.message);
      _isProcessing = false;
      _controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final qrState = ref.watch(searchLecturaQrProvider);
   // final scanArea = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// Cámara
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          /// Capa semitransparente con recorte del área central
          /* CustomPaint(
            painter: OverlayMaskPainter(scanArea: scanArea),
            child: Container(),
          ), */

          /// Efecto de línea láser animada
          /* Center(
            child: AnimatedBuilder(
              animation: _laserController,
              builder: (context, _) {
                final y = (scanArea - 6) * _laserController.value;
                return Transform.translate(
                  offset: Offset(0, -scanArea / 2 + y),
                  child: Container(
                    width: scanArea * 0.9,
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.indigo, Colors.blueAccent],
                      ),
                      borderRadius: BorderRadius.circular(2),
                      
                    ),
                  ),
                );
              },
            ),
          ), */

          /// Borde del escáner
         /*  Center(
            child: CustomPaint(
              size: Size(scanArea, scanArea),
              painter: FuturisticBorderPainter(),
            ),
          ), */

          /// Barra superior personalizada (sin AppBar)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón volver
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Escáner QR",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Botón linterna
                  IconButton(
                    icon: Icon(
                      _flashOn ? Icons.flash_on : Icons.flash_off,
                      color: _flashOn ? Colors.yellowAccent : Colors.white,
                    ),
                    onPressed: () {
                      setState(() => _flashOn = !_flashOn);
                      _controller.toggleTorch();
                    },
                  ),
                ],
              ),
            ),
          ),

          /// Panel inferior de ayuda (Glassmorphism)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    padding: const EdgeInsets.all(16),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Enfoca el código de barras",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Mantén el dispositivo firme y asegúrate de que el código esté dentro del recuadro.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// Loader
          if (qrState.status == SearchLecturaQrStatus.loading)
            Container(
              color: Colors.black.withValues(alpha: .7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.indigoAccent),
                    SizedBox(height: 16),
                    Text(
                      'Cargando datos del medidor...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 🎨 Dibuja el área transparente central sin ColorFiltered
class OverlayMaskPainter extends CustomPainter {
  final double scanArea;
  OverlayMaskPainter({required this.scanArea});

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.indigo.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(
      (size.width - scanArea) / 2,
      (size.height - scanArea) / 2,
      scanArea,
      scanArea,
    );

    final path = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()..addRRect(RRect.fromRectXY(rect, 24, 24)),
    );

    canvas.drawPath(path, overlayPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 🎨 Bordes tipo futurista
class FuturisticBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0);

    const corner = 30.0;
    final path = Path()
      ..moveTo(0, corner)
      ..lineTo(0, 0)
      ..lineTo(corner, 0)
      ..moveTo(size.width - corner, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, corner)
      ..moveTo(size.width, size.height - corner)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - corner, size.height)
      ..moveTo(corner, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height - corner);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
