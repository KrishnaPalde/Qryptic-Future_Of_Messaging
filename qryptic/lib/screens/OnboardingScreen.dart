// import 'package:flutter/material.dart';
// import 'package:qryptic/helper/StaticData.dart';
// import 'package:qryptic/helper/database.dart';
// import 'package:qryptic/model/QrypticUser.dart';
// import 'package:qryptic/screens/HomeScreen.dart';

// class UserOnboardingScreen extends StatefulWidget {
//   @override
//   UserOnboardingScreen({required this.uid});
//   final uid;
//   _UserOnboardingScreenState createState() => _UserOnboardingScreenState();
// }

// class _UserOnboardingScreenState extends State<UserOnboardingScreen> {
//   int _currentStep = 0;

//   // Controllers for TextFields
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _mobileController = TextEditingController();
//   final _qrypticPhraseController = TextEditingController();
//   final _bioController = TextEditingController();

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   List<Step> _getSteps() {
//     return [
//       Step(
//         title:
//             const Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
//         content: Column(
//           children: [
//             TextField(
//               controller: _firstNameController,
//               decoration: const InputDecoration(
//                 labelText: 'Enter your first name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _lastNameController,
//               decoration: const InputDecoration(
//                 labelText: 'Enter your last name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ],
//         ),
//         isActive: _currentStep >= 0,
//         state: _currentStep == 0 ? StepState.editing : StepState.complete,
//       ),
//       Step(
//         title:
//             const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
//         content: TextField(
//           controller: _mobileController,
//           decoration: const InputDecoration(
//             labelText: 'Enter your Mobile Number',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         isActive: _currentStep >= 1,
//         state: _currentStep == 1 ? StepState.editing : StepState.complete,
//       ),
//       Step(
//         title: const Text("Qryptic Phrase",
//             style: TextStyle(fontWeight: FontWeight.bold)),
//         content: TextField(
//           controller: _qrypticPhraseController,
//           decoration: const InputDecoration(
//             labelText: 'Enter your unique Qryptic Phrase',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         isActive: _currentStep >= 2,
//         state: _currentStep == 2 ? StepState.editing : StepState.complete,
//       ),
//       Step(
//         title: const Text("Bio", style: TextStyle(fontWeight: FontWeight.bold)),
//         content: TextField(
//           controller: _bioController,
//           decoration: const InputDecoration(
//             labelText: 'Write a short bio',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         isActive: _currentStep >= 3,
//         state: _currentStep == 3 ? StepState.editing : StepState.complete,
//       ),
//     ];
//   }

//   void _onStepContinue() {
//     if (_currentStep < _getSteps().length - 1) {
//       setState(() {
//         _currentStep += 1;
//       });
//     }
//   }

//   void _onStepCancel() {
//     if (_currentStep > 0) {
//       setState(() {
//         _currentStep -= 1;
//       });
//     }
//   }

//   Future<int> onboardUser() async {
//     try {
//       return onboardUserData(
//         "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}",
//         _mobileController.text.trim(),
//         _qrypticPhraseController.text.trim(),
//         _bioController.text.trim(),
//         widget.uid,
//       );
//     } catch (e) {
//       return -1;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Adjust layout based on screen size
//     double screenWidth = MediaQuery.of(context).size.width;
//     bool isWideScreen = screenWidth > 600;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.deepPurpleAccent,
//         title: const Text("User Onboarding"),
//       ),
//       body: Padding(
//         padding: isWideScreen
//             ? const EdgeInsets.symmetric(horizontal: 50, vertical: 30)
//             : const EdgeInsets.all(16.0),
//         child: Container(
//           child: Stepper(
//             type: StepperType.vertical,
//             currentStep: _currentStep,
//             onStepContinue: _onStepContinue,
//             onStepCancel: _onStepCancel,
//             steps: _getSteps(),
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           if (_currentStep == _getSteps().length - 1) {
//             // Onboarding complete
//             final status = await onboardUser();
//             if (status == 1) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Successfully onboard")));
//               Navigator.of(context).pushReplacement(MaterialPageRoute(
//                 builder: (context) => HomeScreen(),
//               ));
//             } else {
//               ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("error onboarding")));
//             }
//           } else {
//             _onStepContinue();
//           }
//         },
//         child: const Icon(Icons.check),
//         backgroundColor: Colors.deepPurpleAccent,
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:qryptic/helper/database.dart';
// import 'package:qryptic/screens/HomeScreen.dart';

// class UserOnboardingScreen extends StatefulWidget {
//   final String uid;
//   UserOnboardingScreen({required this.uid});

//   @override
//   _UserOnboardingScreenState createState() => _UserOnboardingScreenState();
// }

// class _UserOnboardingScreenState extends State<UserOnboardingScreen> {
//   int _currentStep = 0;

//   // Controllers for TextFields
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _mobileController = TextEditingController();
//   final _qrypticPhraseController = TextEditingController();
//   final _bioController = TextEditingController();

//   List<String> suggestedQPCs = [];
//   String qpcStatus = "Enter QPC";

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   // Regex for validating QPC (letters, numbers, hyphens, and underscores only)
//   bool isValidQPC(String qpc) {
//     final regex = RegExp(r'^[a-zA-Z0-9-_]+$');
//     return regex.hasMatch(qpc);
//   }

//   // Function to get auto-suggestions (including name-based suggestions)
//   // Function to get auto-suggestions (including name-based suggestions)
//   Future<void> getAutoSuggestions(String query) async {
//     // Generate suggestions based on the first and last name
//     String firstName = _firstNameController.text.trim();
//     String lastName = _lastNameController.text.trim();

//     // Generate a few variations for the QPC
//     List<String> nameBasedSuggestions = [
//       '${firstName.toLowerCase()}${lastName.toLowerCase()}',
//       '${firstName.toLowerCase()}_${lastName.toLowerCase()}',
//       '${firstName.toLowerCase()}-${lastName.toLowerCase()}',
//       '${firstName.substring(0, 3).toLowerCase()}${lastName.substring(0, 3).toLowerCase()}',
//       '${firstName.substring(0, 2).toLowerCase()}-${lastName.substring(0, 2).toLowerCase()}',
//       '${firstName.length}${lastName.length}',
//       '${firstName}${lastName.length}',
//     ];

//     // Filter suggestions based on query
//     List<String> filteredSuggestions = nameBasedSuggestions
//         .where((element) => element.toLowerCase().contains(query.toLowerCase()))
//         .toList();

//     // Check availability of each suggestion
//     List<String> availableSuggestions = [];
//     for (String suggestion in filteredSuggestions) {
//       bool available = await checkQPCAvailability(suggestion);
//       if (available) {
//         availableSuggestions.add(suggestion); // Only add available suggestions
//       }
//     }

//     setState(() {
//       suggestedQPCs = availableSuggestions;
//     });
//   }

//   List<Step> _getSteps() {
//     return [
//       Step(
//         title:
//             const Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
//         content: Column(
//           children: [
//             TextField(
//               controller: _firstNameController,
//               decoration: const InputDecoration(
//                 labelText: 'Enter your first name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _lastNameController,
//               decoration: const InputDecoration(
//                 labelText: 'Enter your last name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ],
//         ),
//         isActive: _currentStep >= 0,
//         state: _currentStep == 0 ? StepState.editing : StepState.complete,
//       ),
//       Step(
//         title:
//             const Text("Mobile", style: TextStyle(fontWeight: FontWeight.bold)),
//         content: TextField(
//           controller: _mobileController,
//           decoration: const InputDecoration(
//             labelText: 'Enter your Mobile Number',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         isActive: _currentStep >= 1,
//         state: _currentStep == 1 ? StepState.editing : StepState.complete,
//       ),
//       Step(
//         title: const Text("Qryptic Phrase",
//             style: TextStyle(fontWeight: FontWeight.bold)),
//         content: Column(
//           children: [
//             TextField(
//               controller: _qrypticPhraseController,
//               decoration: InputDecoration(
//                 labelText: 'Enter your unique Qryptic Phrase',
//                 border: OutlineInputBorder(),
//                 suffixText: isValidQPC(_qrypticPhraseController.text)
//                     ? qpcStatus
//                     : 'Invalid Format',
//                 suffixStyle: TextStyle(
//                   color: isValidQPC(_qrypticPhraseController.text)
//                       ? qpcStatus == "Not Available"
//                           ? Colors.red
//                           : Colors.green
//                       : Colors.red,
//                 ),
//               ),
//               onChanged: (value) async {
//                 setState(() {
//                   qpcStatus = 'Checking...';
//                 });

//                 if (isValidQPC(value)) {
//                   // Check QPC availability
//                   bool available = await checkQPCAvailability(value);
//                   setState(() {
//                     qpcStatus = available ? 'Available' : 'Not Available';
//                   });
//                 }

//                 // Fetch auto-suggestions
//                 await getAutoSuggestions(value);
//                 // } else {
//                 //   setState(() {
//                 //     suggestedQPCs = [];
//                 //   });
//                 // }
//               },
//             ),
//             const SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 const Text('Suggestions: '),
//                 Expanded(
//                   child: Wrap(
//                     spacing: 8.0, // Add space between items
//                     runSpacing: 4.0, // Add space between lines
//                     children: suggestedQPCs.map((suggestion) {
//                       return GestureDetector(
//                         onTap: () {
//                           _qrypticPhraseController.text = suggestion;
//                           setState(() {
//                             qpcStatus = 'Available';
//                           });
//                         },
//                         child: Text(
//                           "$suggestion, ",
//                           style: const TextStyle(color: Colors.blue),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         isActive: _currentStep >= 2,
//         state: _currentStep == 2 ? StepState.editing : StepState.complete,
//       ),
//       Step(
//         title: const Text("Bio", style: TextStyle(fontWeight: FontWeight.bold)),
//         content: TextField(
//           controller: _bioController,
//           decoration: const InputDecoration(
//             labelText: 'Write a short bio',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         isActive: _currentStep >= 3,
//         state: _currentStep == 3 ? StepState.editing : StepState.complete,
//       ),
//     ];
//   }

//   void _onStepContinue() {
//     if (_currentStep < _getSteps().length - 1) {
//       setState(() {
//         _currentStep += 1;
//       });
//     }
//   }

//   void _onStepCancel() {
//     if (_currentStep > 0) {
//       setState(() {
//         _currentStep -= 1;
//       });
//     }
//   }

//   Future<int> onboardUser() async {
//     try {
//       return onboardUserData(
//         "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}",
//         _mobileController.text.trim(),
//         _qrypticPhraseController.text.trim(),
//         _bioController.text.trim(),
//         widget.uid,
//       );
//     } catch (e) {
//       return -1;
//     }
//   }

//   @override
//   void initState() {
//     super.initState();

//     // Generate 5 default QPC suggestions when the screen loads
//     String firstName = _firstNameController.text.trim();
//     String lastName = _lastNameController.text.trim();
//     List<String> nameBasedSuggestions = [];
//     if (firstName.isNotEmpty &&
//         lastName.isNotEmpty &&
//         firstName.length > 4 &&
//         lastName.length > 4) {
//       nameBasedSuggestions = [
//         '${firstName.toLowerCase()}${lastName.toLowerCase()}',
//         '${firstName.toLowerCase()}_${lastName.toLowerCase()}',
//         '${firstName.toLowerCase()}-${lastName.toLowerCase()}',
//         '${firstName.substring(0, 3).toLowerCase()}${lastName.substring(0, 3).toLowerCase()}',
//         '${firstName.substring(0, 2).toLowerCase()}-${lastName.substring(0, 2).toLowerCase()}',
//       ];
//     }

//     setState(() {
//       suggestedQPCs = nameBasedSuggestions;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Adjust layout based on screen size
//     double screenWidth = MediaQuery.of(context).size.width;
//     bool isWideScreen = screenWidth > 600;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.deepPurpleAccent,
//         title: const Text("User Onboarding"),
//       ),
//       body: Padding(
//         padding: isWideScreen
//             ? const EdgeInsets.symmetric(horizontal: 50, vertical: 30)
//             : const EdgeInsets.all(16.0),
//         child: Container(
//           child: Stepper(
//             type: StepperType.vertical,
//             currentStep: _currentStep,
//             onStepContinue: _onStepContinue,
//             onStepCancel: _onStepCancel,
//             steps: _getSteps(),
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           if (_currentStep == _getSteps().length - 1) {
//             // Onboarding complete
//             final status = await onboardUser();
//             if (status == 1) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("User onboarded successfully")));
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (_) => HomeScreen()),
//               );
//             } else {
//               ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Error onboarding user")));
//             }
//           }
//         },
//         child: const Icon(Icons.check),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:qryptic/helper/database.dart';
import 'package:qryptic/screens/HomeScreen.dart';
import 'package:qryptic/widget/CustomProgressIndicator.dart';
import 'package:qryptic/widget/FuturisticTextField.dart';
import 'package:qryptic/widget/FuturisticButton.dart';

class UserOnboardingScreen extends StatefulWidget {
  final String uid;
  UserOnboardingScreen({required this.uid});

  @override
  _UserOnboardingScreenState createState() => _UserOnboardingScreenState();
}

class _UserOnboardingScreenState extends State<UserOnboardingScreen> {
  int _currentStep = 0;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _qrypticPhraseController = TextEditingController();
  final _bioController = TextEditingController();

  List<String> suggestedQPCs = [];
  String qpcStatus = "Enter QPC";
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
  }

  bool isValidQPC(String qpc) {
    final regex = RegExp(r'^[a-zA-Z0-9-_]+$');
    return regex.hasMatch(qpc);
  }

  Future<void> getAutoSuggestions(String query) async {
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    List<String> nameBasedSuggestions = [
      '${firstName.toLowerCase()}${lastName.toLowerCase()}',
      '${firstName.toLowerCase()}_${lastName.toLowerCase()}',
      '${firstName.toLowerCase()}-${lastName.toLowerCase()}',
    ];
    List<String> filteredSuggestions = nameBasedSuggestions
        .where((element) => element.toLowerCase().contains(query.toLowerCase()))
        .toList();

    List<String> availableSuggestions = [];
    for (String suggestion in filteredSuggestions) {
      bool available = await checkQPCAvailability(suggestion);
      if (available) {
        availableSuggestions.add(suggestion);
      }
    }

    setState(() {
      suggestedQPCs = availableSuggestions;
    });
  }

  Future<int> onboardUser() async {
    try {
      return onboardUserData(
        "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}",
        _mobileController.text.trim(),
        _qrypticPhraseController.text.trim(),
        _bioController.text.trim(),
        widget.uid,
      );
    } catch (e) {
      return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "User Onboarding",
          style: TextStyle(
              color: Colors.cyanAccent,
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.bold,
              fontSize: 24),
        ),
      ),
      body: Padding(
        padding: isWideScreen
            ? const EdgeInsets.symmetric(horizontal: 50, vertical: 30)
            : const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Ensures content is scrollable
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    // Quantum progress bar
                    LinearProgressIndicator(
                      value: (_currentStep + 1) / 4,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation(Colors.cyanAccent),
                    ),
                    const SizedBox(height: 20),

                    // Animated panel transitions
                    if (_currentStep == 0)
                      FadeInRight(
                        duration: Duration(milliseconds: 500),
                        child: _buildStep1(),
                      ),
                    if (_currentStep == 1)
                      FadeInRight(
                        duration: Duration(milliseconds: 500),
                        child: _buildStep2(),
                      ),
                    if (_currentStep == 2)
                      FadeInRight(
                        duration: Duration(milliseconds: 500),
                        child: _buildStep3(),
                      ),
                    if (_currentStep == 3)
                      FadeInRight(
                        duration: Duration(milliseconds: 500),
                        child: _buildStep4(),
                      ),
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  // height: MediaQuery.of(context).size.height * 0.1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.02,
                            right: 15),
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: GestureDetector(
                              onTap: () {
                                if (_currentStep > 0) {
                                  setState(() {
                                    _currentStep--;
                                  });
                                }
                              },
                              child: MouseRegion(
                                onEnter: (_) => () {
                                  if (_currentStep > 0) {
                                    setState(() {
                                      _currentStep--;
                                    });
                                  }
                                },
                                onExit: (_) => () {
                                  if (_currentStep > 0) {
                                    setState(() {
                                      _currentStep--;
                                    });
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 10),
                                  decoration: BoxDecoration(
                                    // Applying the transparent background with a cyan border
                                    color: _isLoading
                                        ? Colors.cyanAccent.withOpacity(0.8)
                                        : Colors
                                            .transparent, // Transparent when not loading
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.cyan,
                                        width: 2), // Border with cyan color
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? SpinKitWave(
                                            color: Colors.black,
                                            size: 24) // Loading indicator
                                        : Text(
                                            'Back', // Updated text for the button
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.cyanAccent
                                                  .withOpacity(0.8),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Next Button
                      Padding(
                        padding: EdgeInsets.only(right: 15.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          child: FuturisticButton(
                            isLoading: _isLoading,
                            onPressed: () async {
                              if (_currentStep == 3) {
                                CustomProgressIndicator().show(context);
                                final status = await onboardUser();
                                Future.delayed(Duration(seconds: 5));
                                CustomProgressIndicator().dismiss();
                                if (status == 1) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "User onboarded successfully")));
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => HomeScreen()),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text("Error onboarding user")));
                                }
                              } else {
                                setState(() {
                                  _currentStep++;
                                });
                              }
                            },
                            buttonText: _currentStep == 3 ? "Finish" : "Next",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        FuturisticTextField(
            label: "Enter First Name",
            controller: _firstNameController,
            isObscure: false,
            onChange: (_) => {}),
        const SizedBox(height: 10),
        FuturisticTextField(
            label: "Enter Last Name",
            controller: _lastNameController,
            isObscure: false,
            onChange: (_) => {}),
      ],
    );
  }

  Widget _buildStep2() {
    return FuturisticTextField(
      label: "Enter Mobile Number",
      controller: _mobileController,
      isObscure: false,
      onChange: (_) => {},
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        // FuturisticTextField(
        //     label: "Enter Qryptic Phrase",
        //     controller: _qrypticPhraseController,
        //     isObscure: false,
        //     onChange: (q) async => {getAutoSuggestions(q)}),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: TextField(
            controller: _qrypticPhraseController,
            obscureText: false,
            style: TextStyle(color: Colors.white, fontSize: 18),
            cursorColor: Colors.cyanAccent,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              labelText: "Enter Qryptic Phrase",
              labelStyle: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              floatingLabelStyle: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(blurRadius: 10, color: Colors.cyanAccent),
                ],
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.cyanAccent, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.cyanAccent, width: 2.5),
              ),
              suffixText: isValidQPC(_qrypticPhraseController.text)
                  ? qpcStatus
                  : 'Invalid Format',
              suffixStyle: TextStyle(
                color: isValidQPC(_qrypticPhraseController.text)
                    ? qpcStatus == "Not Available"
                        ? Colors.red
                        : Colors.green
                    : Colors.red,
              ),
            ),
            onChanged: (value) async {
              setState(() {
                qpcStatus = 'Checking...';
              });

              if (isValidQPC(value)) {
                // Check QPC availability
                bool available = await checkQPCAvailability(value);
                setState(() {
                  qpcStatus = available ? 'Available' : 'Not Available';
                });
              }

              // Fetch auto-suggestions
              await getAutoSuggestions(value);
              // } else {
              //   setState(() {
              //     suggestedQPCs = [];
              //   });
              // }
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text('Suggestions: '),
            Expanded(
              child: Wrap(
                spacing: 8.0, // Add space between items
                runSpacing: 4.0, // Add space between lines
                children: suggestedQPCs.map((suggestion) {
                  return GestureDetector(
                    onTap: () {
                      _qrypticPhraseController.text = suggestion;
                      setState(() {
                        qpcStatus = 'Available';
                      });
                    },
                    child: Text(
                      "$suggestion, ",
                      style: const TextStyle(color: Colors.blue),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return FuturisticTextField(
        label: "Write a Short Bio (Optional)",
        controller: _bioController,
        isObscure: false,
        onChange: (_) => {});
  }
}
