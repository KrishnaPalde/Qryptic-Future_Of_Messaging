import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class FuturisticButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String buttonText;

  const FuturisticButton({
    Key? key,
    required this.isLoading,
    required this.onPressed,
    required this.buttonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
      child: Center(
        child: Container(
          child: GestureDetector(
            onTap: onPressed,
            child: MouseRegion(
              onEnter: (_) => onPressed(),
              onExit: (_) => onPressed(),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                decoration: BoxDecoration(
                  color: isLoading
                      ? Colors.cyanAccent.withOpacity(0.8)
                      : Colors.cyanAccent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.8),
                      blurRadius: 15,
                      spreadRadius: 3,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                child: Center(
                  child: isLoading
                      ? SpinKitWave(color: Colors.black, size: 24)
                      : Text(
                          buttonText,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
