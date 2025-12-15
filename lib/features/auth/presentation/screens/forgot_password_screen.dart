import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexsys_app/core/theme/theme.dart';

import '../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final emailCtrl = TextEditingController();

  ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),

              SizedBox(height: 40),

              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.pink.shade50,
                  child: Icon(Icons.lock_reset, size: 40, color: AppColors.primary),
                ),
              ),

              SizedBox(height: 30),
              Text(
                "¿Has olvidado tu contraseña?",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "¡No te preocupes! Introduce la dirección asociada. Te enviaremos instrucciones para restablecerla.",
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),

              SizedBox(height: 30),
              CustomTextField(label: "Email", controller: emailCtrl),

              SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.push('/verify'),
                  style: ElevatedButton.styleFrom(
                    //backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text("Enviar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
