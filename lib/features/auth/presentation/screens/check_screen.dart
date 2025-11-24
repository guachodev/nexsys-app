import 'package:flutter/material.dart';
import 'package:nexsys_app/core/constants/constants.dart';
import 'package:nexsys_app/core/theme/theme.dart';

class CheckScreen extends StatelessWidget {
  const CheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              /* SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Círculo exterior giratorio
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        backgroundColor: AppColors.primary.shade100,
                      ),
                    ),

                    // Icono de agua en el centro
                    SizedBox(
                      width: 80,
                      height: 80,
                      /* decoration: BoxDecoration(
                        color: Color(0xFF1A237E).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ), */
                      child: Image.asset('assets/images/nexsys.png', width: 80),
                    ),
                  ],
                ),
              ),
               */SizedBox(
                width: double.infinity,
                height: double.infinity,
                /* decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF292929), Color(0xFF090909)],
                    stops: [0, 1],
                    begin: AlignmentDirectional(1, -1),
                    end: AlignmentDirectional(-1, 1),
                  ),
                ), */
              ),
              Align(
                alignment: AlignmentDirectional(0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 8,
                        ),
                      ),
                      child: Align(
                        alignment: AlignmentDirectional(0, 0),
                        child: Image.asset(
                          'assets/images/nexsys_dark.png',
                          width: 80,
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional(0, 0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 4),
                        child: Text(
                          Environment.appName,
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'Cargando datos...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),

                    Align(
                      alignment: AlignmentDirectional(0, 0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 0.5,
                          height: 10,
                          decoration: BoxDecoration(shape: BoxShape.rectangle),
                          child: Align(
                            alignment: AlignmentDirectional(0, 0),
                            child: LinearProgressIndicator(
                              minHeight: 6,
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
