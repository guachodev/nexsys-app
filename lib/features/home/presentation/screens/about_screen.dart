import 'package:flutter/material.dart';
import 'package:nexsys_app/shared/widgets/appbar.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutScreen> {
  String appName = "Nexsys App";
  String version = "124";
  String buildNumber = "";

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      //appName = info.appName;
      version = info.version;
      buildNumber = info.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarApp(
        title: "Acerca de la aplicación",
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),

          // Logo centrado
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Image.asset(
                  "assets/images/nexsys.png", // Cambia tu ruta
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Nombre de la app
          Center(
            child: Text(
              appName.isEmpty ? "Mi Aplicación" : appName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Versión
          Center(
            child: Text(
              "Versión $version ($buildNumber)",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Descripción de la app
          const Text(
            "Esta aplicación ha sido desarrollada para facilitar la gestión de lecturas, "
            "registro fotográfico y administración de novedades de forma rápida y eficiente.\n\n"
            "Nuestro objetivo es brindar una herramienta confiable, intuitiva y moderna "
            "para mejorar los procesos operativos.",
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 15),
          ),

          const SizedBox(height: 30),

          // Información de soporte
          const Text(
            "Soporte Técnico",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const ListTile(
            leading: Icon(Icons.email),
            title: Text("soporte@nexsys.com"),
          ),
          const ListTile(
            leading: Icon(Icons.phone),
            title: Text("+593 987 654 321"),
          ),

          const SizedBox(height: 20),

          // Botón para ver licencias Flutter
          ElevatedButton(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: appName,
              applicationVersion: "$version ($buildNumber)",
            ),
            child: const Text("Ver licencias de software"),
          ),

          const SizedBox(height: 30),

          Center(
            child: Text(
              "© ${DateTime.now().year} Nexsys App\nTodos los derechos reservados.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
