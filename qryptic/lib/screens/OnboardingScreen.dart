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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qryptic/helper/database.dart';
import 'package:qryptic/screens/HomeScreen.dart';

class UserOnboardingScreen extends StatefulWidget {
  final String uid;
  UserOnboardingScreen({required this.uid});

  @override
  _UserOnboardingScreenState createState() => _UserOnboardingScreenState();
}

class _UserOnboardingScreenState extends State<UserOnboardingScreen> {
  int _currentStep = 0;

  // Controllers for TextFields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _qrypticPhraseController = TextEditingController();
  final _bioController = TextEditingController();

  List<String> suggestedQPCs = [];
  String qpcStatus = "Enter QPC";

  @override
  void dispose() {
    super.dispose();
  }

  // Regex for validating QPC (letters, numbers, hyphens, and underscores only)
  bool isValidQPC(String qpc) {
    final regex = RegExp(r'^[a-zA-Z0-9-_]+$');
    return regex.hasMatch(qpc);
  }

  // Function to get auto-suggestions (including name-based suggestions)
  // Function to get auto-suggestions (including name-based suggestions)
  Future<void> getAutoSuggestions(String query) async {
    // Generate suggestions based on the first and last name
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();

    // Generate a few variations for the QPC
    List<String> nameBasedSuggestions = [
      '${firstName.toLowerCase()}${lastName.toLowerCase()}',
      '${firstName.toLowerCase()}_${lastName.toLowerCase()}',
      '${firstName.toLowerCase()}-${lastName.toLowerCase()}',
      '${firstName.substring(0, 3).toLowerCase()}${lastName.substring(0, 3).toLowerCase()}',
      '${firstName.substring(0, 2).toLowerCase()}-${lastName.substring(0, 2).toLowerCase()}',
      '${firstName.length}${lastName.length}',
      '${firstName}${lastName.length}',
    ];

    // Filter suggestions based on query
    List<String> filteredSuggestions = nameBasedSuggestions
        .where((element) => element.toLowerCase().contains(query.toLowerCase()))
        .toList();

    // Check availability of each suggestion
    List<String> availableSuggestions = [];
    for (String suggestion in filteredSuggestions) {
      bool available = await checkQPCAvailability(suggestion);
      if (available) {
        availableSuggestions.add(suggestion); // Only add available suggestions
      }
    }

    setState(() {
      suggestedQPCs = availableSuggestions;
    });
  }

  List<Step> _getSteps() {
    return [
      Step(
        title:
            const Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          children: [
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'Enter your first name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Enter your last name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 0,
        state: _currentStep == 0 ? StepState.editing : StepState.complete,
      ),
      Step(
        title:
            const Text("Mobile", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _mobileController,
          decoration: const InputDecoration(
            labelText: 'Enter your Mobile Number',
            border: OutlineInputBorder(),
          ),
        ),
        isActive: _currentStep >= 1,
        state: _currentStep == 1 ? StepState.editing : StepState.complete,
      ),
      Step(
        title: const Text("Qryptic Phrase",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          children: [
            TextField(
              controller: _qrypticPhraseController,
              decoration: InputDecoration(
                labelText: 'Enter your unique Qryptic Phrase',
                border: OutlineInputBorder(),
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
        ),
        isActive: _currentStep >= 2,
        state: _currentStep == 2 ? StepState.editing : StepState.complete,
      ),
      Step(
        title: const Text("Bio", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _bioController,
          decoration: const InputDecoration(
            labelText: 'Write a short bio',
            border: OutlineInputBorder(),
          ),
        ),
        isActive: _currentStep >= 3,
        state: _currentStep == 3 ? StepState.editing : StepState.complete,
      ),
    ];
  }

  void _onStepContinue() {
    if (_currentStep < _getSteps().length - 1) {
      setState(() {
        _currentStep += 1;
      });
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
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
  void initState() {
    super.initState();

    // Generate 5 default QPC suggestions when the screen loads
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    List<String> nameBasedSuggestions = [];
    if (firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        firstName.length > 4 &&
        lastName.length > 4) {
      nameBasedSuggestions = [
        '${firstName.toLowerCase()}${lastName.toLowerCase()}',
        '${firstName.toLowerCase()}_${lastName.toLowerCase()}',
        '${firstName.toLowerCase()}-${lastName.toLowerCase()}',
        '${firstName.substring(0, 3).toLowerCase()}${lastName.substring(0, 3).toLowerCase()}',
        '${firstName.substring(0, 2).toLowerCase()}-${lastName.substring(0, 2).toLowerCase()}',
      ];
    }

    setState(() {
      suggestedQPCs = nameBasedSuggestions;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Adjust layout based on screen size
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text("User Onboarding"),
      ),
      body: Padding(
        padding: isWideScreen
            ? const EdgeInsets.symmetric(horizontal: 50, vertical: 30)
            : const EdgeInsets.all(16.0),
        child: Container(
          child: Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepContinue: _onStepContinue,
            onStepCancel: _onStepCancel,
            steps: _getSteps(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_currentStep == _getSteps().length - 1) {
            // Onboarding complete
            final status = await onboardUser();
            if (status == 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User onboarded successfully")));
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Error onboarding user")));
            }
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
