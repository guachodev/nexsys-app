import 'package:flutter_riverpod/legacy.dart';
import 'package:formz/formz.dart';
import 'package:nexsys_app/shared/inputs/inputs.dart';

import 'auth_provider.dart';

final loginFormProvider =
    StateNotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>((ref) {
      final loginUserCallback = ref.watch(authProvider.notifier).login;
      return LoginFormNotifier(loginUserCallback: loginUserCallback);
    });

class LoginFormNotifier extends StateNotifier<LoginFormState> {
  final Function(String, String) loginUserCallback;

  LoginFormNotifier({required this.loginUserCallback})
    : super(LoginFormState());

  void onUsernameChange(String value) {
    final newUsername = Username.dirty(value);
    state = state.copyWith(
      username: newUsername,
      isValid: Formz.validate([newUsername, state.password]),
    );
  }

  void onPasswordChanged(String value) {
    final newPassword = Password.dirty(value);
    state = state.copyWith(
      password: newPassword,
      isValid: Formz.validate([newPassword, state.username]),
    );
  }

  void onObscureText() {
    state = state.copyWith(isObscureText: !state.isObscureText);
  }

  
  Future<void> onFormSubmit() async {
    _touchEveryField();

    if (!state.isValid) return;
    state = state.copyWith(isPosting: true);

    await loginUserCallback(
      state.username.value,
      state.password.value
    );

    state = state.copyWith(isPosting: false);
  }

  void _touchEveryField() {
    final username = Username.dirty(state.username.value);
    final password = Password.dirty(state.password.value);
    state = state.copyWith(
      isFormPosted: true,
      username: username,
      password: password,
      isValid: Formz.validate([username, password]),
    );
  }
}

class LoginFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final bool isObscureText;
  final Username username;
  final Password password;

  LoginFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.isObscureText = true,
    this.username = const Username.pure(),
    this.password = const Password.pure(),
  });

  LoginFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    bool? isObscureText,
    Username? username,
    Password? password,
  }) => LoginFormState(
    isPosting: isPosting ?? this.isPosting,
    isFormPosted: isFormPosted ?? this.isFormPosted,
    isValid: isValid ?? this.isValid,
    isObscureText: isObscureText ?? this.isObscureText,
    username: username ?? this.username,
    password: password ?? this.password,
  );

  @override
  String toString() {
    return '''
    LoginFormState:
      isPosting: $isPosting
      isFormPosted: $isFormPosted
      isValid: $isValid
      email: $username
      password: $password
''';
  }
}
