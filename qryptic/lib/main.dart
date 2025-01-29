import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qryptic/QrypticTheme.dart';
import 'package:qryptic/helper/database.dart';
import 'package:qryptic/screens/HomeScreen.dart';
import 'package:qryptic/screens/loginScreen.dart';
import 'package:qryptic/screens/onboardingScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  bool isUserLoggedIn =
      FirebaseAuth.instance.currentUser != null ? true : false;
  bool isUserOnboard = false;
  if (isUserLoggedIn) {
    isUserOnboard =
        await isUserOnboarded(FirebaseAuth.instance.currentUser!.uid);
  }
  runApp(MyApp(
    isUserLoggedIn: isUserLoggedIn,
    isUserOnboard: isUserOnboard,
  ));
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.isUserLoggedIn, required this.isUserOnboard});
  bool isUserLoggedIn;
  bool isUserOnboard;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qryptic',
      theme: QrypticTheme.lightTheme,
      darkTheme: QrypticTheme.darkTheme,
      themeMode: ThemeMode.dark, // Set to dark mode initially
      debugShowCheckedModeBanner: false,
      home: isUserLoggedIn
          ? isUserOnboard
              ? HomeScreen()
              : UserOnboardingScreen(
                  uid: FirebaseAuth.instance.currentUser!.uid)
          : LoginScreen(),
    );
  }
}
