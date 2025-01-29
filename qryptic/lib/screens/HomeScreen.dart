import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:qryptic/helper/StaticData.dart';
import 'package:qryptic/helper/database.dart';
import 'package:qryptic/screens/ChatScreen.dart';
import 'package:qryptic/screens/QPC_Screen.dart';
import 'package:qryptic/screens/SettingsScreen.dart';
import 'package:qryptic/widget/CustomBottomNavbar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _controller;

  final List<Widget> _screens = [
    ChatScreen(),
    QPCScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: getUserData(FirebaseAuth.instance.currentUser!.uid),
          // future: null,ð
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              StaticData.user = snapshot.data!;
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 600),
                child: _screens[_currentIndex],
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0.0, 1.0),
                      end: Offset(0.0, 0.0),
                    ).animate(animation),
                    child: child,
                  );
                },
              );
            } else {
              return SpinKitChasingDots(color: Colors.white, size: 40);
            }
          }),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
