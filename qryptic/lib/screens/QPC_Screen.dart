// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:mobile_scanner/mobile_scanner.dart'; // Import mobile_scanner
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:qryptic/helper/StaticData.dart';
// import 'package:qryptic/helper/database.dart';
// import 'package:qryptic/model/QrypticUser.dart';
// import 'package:qryptic/widget/CustomProgressIndicator.dart';
// import 'package:qryptic/widget/FuturisticToast.dart';
// import 'package:qryptic/widget/ScannedBarcodeLabel.dart';

// class QPCScreen extends StatefulWidget {
//   @override
//   _QPCScreenState createState() => _QPCScreenState();
// }

// class _QPCScreenState extends State<QPCScreen> {
//   final TextEditingController _qpcController = TextEditingController();
//   // String scannedQPC = '';
//   String scannedQPC = ''; // Replace with actual user QPC
//   String userName = '';
//   String connectedQPC = '';
//   bool isLoading = true;
//   bool isPopupOpen = false;

//   MobileScannerController _scannerController =
//       MobileScannerController(); // MobileScanner controller

//   @override
//   void dispose() {
//     _scannerController.dispose(); // Dispose of the scanner controller
//     super.dispose();
//   }

//   void setStateCallback() {
//     setState(() {
//       isPopupOpen = false;
//     });
//   }

//   void _showLoadingDialog(BuildContext context,
//       [Map<String, String> data = const {}]) {
//     showDialog(
//       context: context,
//       barrierDismissible:
//           false, // Prevent closing the dialog by tapping outside
//       builder: (context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: LoadingDialogContent(
//             connectedQPC,
//             userName,
//             setStateCallback,
//             data,
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("QPC Screen - Share and Connect"),
//       ),
//       body: Column(
//         children: [
//           // QR Scanner takes 3/4 of the screen
//           Expanded(
//             flex: 3,
//             child: MobileScanner(
//               overlayBuilder: (context, constraints) {
//                 return Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Align(
//                     alignment: Alignment.bottomCenter,
//                     child: ScannedBarcodeLabel(
//                         barcodes: _scannerController.barcodes),
//                   ),
//                 );
//               },
//               controller: _scannerController,
//               onDetect: (barcode) async {
//                 setState(() {
//   scannedQPC = {
//         for (var element in barcode.raw!
//             .toString()
//             .replaceAll(RegExp(r'[\[\]{}]'), '')
//             .split(",")
//             .where(
//               (element) => element.contains(": "),
//             ))
//           element.split(": ")[0].trim():
//               element.split(": ").sublist(1).join(": ").trim()
//       }['displayValue'] ??
//       "";
// });
//                 if (scannedQPC.isNotEmpty) {
//                   print(scannedQPC);
//                   CustomProgressIndicator().show(context);
//                   final data = await connectUserViaQR(scannedQPC.trim());
//                   CustomProgressIndicator().dismiss();
//                   FuturisticToast.show(context,
//                       message: "Successfully Connected");
//                   if (data.isNotEmpty) {
//                     if (data.containsKey("error") ||
//                         data.containsKey('message')) {
//                       if (!isPopupOpen) {
//                         _showLoadingDialog(context, data);
//                       }
//                       setState(() {
//                         isPopupOpen = true;
//                       });
//                     } else {
//                       setState(() {
//                         userName = data["name"]!;
//                         connectedQPC = data["QPC"]!;
//                       });
//                       if (!isPopupOpen) {
//                         _showLoadingDialog(context);
//                       }
//                       setState(() {
//                         isPopupOpen = true;
//                       });
//                     }
//                   }
//                 }
//               },
//             ),
//           ),

//           // Manual QPC entry takes 1/4 of the screen
//           Expanded(
//             flex: 1,
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   TextField(
//                     controller: _qpcController,
//                     decoration: const InputDecoration(
//                       labelText: "Enter QPC",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Center(
//                     child: ElevatedButton(
//                       onPressed: () async {
//                         CustomProgressIndicator().show(context);
//                         final data =
//                             await connectUserViaQR(_qpcController.text.trim());
//                         CustomProgressIndicator().dismiss();
//                         if (data.isNotEmpty) {
//                           if (data.containsKey("error") ||
//                               data.containsKey('message')) {
//                             if (!isPopupOpen) {
//                               _showLoadingDialog(context, data);
//                             }
//                             setState(() {
//                               isPopupOpen = true;
//                             });
//                           } else {
//                             setState(() {
//                               userName = data["name"]!;
//                               connectedQPC = data["QPC"]!;
//                             });
//                             if (!isPopupOpen) {
//                               _showLoadingDialog(context);
//                             }
//                             setState(() {
//                               isPopupOpen = true;
//                             });
//                           }
//                         }
//                       },
//                       child: const Text(
//                         "Connect",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(fontSize: 16),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _showGeneratedQRCode(context);
//         },
//         child: const Icon(Icons.qr_code),
//         tooltip: 'Show Generated QR Code',
//       ),
//     );
//   }

//   // Function to show the generated QR code in a dialog
//   void _showGeneratedQRCode(BuildContext context) {
//     bool hasJoinedSession = false;
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         child: StreamBuilder(
//             stream: FirebaseFirestore.instance
//                 .collection('users')
//                 .doc(FirebaseAuth.instance.currentUser!.uid)
//                 .snapshots(),
//             builder: (context, snapshot) {
//               print(StaticData.user.qrypticPhrase.toString());
//               if (snapshot.connectionState == ConnectionState.active) {
//                 if (!snapshot.hasData || snapshot.data == null) {
//                   return const Center(
//                     child: Text("Error"),
//                   );
//                 }
//                 QrypticUser user = QrypticUser.fromMap(snapshot.data!.data()!);
//                 print(StaticData.hasJoinedSession);
//                 if (user.qkdSessionId.isNotEmpty &&
//                     !StaticData.hasJoinedSession &&
//                     !user.isSessionFinished) {
//                   return FutureBuilder(
//                     future: joinQKDSession(user.qkdSessionId),
//                     builder: (context, futureSnapshot) {
//                       if (futureSnapshot.connectionState ==
//                           ConnectionState.waiting) {
//                         return const Padding(
//                           padding: EdgeInsets.all(20.0),
//                           child: SpinKitFadingCube(
//                             color: Colors.white,
//                             size: 40.0,
//                           ),
//                         );
//                       } else {
//                         FuturisticToast.show(context,
//                             message: "Successfully Conntected");
//                         StaticData.hasJoinedSession = true;
//                         return Center(
//                           child: Column(
//                             children: [
//                               const Icon(
//                                 Icons.check_circle,
//                                 color: Colors.green,
//                                 size: 80,
//                               ),
//                               const SizedBox(
//                                 height: 50,
//                               ),
//                               ElevatedButton(
//                                 onPressed: () async {
//                                   await FirebaseFirestore.instance
//                                       .collection('users')
//                                       .doc(FirebaseAuth
//                                           .instance.currentUser!.uid)
//                                       .update({
//                                     'qkdSessionId': "",
//                                     'isSessionFinished': false,
//                                   });
//                                   StaticData.hasJoinedSession = false;
//                                   Navigator.pop(context); // Close the dialog
//                                   Navigator.pop(context);
//                                 },
//                                 child: const Text("Close"),
//                               ),
//                             ],
//                           ),
//                         );
//                       }
//                     },
//                   );
//                 }
//                 return SizedBox(
//                   height: 350,
//                   width: 300,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       const Text(
//                         'Your QPC QR Code:',
//                         style: TextStyle(fontSize: 16),
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         StaticData.user.qrypticPhrase.toString(),
//                         style: const TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 16),
//                       QrImageView(
//                         data: StaticData.user.qrypticPhrase.toString(),
//                         backgroundColor: Colors.white,
//                         size: 200.0,
//                       ),
//                       const SizedBox(height: 16),
//                     ],
//                   ),
//                 );
//               }
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             }),
//       ),
//     );
//   }
// }

// // StatefulWidget to handle the dialog state
// class LoadingDialogContent extends StatefulWidget {
//   final String connectedQPC;
//   final String userName;
//   Map<String, String> data;
//   Function setStateCallback;

//   LoadingDialogContent(this.connectedQPC, this.userName, this.setStateCallback,
//       [this.data = const {}]);

//   @override
//   _LoadingDialogContentState createState() => _LoadingDialogContentState();
// }

// class _LoadingDialogContentState extends State<LoadingDialogContent> {
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();

//     // Simulate the delay of 5 seconds for loading
//     Timer(const Duration(seconds: 1), () {
//       setState(() {
//         isLoading = false; // Change loading to false after 5 seconds
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Loading spinner
//           isLoading
//               ? const Padding(
//                   padding: EdgeInsets.all(20.0),
//                   child: SpinKitFadingCube(
//                     color: Colors.white,
//                     size: 40.0,
//                   ),
//                 )
// : Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       widget.data.containsKey("error")
//           ? const Icon(Icons.error, color: Colors.red, size: 40)
//           : const Icon(Icons.check_circle,
//               color: Colors.green, size: 40),
//       const SizedBox(height: 10),
//       widget.data.containsKey('message')
//           ? Text(
//               widget.data['message'] ?? "",
//               style: const TextStyle(
//                   fontSize: 18, fontWeight: FontWeight.bold),
//             )
//           : widget.data.containsKey("error")
//               ? Text(
//                   widget.data['error'] ?? "",
//                   style: const TextStyle(
//                       fontSize: 18, fontWeight: FontWeight.bold),
//                 )
//               : Text(
//                   'Connected with ${widget.userName}',
//                   style: const TextStyle(
//                       fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//       const SizedBox(height: 8),
//       widget.data.containsKey("message") ||
//               widget.data.containsKey("error")
//           ? Container()
//           : Text(
//               'QPC: ${widget.connectedQPC}',
//               style: const TextStyle(
//                   fontSize: 16, color: Colors.grey),
//             ),
//     ],
//   ),
//           const SizedBox(height: 20),
//           // Adding a button to close the dialog
//           if (!isLoading)
//             ElevatedButton(
//               onPressed: () {
//                 widget.setStateCallback();
//                 Navigator.pop(context); // Close the dialog
//               },
//               child: const Text("OK"),
//             ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qryptic/helper/database.dart';
import 'package:qryptic/model/QrypticUser.dart';
import 'package:qryptic/widget/FuturisticToast.dart';

class QPCScreen extends StatefulWidget {
  @override
  _QPCScreenState createState() => _QPCScreenState();
}

class _QPCScreenState extends State<QPCScreen> {
  String scannedQPC = '';
  bool isPopupOpen = false;
  MobileScannerController _scannerController = MobileScannerController();
  bool isScannedAlready = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void setStateCallback() {
    setState(() {
      isScannedAlready = false;
      scannedQPC = '';
    });
  }

  void _showLoadingDialog(BuildContext context, String data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: _LoadingDialogContent(c, data, setStateCallback),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("QPC Scanner",
            style: TextStyle(
              color: Colors.cyanAccent.withOpacity(0.8),
              shadows: [
                Shadow(blurRadius: 10, color: Colors.cyanAccent),
              ],
            )),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildScanner(),
          Positioned(bottom: 20, left: 0, right: 0, child: _buildGlowEffect()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => _showGeneratedQRCode(context),
        child: Icon(Icons.qr_code, color: Colors.white),
      ),
    );
  }

  Widget _buildScanner() {
    return MobileScanner(
      controller: _scannerController,
      onDetect: (barcode) async {
        if (isScannedAlready) {
          return;
        }
        scannedQPC = scannedQPC = {
              for (var element in barcode.raw!
                  .toString()
                  .replaceAll(RegExp(r'[\[\]{}]'), '')
                  .split(",")
                  .where(
                    (element) => element.contains(": "),
                  ))
                element.split(": ")[0].trim():
                    element.split(": ").sublist(1).join(": ").trim()
            }['displayValue'] ??
            "";
        if (scannedQPC.isNotEmpty && !isScannedAlready) {
          setState(() => isScannedAlready = true);
          _showLoadingDialog(context, scannedQPC);
        }
      },
    );
  }

  Widget _buildGlowEffect() {
    return Center(
      child: SpinKitRipple(
        color: Colors.blueAccent,
        size: 150.0,
      ),
    );
  }

  void _showGeneratedQRCode(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7), // Dim background for focus
      builder: (c) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor:
            Colors.transparent, // Transparent background for glass effect
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                padding: EdgeInsets.all(20),
                decoration: _futuristicBoxDecoration2(),
                child: Center(
                  child: SpinKitRipple(
                    color: Colors.cyanAccent.withOpacity(0.8),
                    size: 50,
                  ),
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (!snapshot.hasData) {
                Navigator.pop(c);
              }

              QrypticUser _user = QrypticUser.fromMap(snapshot.data!.data()!);

              if (_user.qkdSessionId.isNotEmpty) {
                if (!_user.isSessionFinished) {
                  return FutureBuilder(
                      future: joinQKDSession(_user.qkdSessionId),
                      builder: (context, snapshot) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: _futuristicBoxDecoration2(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Connecting...",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.cyanAccent,
                                  shadows: [
                                    Shadow(
                                        blurRadius: 10,
                                        color: Colors.cyanAccent),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                              SpinKitSpinningLines(
                                color: Colors.cyanAccent.withOpacity(0.9),
                                size: 60,
                                lineWidth: 4,
                              ),
                              SizedBox(height: 16),
                            ],
                          ),
                        );
                      });
                } else {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: _futuristicBoxDecoration2(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset('assets/animations/success.json',
                            width: 80),
                        const SizedBox(height: 10),
                        Text(
                          'Connected Successfully.',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            FuturisticToast.show(context,
                                message: "Connected Successfully");
                            Navigator.pop(c);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                            foregroundColor: Colors.cyanAccent,
                            shadowColor: Colors.cyanAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: Text(
                            "Close",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              } else {
                return Container(
                  padding: EdgeInsets.all(24),
                  decoration: _futuristicBoxDecoration1(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Your QPC",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyanAccent,
                          shadows: [
                            Shadow(blurRadius: 10, color: Colors.cyanAccent)
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        _user.qrypticPhrase ?? "",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.cyanAccent, width: 2),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 3,
                            )
                          ],
                        ),
                        child: QrImageView(
                          data: _user.qrypticPhrase ?? "",
                          size: 200.0,
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.cyanAccent,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                          foregroundColor: Colors.cyanAccent,
                          shadowColor: Colors.cyanAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          "Close",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              }
            } else {
              FuturisticToast.show(context,
                  message: "Error Generating QR Code...");
              Navigator.pop(c);
              return Container();
            }
            return Container();
          },
        ),
      ),
    );
  }

  BoxDecoration _futuristicBoxDecoration1() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Colors.black.withOpacity(0.7),
      boxShadow: [
        BoxShadow(
          color: Colors.cyanAccent.withOpacity(0.5),
          blurRadius: 15,
          spreadRadius: 3,
        )
      ],
      border: Border.all(color: Colors.cyanAccent.withOpacity(0.6), width: 1.5),
    );
  }
}

class _LoadingDialogContent extends StatelessWidget {
  final String scannedQPC;
  final BuildContext c;
  final Function setStateCallback;

  _LoadingDialogContent(this.c, this.scannedQPC, this.setStateCallback);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: connectUserViaQR(scannedQPC),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: _futuristicBoxDecoration2(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Connecting...",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyanAccent,
                      shadows: [
                        Shadow(blurRadius: 10, color: Colors.cyanAccent),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  SpinKitSpinningLines(
                    color: Colors.cyanAccent.withOpacity(0.9),
                    size: 60,
                    lineWidth: 4,
                  ),
                  SizedBox(height: 16),
                ],
              ),
            );
          } else {
            if (!snapshot.hasData || snapshot.data == null) {
              FuturisticToast.show(context, message: "Error Connecting...");
              Navigator.of(c).pop();
              return Container();
            } else {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: _futuristicBoxDecoration2(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    snapshot.data!.containsKey("error")
                        ? Lottie.asset('assets/animations/error.json',
                            width: 80)
                        : Lottie.asset('assets/animations/success.json',
                            width: 80),
                    const SizedBox(height: 10),
                    snapshot.data!.containsKey('message')
                        ? Text(
                            snapshot.data!['message'] ?? "",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          )
                        : snapshot.data!.containsKey("error")
                            ? Text(
                                snapshot.data!['error'] ?? "",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              )
                            : Text(
                                'Connected with $scannedQPC',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setStateCallback();
                        Navigator.pop(c);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                        foregroundColor: Colors.cyanAccent,
                        shadowColor: Colors.cyanAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        "Close",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }
          }
        });
  }
}

BoxDecoration _futuristicBoxDecoration2() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    color: Colors.black.withOpacity(0.6),
    boxShadow: [
      BoxShadow(
        color: Colors.cyanAccent.withOpacity(0.5),
        blurRadius: 20,
        spreadRadius: 5,
      )
    ],
    border: Border.all(color: Colors.cyanAccent.withOpacity(0.8), width: 2),
  );
}
