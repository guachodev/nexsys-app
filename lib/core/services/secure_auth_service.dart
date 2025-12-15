/* import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class SecureAuthService {
  final _storage = const FlutterSecureStorage();
  final _auth = LocalAuthentication();

  // Guardar PIN cifrado
  Future<void> savePin(String pin) async {
    await _storage.write(key: 'user_pin', value: pin);
  }

  // Leer PIN
  Future<String?> getPin() async {
    return await _storage.read(key: 'user_pin');
  }

  Future<bool> hasPin() async {
    return await getPin() != null;
  }

  // Verificar PIN
  Future<bool> validatePin(String pin) async {
    print(hasPin());
    //final savedPin = await getPin();
    return '123456' == pin;
  }

  // Soporte de biometría
  Future<bool> canUseBiometrics() async {
    return await _auth.canCheckBiometrics;
  }

  Future<bool> authenticateBiometric() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Confirma tu identidad',
        /* options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ), */
      );
    } catch (e) {
      return false;
    }
  }
}

final secureAuthService = SecureAuthService();
 */