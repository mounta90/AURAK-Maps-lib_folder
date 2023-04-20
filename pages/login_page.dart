import 'package:flutter/material.dart';
import 'package:maps/constants/colors.dart';
import 'package:maps/constants/routes.dart';
import 'package:maps/services/auth/auth_exceptions.dart';
import 'package:maps/services/auth/firebase_auth_service.dart';
import 'package:maps/components/show_error_dialog.dart';
import 'dart:developer' as devtools show log;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Login Page Title Container
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.1,
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'AURAK MAPS LOGIN',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // AURAK Login Form Container.
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5.0,
                      blurStyle: BlurStyle.outer,
                    )
                  ],
                  gradient: LinearGradient(
                    colors: [
                      primaryRedColor,
                      primaryYellowColor,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // AURAK Logo
                      const Image(
                        image: AssetImage('lib/assets/images/aurak_logo.png'),
                        height: 100,
                        width: 100,
                      ),
                      // Email text field:
                      TextField(
                        keyboardType: TextInputType.emailAddress,
                        controller: _email,
                        cursorColor: primaryRedColor,
                        enableSuggestions: false,
                        autocorrect: false,
                        style: const TextStyle(fontFamily: 'MavenPro'),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          hintText: "AURAK E-MAIL",
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      // Password text field:
                      TextField(
                        controller: _password,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        cursorColor: primaryRedColor,
                        style: const TextStyle(fontFamily: 'MavenPro'),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          hintText: "AURAK PASSWORD",
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      // Log In text button:
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: TextButton.icon(
                          onPressed: () async {
                            final email = _email.text;
                            final password = _password.text;
                            try {
                              await FirebaseAuthService().logIn(
                                email: email,
                                password: password,
                              );
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                homeRoute,
                                (route) => false,
                              );
                            } on UserNotFoundAuthException {
                              await showErrorDialog(
                                context,
                                'USER NOT FOUND',
                              );
                            } on WrongPasswordAuthException {
                              await showErrorDialog(
                                context,
                                'WRONG PASSWORD',
                              );
                            } on GenericAuthException {
                              await showErrorDialog(
                                context,
                                "AUTHENTICATION ERROR",
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                              side: const BorderSide(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          icon: const Icon(
                            Icons.login,
                            color: primaryRedColor,
                          ),
                          label: const Text(
                            "LOGIN WITH AURAK",
                            style: TextStyle(
                              color: primaryRedColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Guest Login Button Container
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.1,
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await FirebaseAuthService().logInAnonymously();
                      devtools.log(FirebaseAuthService().user!.uid.toString());
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        homeRoute,
                        (route) => false,
                      );
                    } on OperationNotAllowedAuthException {
                      await showErrorDialog(
                        context,
                        'ANONYMOUS LOGIN NOT ALLOWED',
                      );
                    } on GenericAuthException {
                      await showErrorDialog(
                        context,
                        'AUTHENTICATION ERROR',
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(
                    Icons.person_outline,
                    color: primaryYellowColor,
                  ),
                  label: const Text(
                    "LOGIN AS AURAK GUEST",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'MavenPro'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
