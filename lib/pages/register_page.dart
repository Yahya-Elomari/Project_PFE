import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:help_desk/components/my_button.dart';
import 'package:help_desk/components/my_textfield.dart';
import 'package:help_desk/helper/helper_functions.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //register method
  void registerUser() async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    // make sure passwords match
    if (passwordController.text != confirmController.text) {
      Navigator.pop(context);
      // error message pop up
      displayMessageToUser("Passwords don't match !", context);
    }
    //if the passwords match
    else {
      // create the user
      try {
        // ignore: unused_local_variable
        UserCredential? userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);

        //create a user document and add to fire store
        createUserDocument(userCredential);

        //pop loading screen
        if (context.mounted) Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        displayMessageToUser(e.code, context);
      }
    }
  }

  // create user document and collect them in firestore
  Future<void> createUserDocument(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'email': userCredential.user!.email,
        'username': usernameController.text,
        'role': 'user',
      });
    }
  }

  final TextEditingController usernameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmController = TextEditingController();

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
                const Text('I N S C R I P T I O N',
                    style: TextStyle(fontSize: 20)),

                const SizedBox(height: 50),

                //username field
                MyTextField(
                    hinttext: "Nom d'utilisateur",
                    obscureText: false,
                    controller: usernameController),

                const SizedBox(height: 10),

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

                //confirm field
                MyTextField(
                    hinttext: "Confirmez le mot de passe",
                    obscureText: true,
                    controller: confirmController),

                const SizedBox(height: 10),

                const SizedBox(height: 25),

                //login button
                MyButton(text: "S’inscrire", onTap: registerUser),

                const SizedBox(height: 25),

                //déjà un compte
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Avez vous déjà un compte? ",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary),
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Connectez-vous ici",
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
