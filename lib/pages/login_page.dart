import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:help_desk/components/my_button.dart';
import 'package:help_desk/components/my_textfield.dart';
import 'package:help_desk/helper/helper_functions.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  void login() async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    //try signing in
    try {
      FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      //loading circle
      if (context.mounted) Navigator.pop(context);
    }
    // for errors
    on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessageToUser(e.code, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //logo
                Icon(Icons.person,
                    size: 90,
                    color: Theme.of(context).colorScheme.inversePrimary),

                const SizedBox(height: 25),
                const Text('A U T H E N T I F I C A T I O N',
                    style: TextStyle(fontSize: 20)),

                const SizedBox(height: 50),

                //email field
                MyTextField(
                    hinttext: "Adresse e-mail",
                    obscureText: false,
                    controller: emailController),

                const SizedBox(height: 10),

                //password field
                MyTextField(
                    hinttext: "Mot de passe",
                    obscureText: true,
                    controller: passwordController),

                const SizedBox(height: 10),

                //register button
                MyButton(text: "Se connecter", onTap: login),

                const SizedBox(height: 25),

                //register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "vous n'avez pas de compte? ",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary),
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Inscrivez-vous ici",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
