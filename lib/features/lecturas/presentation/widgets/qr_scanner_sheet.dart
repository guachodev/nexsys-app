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
  bool _qrNotFound = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.setSourceAsset('sounds/beep.mp3');
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || _qrNotFound) return;

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
      Notifications.success(
        context,
        'Medidor encontrado: ${state.lectura!.id}',
      );
      context.push('/lecturas/detalle/${state.lectura?.id}');
    } else if (state.status == SearchLecturaQrStatus.error) {
      Notifications.error(context, state.message);

      setState(() {
        _qrNotFound = true; // ⬅ ACTIVAR PANEL DE ERROR
        _isProcessing = false;
      });
    }
  }

  Future<void> _retry() async {
    setState(() {
      _qrNotFound = false;
      _isProcessing = false;
    });

    await _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    final qrState = ref.watch(searchLecturaQrProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// Cámara activa (si NO hay error)
          MobileScanner(
            controller: _controller,
            onDetect: _qrNotFound ? null : _onDetect,
          ),

          /// Barra superior
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
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

                  IconButton(
                    icon: Icon(
                      _flashOn ? Icons.flash_on : Icons.flash_off,
                      color: _flashOn ? Colors.yellowAccent : Colors.white,
                    ),
                    onPressed: () {
                      if (_qrNotFound) return;
                      setState(() => _flashOn = !_flashOn);
                      _controller.toggleTorch();
                    },
                  ),
                ],
              ),
            ),
          ),

          /// Panel inferior dinámico
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    color: _qrNotFound ? Colors.grey.withValues(alpha: .2) : Colors.black.withValues(alpha: .5),
                    padding: const EdgeInsets.all(16),
                    child: _qrNotFound
                        /// ❌ Panel de error
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Medidor no encontrado",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "No se encontró un medidor con este código. Intenta nuevamente.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _retry,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 22,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text("Reintentar"),
                                ),
                              ),
                            ],
                          )
                        /// 📷 Modo normal
                        : const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Enfoca el código de barras",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Mantén el dispositivo firme y asegúrate de que el código esté dentro del recuadro.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),

          /// Loader mientras busca
          if (qrState.status == SearchLecturaQrStatus.loading)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
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
