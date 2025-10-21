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
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.grey.shade200
                ),
                child: Center(
                  child: Text(text, style: TextStyle(color: Colors.grey.shade400)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
