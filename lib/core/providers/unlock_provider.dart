/* import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexsys_app/core/services/services.dart';
import 'package:nexsys_app/core/session/session.dart';


final unlockProvider = Provider((ref) {
  Future<bool> unlockWithBiometrics() async {
    final success = await secureAuthService.authenticateBiometric();
    if (success) {
      ref.read(sessionNotifierProvider.notifier).unlock();
    }
    return success;
  }

  Future<bool> unlockWithPin(String pin) async {
    final valid = await secureAuthService.validatePin(pin);
    if (valid) {
      ref.read(sessionNotifierProvider.notifier).unlock();
    }
    return valid;
  }

  return {
    'unlockWithBiometrics': unlockWithBiometrics,
    'unlockWithPin': unlockWithPin,
  };
});
 */