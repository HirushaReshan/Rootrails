import 'package:flutter/material.dart';

class TypeSelector extends StatelessWidget {
  final String text;
  final Function()? onTap;
  const TypeSelector({
    super.key,
    required this.text,
    required this.onTap,});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Center(
            child: Text(text, style: TextStyle(color: Colors.grey.shade400)),
          ),
        ),
      ),
    );
  }
}
