import 'package:flutter/material.dart';
import '../../utils/palette.dart';

class AuthForm extends StatelessWidget {
  final String title;
  final List<TextFormField> fields;
  final String buttonText;
  final VoidCallback onSubmit;
  final Widget? extraContent; // For social login buttons

  const AuthForm({
    required this.title,
    required this.fields,
    required this.buttonText,
    required this.onSubmit,
    this.extraContent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Palette.white),
        ),
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Palette.lightGray,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              ...fields,
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette.orange,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 100),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(buttonText, style: TextStyle(color: Palette.white, fontSize: 18)),
              ),
            ],
          ),
        ),
        if (extraContent != null) ...[
          SizedBox(height: 15),
          extraContent!,
        ],
      ],
    );
  }
}
