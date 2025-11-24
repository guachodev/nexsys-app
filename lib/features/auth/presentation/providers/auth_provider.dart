import 'dart:convert';

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
      logout(errorMessage: e.message, clearUserData: true);
    }
  }

  void checkAuthStatus() async {
    final token = await preferencesStorageService.getValue<String>('token');

    final userJsonString = await preferencesStorageService.getValue<String>(
      'user',
    );
    User? user;
    if (userJsonString != null) {
      final Map<String, dynamic> userMap = jsonDecode(userJsonString);
      user = User.fromJson(userMap);
    }

    final hasInternet = await ConnectivityService.hasConnection();

    if (!hasInternet && user != null) {
      // Usuario existente y offline
      state = state.copyWith(
        authStatus: AuthStatus.authenticated,
        offline: true,
        user: user,
        errorMessage: '',
      );
      return;
    }

    // Si hay internet → validar token con backend
    try {
      final onlineUser = await authRepository.checkAuthStatus(token!);
      _setLoggedUser(onlineUser, false);
    } catch (e) {
      if (user != null) {
        // Modo offline fallback
        state = state.copyWith(
          authStatus: AuthStatus.authenticated,
          offline: true,
          user: user,
        );
      } else {
        logout();
      }
    }
  }

  void _setLoggedUser(User? user, bool offline) async {
    if (user != null) {
      await preferencesStorageService.setKeyValue('token', user.token);
      await preferencesStorageService.setKeyValue<bool>('offline', offline);
      await preferencesStorageService.setKeyValue(
        'user',
        jsonEncode(user.toJson()),
      );
    }

    state = state.copyWith(
      user: user,
      authStatus: AuthStatus.authenticated,
      errorMessage: '',
      offline: offline,
    );
  }

  Future<void> logout({
    String? errorMessage,
    bool clearUserData = false,
  }) async {
    await preferencesStorageService.removeKey('token');
    await preferencesStorageService.removeKey('offline');

    if (clearUserData) {
      await preferencesStorageService.removeKey('user');
    }

    state = state.copyWith(
      authStatus: AuthStatus.notAuthenticated,
      user: clearUserData ? null : state.user,
      offline: false,
      errorMessage: errorMessage ?? '',
    );
  }
}

class AuthState {
  final AuthStatus authStatus;
  final User? user;
  final String errorMessage;
  final bool offline;
  final bool isLoading;

  AuthState({
    this.authStatus = AuthStatus.checking,
    this.user,
    this.errorMessage = '',
    this.offline = false,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? authStatus,
    User? user,
    String? errorMessage,
    bool? offline,
    bool? isLoading,
  }) => AuthState(
    authStatus: authStatus ?? this.authStatus,
    user: user ?? this.user,
    errorMessage: errorMessage ?? this.errorMessage,
    offline: offline ?? this.offline,
    isLoading: isLoading ?? this.isLoading,
  );
}
