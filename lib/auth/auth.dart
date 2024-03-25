import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:help_desk/auth/login_or_register.dart';
import 'package:help_desk/pages/tickets_list_page.dart';

class AuthPage extends StatelessWidget {
  AuthPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              // the user is already logged in
              User? currentUser = snapshot.data;
              if (currentUser != null) {
                return TicketsListPage(currentUser: currentUser);
              }
            }
            // user is not logged in
            return const LoginOrRegister();
          }),
    );
  }
}
