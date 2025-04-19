import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/services/auth/firebase_auth_methods.dart';
import 'package:frontend/routing/routes.dart';
import 'package:frontend/ui/widgets/social_login_buttons.dart';
import 'package:frontend/ui/widgets/custom_back_button.dart';

import 'package:frontend/utils/palette.dart';


class SignInScreen extends StatefulWidget {
  // static String routeName = '/signin-email-password';
  @override
  State<SignInScreen> createState() => _SignUpScreenState();
  const SignInScreen({super.key});
}

class _SignUpScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormFieldState> _emailFieldKey = GlobalKey<FormFieldState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void signInUser() async {
    if (_formKey.currentState!.validate()) {
      context.read<FirebaseAuthMethods>().loginWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
        context: context,
      );
    }
  }

  void forgetPassword() async {
    if (_emailFieldKey.currentState!.validate()) {
      context.read<FirebaseAuthMethods>().resetPassword(
        email: _emailController.text,
        context: context,
      );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      fillColor: Palette.lightGray,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.primaryColor,
      appBar: AppBar(
        backgroundColor: Palette.primaryColor,
        elevation: 0,
        leading: CustomBackButton(
          color: Colors.white, // Set the color of the back button
          route: Routes.welcome, // Navigate back to the welcome screen
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Palette.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Palette.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    key: _emailFieldKey,
                    controller: _emailController,
                    decoration: _inputDecoration("Email"),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter email';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Enter valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _inputDecoration("Password"),
                    validator:
                        (value) =>
                            (value == null || value.length < 6)
                                ? 'Password too short'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap:
                            () => context
                                .read<FirebaseAuthMethods>()
                                .resetPassword(
                                  email: _emailController.text,
                                  context: context,
                                ),
                        child: const Text(
                          "Forget Password",
                          style: TextStyle(
                            color: Palette.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // SignIn Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: signInUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Palette.orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Palette.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("or continue with"),
                  const SizedBox(height: 10),

                  // Social Buttons
                  const SocialLoginButtons(),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () => context.go(Routes.signUp),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
