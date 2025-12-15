import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/core/theme/theme.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentRoute = ModalRoute.of(context)?.settings.name;

    final List<MenuItem> preferenceItems = [
      MenuItem(
        icon: Icons.info_outline,
        title: "Acerca de",
        link: '/about',
        isPush: true,
      ),
    ];

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _Header(
            authState.user?.fullName ?? 'Invitado',
            authState.user?.email ?? 'demo@nexsys.com',
          ),
          // OPCIONES DE MENÚ PRINCIPAL
          Expanded(
            child: ListView(
              padding: EdgeInsetsGeometry.zero,
              children: [
                _buildSectionDivider("Opciones"),
                ...appMenuItems.map((item) => _MenuItem(item, currentRoute)),

                _buildSectionDivider("Preferencias"),

                ...preferenceItems.map((item) => _MenuItem(item, currentRoute)),

                // 🔥 NUEVA SECCIÓN: Cuenta
                _buildSectionDivider("Cuenta"),
                _LogoutButton(),
              ],
            ),
          ),
          //_LogoutButton(),
        ],
      ),
    );
  }

  Widget _buildSectionDivider(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}

class _LogoutButton extends ConsumerWidget {
  const _LogoutButton();
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _mostrarDialogoLogout(context, ref),
            splashColor: Colors.red.withValues(alpha: .1),
            highlightColor: Colors.red.withValues(alpha: .05),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                //color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // Ícono moderno dentro de un Chip
                  Icon(Icons.logout_rounded, size: 25, color: Colors.red),

                  const SizedBox(width: 14),

                  // Texto principal
                  Text(
                    "Cerrar sesión",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final MenuItem item;
  final String? currentRoute;
  const _MenuItem(this.item, this.currentRoute);

  @override
  Widget build(BuildContext context) {
    bool isSelected = (currentRoute ?? '/') == item.link;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected ? AppColors.primary.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            if (item.link.isNotEmpty) {
              if (item.isPush!) {
                context.push(item.link);
                return;
              }
              context.pushReplacement(item.link);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Icono con indicador de selección
                Icon(
                  item.icon,
                  size: 30,
                  color: isSelected
                      ? AppColors.primary.shade500
                      : Colors.black54,
                ),
                const SizedBox(width: 12),
                // Título
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w900
                          : FontWeight.normal,
                      color: isSelected
                          ? AppColors.primary.shade500
                          : Colors.grey.shade900,
                    ),
                  ),
                ),
                if (item.trailing != null) item.trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String name;
  final String? email;
  const _Header(this.name, this.email);

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double kDrawerHeaderHeight = 120.0 + 1.0;

    return Container(
      height: statusBarHeight + kDrawerHeaderHeight,
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        border: Border(bottom: Divider.createBorderSide(context)),
      ),
      child: AnimatedContainer(
        padding: EdgeInsets.fromLTRB(
          16.0,
          16.0,
          16.0,
          8.0,
        ).add(EdgeInsets.only(top: statusBarHeight)),
        decoration: BoxDecoration(color: AppColors.primary),
        curve: Curves.fastOutSlowIn,
        duration: Duration(milliseconds: 250),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Nombre y correo ocupan todo el ancho
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  //const SizedBox(height: 6),
                  Text(
                    email ?? 'Sin email',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Avatar sobresaliente
            Positioned(
              bottom: -50,
              right: 15,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  /* boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ], */
                ),
                child: CircleAvatar(
                  radius: 40,
                  //backgroundColor: Colors.grey.shade300,
                  //backgroundImage: _getImageProvider(avatarPathOrUrl),
                  backgroundImage: AssetImage('assets/images/av-1.png'),
                  //child: Icon(Icons.person, size: 36, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
