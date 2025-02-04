// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:lottie/lottie.dart';

// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen>
//     with SingleTickerProviderStateMixin {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   bool _isLoading = false;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     );
//     _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.easeInOut,
//       ),
//     );
//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   Future<void> _loginWithEmailPassword() async {
//     setState(() => _isLoading = true);
//     try {
//       await _auth.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to login: $e')),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: AnimatedBuilder(
//               animation: _animationController,
//               builder: (context, child) {
//                 return Container(
//                   decoration: BoxDecoration(
//                     gradient: RadialGradient(
//                       colors: [
//                         Colors.purpleAccent.withOpacity(0.3),
//                         Colors.black,
//                       ],
//                       center: Alignment(0, 0),
//                       radius: 1.5,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Positioned(
//             top: 50,
//             left: 20,
//             right: 20,
//             child: FadeTransition(
//               opacity: _fadeAnimation,
//               child: Lottie.asset(
//                 'assets/animations/login_screen2.json',
//                 height: 250,
//               ),
//             ),
//           ),
//           Center(
//             child: FadeTransition(
//               opacity: _fadeAnimation,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.only(
//                         top: MediaQuery.of(context).size.height * 0.1),
//                     child: Text(
//                       'Qryptic',
//                       style: TextStyle(
//                         fontSize: 42,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.cyanAccent,
//                         shadows: [
//                           Shadow(
//                             blurRadius: 20,
//                             color: Colors.cyanAccent,
//                             offset: Offset(0, 0),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 48),
//                   _buildTextField('Email', _emailController, false),
//                   SizedBox(height: 24),
//                   _buildTextField('Password', _passwordController, true),
//                   SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: _loginWithEmailPassword,
//                     style: ElevatedButton.styleFrom(
//                       padding:
//                           EdgeInsets.symmetric(vertical: 16, horizontal: 64),
//                       backgroundColor: Colors.cyanAccent,
//                       foregroundColor: Colors.black,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 12,
//                     ),
//                     child: _isLoading
//                         ? SpinKitWave(color: Colors.black, size: 24)
//                         : Text(
//                             'Login',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField(
//       String label, TextEditingController controller, bool isObscure) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 24),
//       child: TextField(
//         controller: controller,
//         obscureText: isObscure,
//         decoration: InputDecoration(
//           filled: true,
//           fillColor: Colors.grey[900],
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//           labelText: label,
//           labelStyle: TextStyle(color: Colors.white),
//         ),
//         style: TextStyle(color: Colors.white),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:qryptic/helper/database.dart';
import 'package:qryptic/screens/HomeScreen.dart';
import 'package:qryptic/screens/OnboardingScreen.dart';
import 'package:qryptic/widget/FuturisticButton.dart';
import 'package:qryptic/widget/FuturisticTextField.dart';
import 'package:qryptic/widget/FuturisticToast.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Future<void> _loginWithEmailPassword() async {
  //   setState(() => _isLoading = true);
  //   try {
  //     final a = await _auth.signInWithEmailAndPassword(
  //       email: _emailController.text.trim(),
  //       password: _passwordController.text.trim(),
  //     );
  //     FuturisticToast.show(context, message: "Successfully Logged In");
  //     Navigator.of(context).pushReplacement(MaterialPageRoute(
  //       builder: (context) => UserOnboardingScreen(uid: a.user!.uid),
  //     ));
  //   } catch (e) {
  //     FuturisticToast.show(context, message: "Failed to login : $e");
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }
  Future<void> _loginWithEmailPassword() async {
    setState(() => _isLoading = true);
    try {
      final userExists = await isUserExist(_emailController.text.trim());
      UserCredential userCredential;
      userExists == 0
          ? userCredential = await _auth.createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            )
          : userCredential = await _auth.signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

      if (userExists == 1) {
        FuturisticToast.show(context, message: "Login Successful");

        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ));
      } else if (userExists == 0 || userExists == 2) {
        FuturisticToast.show(context,
            message: "Starting User Onboarding Program...");
        await createUser(
            _emailController.text.trim(), userCredential.user!.uid);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => UserOnboardingScreen(
            uid: userCredential.user!.uid,
          ),
        ));
      } else {
        FuturisticToast.show(context, message: "Something Went Wrong !!!");
      }
    } catch (e) {
      FuturisticToast.show(context, message: "Something Went Wrong !!!");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Glowing Gradient Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.purpleAccent.withOpacity(0.4),
                        Colors.black,
                      ],
                      center: Alignment(0, 0),
                      radius: 1.5,
                    ),
                  ),
                );
              },
            ),
          ),
          // Lottie Animation (Login Animation)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Lottie.asset(
                'assets/animations/login_screen2.json',
                height: 250,
              ),
            ),
          ),
          // Futuristic Login UI
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title - Qryptic
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.1),
                    child: Text(
                      'Qryptic',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent,
                        shadows: [
                          Shadow(
                            blurRadius: 20,
                            color: Colors.cyanAccent,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 48),
                  FuturisticTextField(
                      label: 'Email',
                      controller: _emailController,
                      isObscure: false,
                      onChange: (_) => {}),
                  SizedBox(height: 24),
                  FuturisticTextField(
                      label: 'Password',
                      controller: _passwordController,
                      isObscure: true,
                      onChange: (_) => {}),
                  SizedBox(height: 24),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: FuturisticButton(
                      isLoading: _isLoading,
                      onPressed: _loginWithEmailPassword,
                      buttonText: "Login",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Futuristic Text Field with Neon Glow
}
