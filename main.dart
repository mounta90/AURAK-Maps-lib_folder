import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:maps/constants/routes.dart';
import 'package:maps/firebase_options.dart';
import 'package:maps/pages/intro_page.dart';
import 'package:maps/pages/login_page.dart';
import 'package:maps/pages/navigator_page.dart';
import 'package:maps/services/auth/firebase_auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// almountassirb@gmail.com
// aurakmaps

void main() async {
  await dotenv.load(fileName: "lib/assets/config/.env");
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false, //hides debug message on screen
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'MavenPro',
      ),
      home: const InitializationPage(),
      routes: {
        loginRoute: (context) => const LoginPage(),
        homeRoute: (context) => const NavigatorPage(),
      },
    ),
  );
}

class InitializationPage extends StatelessWidget {
  const InitializationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            FirebaseAuthService firebaseAuthService = FirebaseAuthService();
            User? user = firebaseAuthService.user;
            if (user != null) {
              return const NavigatorPage();
            } else {
              return const IntroPage();
            }
          default:
            return const Scaffold();
        }
      },
    );
  }
}
