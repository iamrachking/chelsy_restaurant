import 'package:chelsy_restaurant/presentation/login/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends GetView<LoginController> {

  @override
  final LoginController controller = Get.put(LoginController());

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
            children: [
              // Logo & sous-titre
              LoginHeader(),
              LoginForm(),
            ],
          ),
      ),
    );
  }
}

class LoginHeader extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
          color: Color(0xFF3D2817),
          borderRadius: BorderRadius.only(
            //bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(100)
          )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            bottom: false,
            child: Center(heightFactor: 0.375,
              child: Image(image: AssetImage('assets/logo-chelsy.png')),
            ),
          ),
          //const SizedBox(height: 1),
          Center(
            child: Text(
              "Bienvenue dans votre nouvelle safe place.",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w300),
              //textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {

  bool isSignUp = true; // true = s'inscrire, false = se connecter
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(100),
          ),
        ),
        child: Column(
          children: [
            // Bouton s'inscrire / se connecter
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isSignUp = true;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSignUp ? Color(0xFF3D2817) : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Color(0xFF3D2817),
                          width: 1,
                        )
                      ),
                      child: Text(
                        'S\'inscrire',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSignUp ? Colors.white : Color(0xFF3D2817),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                ),
                SizedBox(width: 8,),

                // Bouton Se connecter
                Expanded(child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isSignUp = false;
                    });
                  },
                  child: Container(
                    padding: ed
                  ),
                ))
              ],
            )
          ],
        ),
      ),
    );
  }
}