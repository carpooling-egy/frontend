import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/services/auth/firebase_auth_methods.dart';
import 'package:frontend/routing/routes.dart';

import 'package:frontend/config/assets.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Removes the default back button
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Profile Picture
            GestureDetector(
              onTap: () => context.go(Routes.profile),
              child: const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(
                  AppAssets.avatar,
                ), // Replace with your image
              ),
            ),

            // Notification Icon with Badge
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.black),
                  onPressed: () {
                    // Notification logic
                  },
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Buttons Section
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.read<FirebaseAuthMethods>().signOut(context);
                },
                child: const Text('Sign Out'),
              ),
              const SizedBox(width: 10), // Add spacing between buttons
              ElevatedButton(
                onPressed: () {
                  context.read<FirebaseAuthMethods>().deleteAccount(context);
                },
                child: const Text('Delete Account'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main Content Section
          const Center(
            child: Text(
              'Home Screen Content',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}