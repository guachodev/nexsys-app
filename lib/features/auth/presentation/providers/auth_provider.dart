import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/core/constants/enums.dart';
import 'package:nexsys_app/core/errors/errors.dart';
import 'package:nexsys_app/core/services/services.dart';
import 'package:nexsys_app/features/auth/data/data.dart';
import 'package:nexsys_app/features/auth/domain/domain.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = AuthRepositoryImpl();
  final preferencesStorageService = PreferencesStorageService();

  return AuthNotifier(
    authRepository: authRepository,
    preferencesStorageService: preferencesStorageService,
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepositoryImpl authRepository;
  final PreferencesStorageService preferencesStorageService;

  AuthNotifier({
    required this.authRepository,
    required this.preferencesStorageService,
  }) : super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> login(String email, String password, bool offline) async {
    try {
      final user = await authRepository.login(email, password);
      _setLoggedUser(user, offline);
    } on CustomError catch (e) {
      logout(e.message);
    }
  }

  void checkAuthStatus() async {
    final token = await preferencesStorageService.getValue<String>('token');
    final offline = await preferencesStorageService.getValue<bool>('offline');

    if (token == null) return logout();

    try {
      final user = await authRepository.checkAuthStatus(token);
      _setLoggedUser(user, offline);
    } catch (e) {
      logout();
    }
  }

  void _setLoggedUser(User? user, bool? offline) async {
    if (user != null) {
      await preferencesStorageService.setKeyValue('token', user.token);
      await preferencesStorageService.setKeyValue<bool>('offline', offline!);
    }

    state = state.copyWith(
      user: user,
      authStatus: AuthStatus.authenticated,
      errorMessage: '',
      offline: offline,
    );
  }

  Future<void> logout([String? errorMessage]) async {
    await preferencesStorageService.removeKey('token');
    await preferencesStorageService.removeKey('offline');

    state = state.copyWith(
      authStatus: AuthStatus.notAuthenticated,
      user: null,
      errorMessage: errorMessage,
      offline: false,
    );
  }
}

class AuthState {
  final AuthStatus authStatus;
  final User? user;
  final String errorMessage;
  final bool? offline;

  AuthState({
    this.authStatus = AuthStatus.checking,
    this.user,
    this.errorMessage = '',
    this.offline = false,
  });

  AuthState copyWith({
    AuthStatus? authStatus,
    User? user,
    String? errorMessage,
    bool? offline,
  }) => AuthState(
    authStatus: authStatus ?? this.authStatus,
    user: user ?? this.user,
    errorMessage: errorMessage ?? this.errorMessage,
    offline: offline ?? this.offline,
  );
}
