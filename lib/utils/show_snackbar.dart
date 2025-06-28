import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text, {Color? backgroundColor, IconData? icon}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: backgroundColor,
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white),
            SizedBox(width: 12),
          ],
          Expanded(child: Text(text)),
        ],
      ),
    ),
  );
}
