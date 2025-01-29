import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Import mobile_scanner
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qryptic/helper/StaticData.dart';
import 'package:qryptic/helper/database.dart';
import 'package:qryptic/widget/ScannedBarcodeLabel.dart';

class QPCScreen extends StatefulWidget {
  @override
  _QPCScreenState createState() => _QPCScreenState();
}

class _QPCScreenState extends State<QPCScreen> {
  final TextEditingController _qpcController = TextEditingController();
  // String scannedQPC = '';
  String scannedQPC = ''; // Replace with actual user QPC
  String userName = '';
  String connectedQPC = '';
  bool isLoading = true;
  bool isPopupOpen = false;

  MobileScannerController _scannerController =
      MobileScannerController(); // MobileScanner controller

  @override
  void dispose() {
    _scannerController.dispose(); // Dispose of the scanner controller
    super.dispose();
  }

  void setStateCallback() {
    setState(() {
      isPopupOpen = false;
    });
  }

  void _showLoadingDialog(BuildContext context,
      [Map<String, String> data = const {}]) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog by tapping outside
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: LoadingDialogContent(
            connectedQPC,
            userName,
            setStateCallback,
            data,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QPC Screen - Share and Connect"),
      ),
      body: Column(
        children: [
          // QR Scanner takes 3/4 of the screen
          Expanded(
            flex: 3,
            child: MobileScanner(
              overlayBuilder: (context, constraints) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ScannedBarcodeLabel(
                        barcodes: _scannerController.barcodes),
                  ),
                );
              },
              controller: _scannerController,
              onDetect: (barcode) async {
                setState(() {
                  scannedQPC = barcode.raw!
                      .toString()
                      .replaceAll(RegExp(r'[\[\]{}]'), '')
                      .split(",")
                      .last
                      .split(":")
                      .last;
                });
                if (scannedQPC.isNotEmpty) {
                  final data = await connectUserViaQR(scannedQPC.trim());
                  if (data.isNotEmpty) {
                    if (data.containsKey("error") ||
                        data.containsKey('message')) {
                      if (!isPopupOpen) {
                        _showLoadingDialog(context, data);
                      }
                      setState(() {
                        isPopupOpen = true;
                      });
                    } else {
                      setState(() {
                        userName = data["name"]!;
                        connectedQPC = data["QPC"]!;
                      });
                      if (!isPopupOpen) {
                        _showLoadingDialog(context);
                      }
                      setState(() {
                        isPopupOpen = true;
                      });
                    }
                  }
                }
              },
            ),
          ),

          // Manual QPC entry takes 1/4 of the screen
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _qpcController,
                    decoration: const InputDecoration(
                      labelText: "Enter QPC",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final data =
                            await connectUserViaQR(_qpcController.text.trim());
                        if (data.isNotEmpty) {
                          if (data.containsKey("error") ||
                              data.containsKey('message')) {
                            if (!isPopupOpen) {
                              _showLoadingDialog(context, data);
                            }
                            setState(() {
                              isPopupOpen = true;
                            });
                          } else {
                            setState(() {
                              userName = data["name"]!;
                              connectedQPC = data["QPC"]!;
                            });
                            if (!isPopupOpen) {
                              _showLoadingDialog(context);
                            }
                            setState(() {
                              isPopupOpen = true;
                            });
                          }
                        }
                      },
                      child: const Text(
                        "Connect",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showGeneratedQRCode(context);
        },
        child: const Icon(Icons.qr_code),
        tooltip: 'Show Generated QR Code',
      ),
    );
  }

  // Function to show the generated QR code in a dialog
  void _showGeneratedQRCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          height: 350,
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Your QPC QR Code:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                StaticData.user.qrypticPhrase.toString(),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              QrImageView(
                data: StaticData.user.qrypticPhrase.toString(),
                backgroundColor: Colors.white,
                size: 200.0,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// StatefulWidget to handle the dialog state
class LoadingDialogContent extends StatefulWidget {
  final String connectedQPC;
  final String userName;
  Map<String, String> data;
  Function setStateCallback;

  LoadingDialogContent(this.connectedQPC, this.userName, this.setStateCallback,
      [this.data = const {}]);

  @override
  _LoadingDialogContentState createState() => _LoadingDialogContentState();
}

class _LoadingDialogContentState extends State<LoadingDialogContent> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // Simulate the delay of 5 seconds for loading
    Timer(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false; // Change loading to false after 5 seconds
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Loading spinner
          isLoading
              ? const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: SpinKitFadingCube(
                    color: Colors.white,
                    size: 40.0,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.data.containsKey("error")
                        ? const Icon(Icons.error, color: Colors.red, size: 40)
                        : const Icon(Icons.check_circle,
                            color: Colors.green, size: 40),
                    const SizedBox(height: 10),
                    widget.data.containsKey('message')
                        ? Text(
                            widget.data['message'] ?? "",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          )
                        : widget.data.containsKey("error")
                            ? Text(
                                widget.data['error'] ?? "",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              )
                            : Text(
                                'Connected with ${widget.userName}',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                    const SizedBox(height: 8),
                    widget.data.containsKey("message") ||
                            widget.data.containsKey("error")
                        ? Container()
                        : Text(
                            'QPC: ${widget.connectedQPC}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                  ],
                ),
          const SizedBox(height: 20),
          // Adding a button to close the dialog
          if (!isLoading)
            ElevatedButton(
              onPressed: () {
                widget.setStateCallback();
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("OK"),
            ),
        ],
      ),
    );
  }
}
