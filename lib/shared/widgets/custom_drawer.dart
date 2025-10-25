import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexsys_app/core/constants/menu_items.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /* final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double kDrawerHeaderHeight = 120.0 + 1.0;
     */
    final authState = ref.watch(authProvider);
    final currentRoute = ModalRoute.of(context)?.settings.name;

    final List<MenuItem> preferenceItems = [
      /* MenuItem(
        icon: Icons.wifi,
        title: "Estás en modo:",
        trailing: _OnlineChip(authState.offline),
        link: '',
      ), */
      MenuItem(icon: Icons.info, title: "Acerca de", link: ''),
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
              ],
            ),
          ),
          _LogoutButton(),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: SizedBox(
              width: 36,
              height: 36,

              child: Icon(
                Icons.logout_outlined,
                size: 18,
                color: Colors.red.shade700,
              ),
            ),
            title: Text(
              "Cerrar sesión",
              style: TextStyle(
                color: Colors.red.shade800,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              size: 18,
              color: Colors.red.shade700,
            ),
            onTap: () {
              //Navigator.pop(context); // Cierra el drawer
              //_showLogoutConfirmation(context)

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: const Text("Cerrar sesión"),
                    content: const Text(
                      "¿Estás seguro de que quieres cerrar sesión?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancelar"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Cierra el dialog
                          // Aquí iría la lógica real de cierre de sesión
                          //context.pushReplacement('/login');
                          ref.read(authProvider.notifier).logout();
                        },
                        child: const Text("Cerrar sesión"),
                      ),
                    ],
                  );
                },
              );
            },
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
        color: isSelected ? Colors.indigo.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            if (item.link.isNotEmpty) {
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
                      ? Colors.indigo.shade700
                      : Colors.grey.shade700,
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
                          ? Colors.indigo.shade700
                          : Colors.grey.shade800,
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
        decoration: BoxDecoration(color: Colors.indigo),
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

class _OnlineChip extends StatelessWidget {
  final bool offline;
  const _OnlineChip(this.offline);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: offline ? Colors.deepOrange.shade500 : Colors.green.shade500,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            offline ? 'Offline' : "Online",
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
