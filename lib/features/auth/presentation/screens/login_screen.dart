import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/core/utils/utils.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

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

    ref.listen(authProvider, (previous, next) async {
      if (next.errorMessage.isEmpty) return;
      Notifications.error(context, next.errorMessage);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (_, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 140),
                      Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 100,
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        "Bienvenido",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Por favor, introduzca sus datos.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        onChanged: ref
                            .read(loginFormProvider.notifier)
                            .onUsernameChange,
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
                        onChanged: ref
                            .read(loginFormProvider.notifier)
                            .onPasswordChanged,
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
                            onPressed: () => ref
                                .read(loginFormProvider.notifier)
                                .onObscureText(),
                          ),
                          errorText: loginForm.isFormPosted
                              ? loginForm.password.errorMessage
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () => ref
                              .read(loginFormProvider.notifier)
                              .onFormSubmit(),
                          style: ElevatedButton.styleFrom(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Iniciar sesión",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),

                      /*const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              "https://upload.wikimedia.org/wikipedia/commons/0/09/IOS_Google_icon.png",
                              height: 22,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Continuar con Google",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
*/
                      const SizedBox(height: 25),
                      /* TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        style: TextButton.styleFrom(
                          //foregroundColor: Colors.black,
                        ),
                        child: const Text(
                          "¿Has olvidado tu contraseña?",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ), */

                      const Spacer(),

                      /// FOOTER
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.copyright,
                                size: 12,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
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
                          const SizedBox(height: 4),
                          Text(
                            'Versión ${Environment.version}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
