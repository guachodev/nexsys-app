import 'package:flutter/material.dart';
import 'package:nexsys_app/helpers/styles/colorsRes.dart';
import 'package:nexsys_app/widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  bool isOnline = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // CABECERA: botón Ayuda a la derecha
              Row(
                children: [
                  const Expanded(
                    child: SizedBox(),
                  ), // ocupa espacio a la izquierda
                ],
              ),

              //const SizedBox(height: 8),
              const SizedBox(height: 40),

              // Logo y nombre institución
              Column(
                children: [
                  Image.asset(
                    "assets/logo.png", // coloca tu logo en assets
                    height: 100,
                  ),
                  const SizedBox(height: 8),
                ],
              ),

              const SizedBox(height: 30),

              // Título login
              const Text(
                "Inicia sesión",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const Text(
                "Accede a tu cuenta para continuar",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),

              const SizedBox(height: 30),

              // Usuario
              TextField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  hintText: "Usuario",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  hintText: "Contraseña",
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: const Icon(Icons.visibility),
                  border: OutlineInputBorder(
                    //borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botones Online / Offline
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isOnline = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isOnline ? Colors.blue : Colors.grey,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wifi,
                                color: isOnline ? Colors.white : Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "ONLINE",
                                style: TextStyle(
                                  // color: isOnline ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isOnline = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: !isOnline ? Colors.blue : Colors.grey[200],
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_off,
                                color: !isOnline ? Colors.white : Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "OFFLINE",
                                style: TextStyle(
                                  //color: !isOnline ? Colors.white : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Botón ingresar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "INGRESAR",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Footer con versión
              const Text(
                "Nexsys App Ver. 3.0.1",
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginWidgetState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: get,
      backgroundColor: Colors.white,
      body: AuthBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 250),

              CardContainer(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'Inicia sesión',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),

                    Text('Accede a tu cuenta para continuar'),

                    SizedBox(height: 30),
                    _LoginForm(),
                  ],
                ),
              ),

              SizedBox(height: 50),
              Text('Nexsys App Ver. 3.0.1'),
              SizedBox(height: 10),
              TextButton(
                //onPressed: () =>
                //  Navigator.pushReplacementNamed(context, 'register'),
                style: ButtonStyle(
                  /* overlayColor: WidgetStateProperty.all(
                    Colors.indigo.withOpacity(0.1),
                  ), */
                  shape: WidgetStateProperty.all(StadiumBorder()),
                ),
                onPressed: () {},
                child: Text(
                  'Crear una nueva cuenta',
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //final loginForm = Provider.of<LoginFormProvider>(context);
    final formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          TextFormField(
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              //hintText: 'john.doe@gmail.com',
              labelText: 'Usuario',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.verified_user_sharp),
            ),
            //onChanged: ( value ) => loginForm.email = value,
            validator: (value) {
              return (value != null)
                  ? null
                  : 'El valor ingresado no luce como un usuario';
            },
          ),

          SizedBox(height: 10),

          TextFormField(
            autocorrect: false,
            obscureText: true,
            keyboardType: TextInputType.emailAddress,
            strutStyle: StrutStyle(height: -1),
            decoration: InputDecoration(
              hintText: '*****',
              labelText: 'Contraseña',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            //onChanged: ( value ) => loginForm.password = value,
            validator: (value) {
              return (value != null && value.length >= 6)
                  ? null
                  : 'La contraseña debe de ser de 6 caracteres';
            },
          ),
          SizedBox(height: 10),
          SegmentedButton(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: true,
                label: Text('Online'),
                icon: Icon(Icons.wifi),
              ),
              ButtonSegment(
                value: false,
                label: Text('offline'),
                icon: Icon(Icons.upload, color: ColorsRes.cardColorDark),
              ),
            ],
            selected: {true},
          ),

          SizedBox(height: 10),

          MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            //disabledColor: Colors.grey,
            elevation: 0,
            //minWidth:,
            color: ColorsRes.appColor.shade500,
            onPressed: () {},
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
              child: Text('Ingresar', style: TextStyle(color: Colors.white)),
            ),
            /* child: Container(
              padding: EdgeInsets.symmetric( horizontal: 80, vertical: 15),
              child: Text(
                loginForm.isLoading 
                  ? 'Espere'
                  : 'Ingresar',
                style: TextStyle( color: Colors.white ),
              )
            ), */
            /* onPressed: loginForm.isLoading ? null : () async {
              
              FocusScope.of(context).unfocus();
              final authService = Provider.of<AuthService>(context, listen: false);
              
              if( !loginForm.isValidForm() ) return;
    
              loginForm.isLoading = true;
    
    
              // TODO: validar si el login es correcto
              final String? errorMessage = await authService.login(loginForm.email, loginForm.password);
    
              if ( errorMessage == null ) {
                Navigator.pushReplacementNamed(context, 'home');
              } else {
                // TODO: mostrar error en pantalla
                // print( errorMessage );
                NotificationsService.showSnackbar(errorMessage);
                loginForm.isLoading = false;
              }
            } */
          ),
        ],
      ),
    );
  }
}
