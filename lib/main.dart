import 'package:flutter/material.dart';
import 'package:nexsys_app/screens/screens.dart';
import 'package:nexsys_app/utils/constant.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Constant.appName,
      initialRoute: 'login',
      routes: {'login': (_) => LoginScreen()},
      //theme: ColorsRes.lightTheme,
    );
  }
}
