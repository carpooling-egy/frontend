import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/routing/routes.dart';

import 'package:frontend/config/assets.dart';
import 'package:frontend/utils/palette.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 0,
            child: Image.asset(
              AppAssets.welcomeImage,
              fit: BoxFit.contain,
            ),
          ),
                   
          // Content below the image
          Expanded(
            child: Container(
              width: double.infinity,
              color: Palette.primaryColor,
              padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Book your",
                    style: TextStyle(fontSize: 18, color: Palette.white),
                  ),
                  Text(
                    "Carpool\nNOW",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Palette.white),
                  ),
                  SizedBox(height: 80),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => context.go(Routes.signin),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Palette.accentColor,
                        padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text("Sign In", style: TextStyle(color: Palette.white, fontSize: 18)),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go(Routes.signup),
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: Palette.white, fontSize: 14),
                          children: [
                            TextSpan(
                              text: "Sign up",
                              style: TextStyle(
                                color: Palette.orange, // Orange color
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline, // Underlined
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}