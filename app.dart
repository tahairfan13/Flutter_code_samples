import 'package:connectnwork/constants.dart';
import 'package:connectnwork/screens/delete_account.dart';
import 'package:connectnwork/screens/home.dart';
import 'package:connectnwork/screens/main_page.dart';
import 'package:connectnwork/screens/my_jobs.dart';
import 'package:connectnwork/screens/my_profile.dart';
import 'package:connectnwork/screens/notfications.dart';
import 'package:connectnwork/screens/notification_settings.dart';
import 'package:connectnwork/screens/payments_setup.dart';
import 'package:connectnwork/screens/reset_password.dart';
import 'package:connectnwork/screens/settings.dart';
import 'package:connectnwork/screens/support.dart';
import 'package:connectnwork/screens/weekly_earnings.dart';
import 'package:connectnwork/services/push_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'environment.dart';

Future<void> app({required String flavor}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  LocalNotificationService.initialize();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Load the JSON config into memory
  if (flavor == Environment.stag) {
    server = 'https://dev-api.connectnwork.com';
    appleSignInRedirectURI = 'https://connectnwork-stag.firebaseapp.com/__/auth/handler';
  } else if (flavor == Environment.prod) {
    server = 'https://api.connectnwork.com';
    appleSignInRedirectURI = 'https://cnw-auth.firebaseapp.com/__/auth/handler';
  }

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: messengerKey,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Connect&WORK',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/main',
      routes: {
        '/main': (context) => const MainPage(),
        '/home': (context) => const HomeScreen(),
        '/reset_password': (context) => const ResetPasswordPage(),
        '/my_jobs': (context) => const MyJobs(),
        '/weekly_earnings': (context) => const WeeklyEarningsScreen(),
        '/my_profile': (context) => const MyProfileScreen(),
        '/settings': (context) => const SettingsPage(),
        '/notification_settings': (context) => const NotificationSettings(),
        '/payments_setup': (context) => const PaymentsSetupScreen(),
        '/support': (context) => const SupportScreen(),
        '/delete_account': (context) => const DeleteAccountScreen(),
        '/notifications': (context) => const NotificationsScreen(),
      },
    );
  }
}
