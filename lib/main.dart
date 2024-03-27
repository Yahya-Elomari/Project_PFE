import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:help_desk/auth/auth.dart';
import 'package:help_desk/auth/login_or_register.dart';
import 'package:help_desk/pages/technician_page.dart';
import 'package:help_desk/pages/tickets_list_page.dart';
import 'firebase_options.dart';
import 'package:help_desk/theme/dark_mode.dart';
import 'package:help_desk/theme/light_mode.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
      theme: lightMode,
      darkTheme: darkMode,
      routes: {
        '/login_register_page': (context) => const LoginOrRegister(),
        '/tickets_list_page': (context) =>
            TicketsListPage(currentUser: FirebaseAuth.instance.currentUser)
      },
    );
  }
}
