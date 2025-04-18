import 'package:flutter/material.dart';

import 'package:frontend/routing/routes.dart';
import 'package:frontend/ui/widgets/custom_back_button.dart';

import 'package:frontend/utils/palette.dart';

class ProfileScreen extends StatefulWidget {
  static String routeName = '/profile';
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
  const ProfileScreen({Key? key}) : super(key: key);
}


class _ProfileScreenState extends State<ProfileScreen> {

  final _formKey = GlobalKey<FormState>(); // Key to manage the form state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(color: Palette.primaryColor, route: Routes.home),
        title: const Text('Edit profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                // Save profile logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile saved successfully!')),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Assign the form key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              Center(
                child: Stack(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage("lib/assets/image/avatar.png"), // Replace with your image
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white, // White background
                          shape: BoxShape.circle, // Circular shape
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.teal, size: 16),
                          onPressed: () {
                            // Edit profile picture logic
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Name Section
              const Text(
                'Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'First',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Last',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Telephone Section
              const Text(
                'Telephone',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                  // labelText: 'Input',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your telephone number';
                  }
                  if (!RegExp(r'^\d+$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Email Section
              const Text(
                'Email',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                  // labelText: 'Input',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Gender Section
              const Text(
                'Gender',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  // Handle gender selection
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your gender';
                  }
                  return null;
                },
                hint: const Text('Select Gender'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}