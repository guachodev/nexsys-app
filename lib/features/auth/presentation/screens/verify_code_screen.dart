import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VerifyCodeScreen extends StatelessWidget {
  const VerifyCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  child: Icon(Icons.email_outlined,
                      size: 40, color: Colors.pink),
                ),
              ),

              SizedBox(height: 30),
              Text("Check your email",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                "We sent a 4 digit code to tim.jennings@example.com",
                style: TextStyle(color: Colors.grey),
              ),

              SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  4,
                  (i) => Container(
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "*",
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.push('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text("Verify"),
                ),
              ),

              SizedBox(height: 16),
              Center(
                child: Text(
                  "Didn't receive the email?  Resend(13)",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
