import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/core/errors/errors.dart';
import 'package:nexsys_app/core/services/services.dart';
import 'package:nexsys_app/features/auth/data/data.dart';
import 'package:nexsys_app/features/auth/domain/domain.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = AuthRepositoryImpl();
  final storage = PreferencesStorageService();
  return AuthNotifier(repository: authRepository, storage: storage);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepositoryImpl repository;
  final PreferencesStorageService storage;
  AuthNotifier({required this.repository, required this.storage})
    : super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> login(String email, String password) async {
    try {
      final user = await repository.login(email, password);
      await storage.setKeyValue('token', user.token);
      await storage.setKeyValue('user', jsonEncode(user.toJson()));
      _setAuthenticated(user);
      debugPrint(user.toJsonString());
    } on CustomError catch (e) {
      state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        user: null,
        errorMessage: e.message,
      );
    }
  }

  Future<void> logout() async {
    await storage.removeKey('token');
    await storage.removeKey('offline');
    await storage.removeKey('user');
    _setNotAuthenticated();
  }

  void checkAuthStatus() async {
    final token = await storage.getValue<String>('token');
    final userJsonString = await storage.getValue<String>('user');

    User? user;
    if (userJsonString != null) {
      user = User.fromJson(jsonDecode(userJsonString));
    }

    final hasInternet = await ConnectivityService.hasConnection();

    if (!hasInternet) {
      if (user != null) {
        _setAuthenticated(user);
      } else {
        _setNotAuthenticated();
      }
      return;
    }

    if (token != null) {
      try {
        final onlineUser = await repository.checkAuthStatus(token);
        _setAuthenticated(onlineUser);
        return;
      } catch (_) {
        if (user != null) {
          _setAuthenticated(user);
          return;
        }
      }
    }

    logout();
    _setNotAuthenticated();
  }

  void _setAuthenticated(User user) {
    state = state.copyWith(
      authStatus: AuthStatus.authenticated,
      user: user,
      errorMessage: '',
    );
    // ref.read(sessionNotifierProvider).setAuthenticated(true);
  }

  void _setNotAuthenticated() {
    state = state.copyWith(authStatus: AuthStatus.notAuthenticated, user: null);
    //ref.read(sessionNotifierProvider).setAuthenticated(false);
  }
}

class AuthState {
  final AuthStatus authStatus;
  final User? user;
  final String errorMessage;
  final bool isLoading;

  AuthState({
    this.authStatus = AuthStatus.checking,
    this.user,
    this.errorMessage = '',
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? authStatus,
    User? user,
    String? errorMessage,
    bool? isLoading,
  }) => AuthState(
    authStatus: authStatus ?? this.authStatus,
    user: user ?? this.user,
    errorMessage: errorMessage ?? this.errorMessage,
    isLoading: isLoading ?? this.isLoading,
  );
}
