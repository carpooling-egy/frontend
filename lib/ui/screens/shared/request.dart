// ride_screen.dart
import 'package:flutter/material.dart';

class RideScreen extends StatelessWidget {
  final String title;
  final String message;

  const RideScreen({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(message, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
