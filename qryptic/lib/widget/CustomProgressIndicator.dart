import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomProgressIndicator {
  static final CustomProgressIndicator _singleton =
      CustomProgressIndicator._internal();
  late BuildContext _context;
  bool isDisplayed = false;

  factory CustomProgressIndicator() {
    return _singleton;
  }

  bool getDisplayStatus() {
    return isDisplayed;
  }

  CustomProgressIndicator._internal();

  show(BuildContext context) {
    if (isDisplayed) {
      return;
    }
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          _context = context;
          isDisplayed = true;
          return WillPopScope(
            onWillPop: () async => false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, top: 16, right: 16),
                    child: SpinKitWave(
                        color: Colors.cyanAccent.withOpacity(0.8), size: 24),
                  ),
                ],
              ),
            ),
          );
        });
  }

  dismiss() {
    if (isDisplayed) {
      Navigator.of(_context).pop();
      isDisplayed = false;
    }
  }
}
