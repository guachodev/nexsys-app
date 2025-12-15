import 'package:flutter/material.dart';
import 'package:nexsys_app/core/theme/theme.dart';
//import 'package:lottie/lottie.dart';

class Loader {
 static void openLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: .6),
    builder: (_) {
      final theme = Theme.of(context);
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Loader animado
              SizedBox(
                height: 60,
                width: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),

              const SizedBox(height: 24),

              // Mensaje principal
              Text(
                "Iniciando sesión...",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Mensaje secundario
              Text(
                "Estamos conectando con el servidor,\nesto tomará solo unos segundos.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 20),

              // Barra de progreso opcional
              LinearProgressIndicator(
                minHeight: 4,
                color: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ],
          ),
        ),
      );
    },
  );
}

  static void openLoading(BuildContext context, String title, String detail) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Color(0xFF1C252E).withValues(alpha: .8),
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  backgroundColor: Color(0xFFEEEEEE),
                ),
              ),
              const SizedBox(height: 25),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: TextStyle(
                  fontSize: 15,
                  //color: Color.fromARGB(255, 88, 88, 88),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void openFullLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Color.fromARGB(255, 10, 10, 10).withValues(alpha: .8),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      backgroundColor: Colors.grey.shade50,
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: Image.asset(
                      'assets/images/nexsys_dark.png',
                      width: 70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Loading text
            const Text(
              'Espera un momento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void openDowloadLecturas(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Color.fromARGB(255, 10, 10, 10).withValues(alpha: .8),
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  backgroundColor: Color(0xFFEEEEEE),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "Descargando lecturas",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                "Espera un momento por favor...",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void openInfoRed(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Color.fromARGB(255, 10, 10, 10).withValues(alpha: .8),
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return Dialog(
          backgroundColor: theme.colorScheme.surface,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícono redondeado elegante
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.wifi_off,
                    color: theme.colorScheme.primary,
                    size: 42,
                  ),
                ),

                const SizedBox(height: 22),
                const Text(
                  "Sin conexión a Internet",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),

                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Aceptar", style: TextStyle(fontWeight: FontWeight.w600),),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Stop the currently open loading dialog.
  /// This method doesn't return anything.
  static void stopLoading(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}
