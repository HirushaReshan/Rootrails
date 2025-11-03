import 'package:flutter/material.dart';

// Define the custom fill color used in the Sign Up design
const Color kInputFillColor = Color(0xFFF0F0F0); // Light grey fill for inputs

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final bool enabled;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.enabled = true,
    this.suffixIcon,
  });

  // Define a constant radius for the highly rounded corners
  static const double kTextFieldRadius = 50.0;

  // Define a transparent border style to remove the visible outline
  final InputBorder kNoInputBorder = const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(kTextFieldRadius)),
    borderSide: BorderSide(
      color: Colors.transparent, // Making the border transparent
      width: 0,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,

        hintStyle: const TextStyle(color: Colors.grey),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 25,
        ),

        border: kNoInputBorder,
        enabledBorder: kNoInputBorder,
        focusedBorder: kNoInputBorder,
        errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(kTextFieldRadius),
          ),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(kTextFieldRadius),
          ),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2.0,
          ),
        ),

        fillColor: enabled ? kInputFillColor : Colors.grey.shade100,
        filled: true,
      ),
    );
  }
}
