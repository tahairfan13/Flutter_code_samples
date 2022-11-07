import 'package:connectnwork/constants.dart';
import 'package:connectnwork/repos/user_repository.dart';
import 'package:connectnwork/screens/home.dart';
import 'package:connectnwork/screens/my_profile.dart';
import 'package:connectnwork/widgets/scaffold_gradient.dart';
import 'package:flutter/material.dart';

class CheckProfileVerified extends StatefulWidget {
  const CheckProfileVerified({Key? key}) : super(key: key);

  @override
  State<CheckProfileVerified> createState() => _CheckProfileVerifiedState();
}

class _CheckProfileVerifiedState extends State<CheckProfileVerified> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldGradient(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder(
          future: UserRepository.get(),
          builder: (context, snapshot) {
            final data = snapshot.data;
            if (data != null) {
              myProfile = data;
              if (myProfile!.idVerified != null && myProfile!.idVerified! == true) {
                return const HomeScreen();
              } else {
                return const MyProfileScreen();
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
