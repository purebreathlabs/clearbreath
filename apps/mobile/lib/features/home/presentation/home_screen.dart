import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'ClearBreath',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
