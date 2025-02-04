import 'package:flutter/material.dart';

class FuturisticTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Function(String) onChange;
  final bool isObscure;

  const FuturisticTextField({
    Key? key,
    required this.label,
    required this.controller,
    required this.isObscure,
    required this.onChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: TextStyle(color: Colors.white, fontSize: 18),
        cursorColor: Colors.cyanAccent,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.black.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          labelText: label,
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
        ),
        onChanged: onChange,
      ),
    );
  }
}
