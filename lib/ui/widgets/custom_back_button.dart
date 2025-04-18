import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBackButton extends StatelessWidget {
  final Color color;
  final String route;

  const CustomBackButton({
    Key? key,
    required this.color,
    required this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: color),
      onPressed: () => context.go(route), // Navigate to the specified route
    );
  }
  
}