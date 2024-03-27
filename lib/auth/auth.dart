import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:help_desk/auth/login_or_register.dart';
import 'package:help_desk/database/firestore.dart';
import 'package:help_desk/pages/technician_page.dart';
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
            // The user is already logged in
            User? currentUser = snapshot.data;
            if (currentUser != null) {
              // Check the user's role
              return FutureBuilder<bool>(
                future: FirestoreDatabase().isTech(),
                builder: (context, techSnapshot) {
                  if (techSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (techSnapshot.hasData) {
                    // Redirect to TechnicienPage if the user role is tech
                    if (techSnapshot.data!) {
                      return TechnicienPage();
                    } else {
                      // Redirect to TicketsListPage for other roles
                      return TicketsListPage(currentUser: currentUser);
                    }
                  }
                  // Error or user role not determined yet
                  return const Center(
                      child: Text('Error determining user role'));
                },
              );
            }
          }
          // User is not logged in
          return const LoginOrRegister();
        },
      ),
    );
  }
}
