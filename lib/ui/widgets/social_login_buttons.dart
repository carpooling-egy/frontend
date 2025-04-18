import 'package:flutter/material.dart';
import 'package:frontend/utils/palette.dart';
import 'package:frontend/services/auth/firebase_auth_methods.dart';
import 'package:provider/provider.dart';

import 'package:frontend/config/assets.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialButton(
          AppAssets.googleIcon,
          onTap:
              () =>
                  context.read<FirebaseAuthMethods>().signInWithGoogle(context),
        ),
        const SizedBox(width: 20),
        _socialButton(
          AppAssets.facebookIcon,
          onTap:
              () => context.read<FirebaseAuthMethods>().signInWithFacebook(
                context,
              ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _socialButton(String assetPath, {Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Palette.white,
        backgroundImage: AssetImage(assetPath),
      ),
    );
  }
}
