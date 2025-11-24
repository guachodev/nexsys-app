import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexsys_app/core/theme/theme.dart';
import 'package:nexsys_app/core/utils/utils.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';

class LoginForm extends ConsumerWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginForm = ref.watch(loginFormProvider);
    ref.listen<LoginFormState>(loginFormProvider, (previous, next) {
      if (next.isPosting && (previous?.isPosting ?? false) == false) {
        Loader.openLoadingDialog(context);
      }

      if (!next.isPosting && (previous?.isPosting ?? true) == true) {
        // 👉 Se terminó el posting → cerrar loader
        Loader.stopLoading(context);
      }
    });

    ref.listen(authProvider, (previous, next) {
      if (next.errorMessage.isEmpty) return;
      Notifications.error(context, next.errorMessage);
    });

    return Container(
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
      child: Column(
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
          TextFormField(
            onChanged: ref.read(loginFormProvider.notifier).onUsernameChange,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              hintText: "test",
              labelText: "Usuario",
              prefixIcon: const Icon(Icons.person_rounded),
              prefixIconColor: Colors.grey.shade600,
              errorText: loginForm.isFormPosted
                  ? loginForm.username.errorMessage
                  : null,
            ),
          ),
          const SizedBox(height: 15),
          TextFormField(
            obscureText: loginForm.isObscureText,
            onChanged: ref.read(loginFormProvider.notifier).onPasswordChanged,
            onFieldSubmitted: (_) =>
                ref.read(loginFormProvider.notifier).onFormSubmit(),
            decoration: InputDecoration(
              hintText: "******",
              labelText: "Contraseña",
              prefixIcon: const Icon(Icons.lock_rounded),
              prefixIconColor: Colors.grey.shade600,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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

          /*
          const SizedBox(height: 15),
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
           */
          const SizedBox(height: 15),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: loginForm.isPosting
                    ? null
                    : ref.read(loginFormProvider.notifier).onFormSubmit,
                child: const Text(
                  "Ingresar",
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          /* TextButton(
            onPressed: () {},
            child: Text(
              "¿Olvidaste tu contraseña?",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {},
            child: Text("Scanear QR?", style: TextStyle(color: AppColors.primary)),
          ), */
        ],
      ),
    );
  }
}
