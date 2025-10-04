import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Color(0xFFF3F3F3),
        body: AuthBackground(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 120),
                Image.asset('assets/images/logo-dark.png', height: 90),
                const SizedBox(height: 60),
                Container(
                  transform: Matrix4.translationValues(0, -10, 0),
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.19),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _LoginForm(),
                ),
                SizedBox(height: 10),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.copyright_rounded,
                          size: 12,
                          color: Colors.grey.shade800,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '2025 ${Environment.appName}',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    SizedBox(width: 4),
                    Text(
                      'Versión ${Environment.version}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends ConsumerWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginForm = ref.watch(loginFormProvider);
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Inicia sesión",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            Text("Accede a tu cuenta para continuar"),
          ],
        ),
        const SizedBox(height: 30),

        // Input Email
        TextFormField(
          onChanged: ref.read(loginFormProvider.notifier).onUsernameChange,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            hintText: "Email",
            labelText: "Usuario",
            prefixIcon: const Icon(Icons.person_rounded),
            prefixIconColor: Colors.grey.shade600,
            errorText: loginForm.isFormPosted
                ? loginForm.username.errorMessage
                : null,
          ),
        ),
        const SizedBox(height: 15),

        // Input Password
        TextFormField(
          obscureText: loginForm.isObscureText,
          onChanged: ref.read(loginFormProvider.notifier).onPasswordChanged,
          onFieldSubmitted: (_) =>
              ref.read(loginFormProvider.notifier).onFormSubmit(),
          decoration: InputDecoration(
            hintText: "Password",
            labelText: "Contraseña",
            prefixIcon: const Icon(Icons.lock_rounded),
            prefixIconColor: Colors.grey.shade600,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: IconButton(
              icon: Icon(
                loginForm.isObscureText
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: () =>
                  ref.read(loginFormProvider.notifier).onObscureText(),
            ),
            errorText: loginForm.isFormPosted
                ? loginForm.password.errorMessage
                : null,
          ),
        ),

        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade200,
          ),
          child: Row(
            children: [
              ModeButton(
                text: 'Online',
                icon: Icons.wifi_rounded,
                selected: !loginForm.isOffline,
                isFirst: true,
                onTap: () =>
                    ref.read(loginFormProvider.notifier).onTapOffline(),
              ),
              ModeButton(
                text: 'Offline',
                icon: Icons.wifi_off_rounded,
                selected: loginForm.isOffline,
                isFirst: false,
                onTap: () =>
                    ref.read(loginFormProvider.notifier).onTapOffline(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Botón Log In
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: loginForm.isPosting
                ? null
                : ref.read(loginFormProvider.notifier).onFormSubmit,
            child: const Text(
              "Ingresar",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                //color: AppColors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
        TextButton(
          onPressed: () {},
          child: Text(
            "¿Olvidaste tu contraseña?",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }
}
