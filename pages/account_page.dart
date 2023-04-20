import 'package:flutter/material.dart';
import 'package:maps/constants/colors.dart';
import 'package:maps/constants/routes.dart';
import 'package:maps/services/auth/firebase_auth_service.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width - 32,
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
              // Logout Button
              ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuthService().logOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (route) => false,
                  );
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
                  Icons.logout,
                  color: primaryRedColor,
                ),
                label: const Text(
                  "LOGOUT",
                  style: TextStyle(
                    color: primaryRedColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
