import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String buttonName;

  const RoundedButton({Key? key, required this.buttonName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.blueAccent,
      ),
      child: TextButton(
        onPressed: () {},
        child: Text(
          buttonName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
