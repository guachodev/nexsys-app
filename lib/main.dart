import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/core/router/router.dart';

Future<void> main() async {
  await Environment.initEnvironment();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: Environment.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(backgroundColor: Colors.white,),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        //colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF1153dc)),
      ),

      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _lecturaController = TextEditingController();
  final TextEditingController _nombreClienteController =
      TextEditingController();
  File? _image;

  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _image = File(photo.path);
      });
    }
  }

  void _viewPhoto() {
    if (_image != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Image.file(_image!),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cerrar"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lectura de Agua Potable")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del cliente o referencia
              GestureDetector(
                onTap: _image != null ? _viewPhoto : _takePhoto,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: _image != null
                      ? Image.file(_image!, fit: BoxFit.cover)
                      : Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.grey[700],
                        ),
                ),
              ),
              SizedBox(height: 16),
              // Nombre del cliente
              TextFormField(
                controller: _nombreClienteController,
                decoration: InputDecoration(
                  labelText: "Nombre del Cliente",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Ingrese el nombre del cliente";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Lectura actual
              TextFormField(
                controller: _lecturaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Lectura Actual (m³)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Ingrese la lectura";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Botón guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Aquí puedes manejar el guardado de datos
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lectura guardada')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Guardar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
