import 'package:connectnwork/constants.dart';
import 'package:connectnwork/screens/auth_page.dart';
import 'package:connectnwork/screens/check_profile_verified.dart';
import 'package:connectnwork/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    myLocale = Localizations.localeOf(context);

    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Something went wrong!',
              ),
            );
          } else if (snapshot.hasData) {
            return const CheckProfileVerified();
          } else {
            return const AuthPage();
          }
        },
      ),
    );
  }
}
