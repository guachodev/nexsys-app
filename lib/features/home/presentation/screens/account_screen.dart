// account_screen.dart
// Diseño de pantalla Cuenta / Perfil para app empresarial

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexsys_app/core/theme/app_colors.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';
import 'package:nexsys_app/shared/widgets/appbar.dart';

class AccountScreen extends ConsumerWidget {
  final String company = 'EPAA MEJIA EP';

  const AccountScreen({super.key});

  void _mostrarDialogoLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Color.fromARGB(255, 10, 10, 10).withValues(alpha: .8),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícono redondeado elegante
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.red.shade600,
                    size: 42,
                  ),
                ),

                const SizedBox(height: 22),
                const Text(
                  "Cerrar sesión",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),
                Text(
                  "¿Estás seguro de que deseas cerrar sesión?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),

                const SizedBox(height: 28),

                // Botones modernos M3
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancelar",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          await ref.read(authProvider.notifier).logout();
                        },
                        child: const Text(
                          "Cerrar sesión",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: BarApp(title: 'Cuenta'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileHeader(
            name: authState.user?.fullName ?? 'Invitado',
            email: authState.user?.email ?? 'demo@nexsys.com',
            role: authState.user?.rol.toUpperCase() ?? 'Invitado',
            company: company,
          ),
          const SizedBox(height: 24),
          /* _ProfileCard(
            fullName: authState.user?.fullName ?? 'Invitado',
            email: authState.user?.email ?? 'demo@nexsys.com',
            role: authState.user?.rol ?? 'Invitado',
            company: company,
          ), */
          /*  const SizedBox(height: 24),
          const _SectionTitle(title: 'Preferencias'),
          const SizedBox(height: 12),
          _OptionTile(
            icon: Icons.lock_outline,
            title: 'Seguridad',
            subtitle: 'Cambiar contraseña',
            onTap: () {},
          ),
         _OptionTile(
            icon: Icons.notifications_none,
            title: 'Notificaciones',
            subtitle: 'Alertas y avisos',
            onTap: () {},
          ),
          _OptionTile(
            icon: Icons.language_outlined,
            title: 'Idioma',
            subtitle: 'Español',
            onTap: () {},
          ), */
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Sesión'),
          const SizedBox(height: 12),
          _OptionTile(
            icon: Icons.logout,
            title: 'Cerrar sesión',
            subtitle: 'Salir de la cuenta',
            color: Colors.red,
            onTap: () => _mostrarDialogoLogout(context, ref),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final String company;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.role,
    required this.company,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/av-1.png'),
              ),

              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(email, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Tag(label: role),
              const SizedBox(width: 8),
              _Tag(label: company),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.black87;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: effectiveColor),
        title: Text(title, style: TextStyle(color: effectiveColor)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
