import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/utils/show_snackbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:frontend/services/api/profile_service.dart';


class FirebaseAuthMethods {
  final FirebaseAuth _auth;
  FirebaseAuthMethods(this._auth);

  // FOR EVERY FUNCTION HERE
  // POP THE ROUTE USING: Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);

  // GET USER DATA
  // using null check operator since this method should be called only
  // when the user is logged in
  User get user => _auth.currentUser!;

  // STATE PERSISTENCE STREAM
  Stream<User?> get authState => FirebaseAuth.instance.authStateChanges();
  // OTHER WAYS (depends on use case):
  // Stream get authState => FirebaseAuth.instance.userChanges();
  // Stream get authState => FirebaseAuth.instance.idTokenChanges();
  // KNOW MORE ABOUT THEM HERE: https://firebase.flutter.dev/docs/auth/start#auth-state

  // Get the current user
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<String?> getUserJWT() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  // Get auth token
  Future<String?> getAuthToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  // EMAIL SIGN UP
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create profile after successful signup with valid data
      if (userCredential.user != null) {
        final profileService = Provider.of<ProfileService>(context, listen: false);
        try {
          // Get username from email (part before @)
          final username = email.split('@')[0];
          // Create initial profile with valid data
          await profileService.createProfile(
            userId: userCredential.user!.uid,  // Use Firebase UID as userId
            firstName: username,
            lastName: 'User',
            email: userCredential.user!.email!,
            phoneNumber: '+1234567890', // Default valid phone number
            gender: 'OTHER',
          );
          print('Profile created successfully for new user');
        } catch (e) {
          print('Error creating profile: $e');
          // Don't throw here, as the user is already created
        }
      }
      
      await sendEmailVerification(context);
    } on FirebaseAuthException catch (e) {
      // if you want to display your own custom error message
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      showSnackBar(
        context,
        e.message!,
      ); // Displaying the usual firebase error message
    }
  }

  // EMAIL LOGIN
  Future<void> loginWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create profile if it doesn't exist
      if (userCredential.user != null) {
        final profileService = Provider.of<ProfileService>(context, listen: false);
        try {
          // Try to get the profile using the userId
          await profileService.getProfile(userCredential.user!.uid);
        } catch (e) {
          // Get username from email (part before @)
          final username = email.split('@')[0];
          // If profile doesn't exist, create it with valid data
          await profileService.createProfile(
            userId: userCredential.user!.uid,  // Use Firebase UID as userId
            firstName: username,
            lastName: 'User',
            email: userCredential.user!.email!,
            phoneNumber: '+1234567890', // Default valid phone number
            gender: 'OTHER',
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      _handleError(e, context);
    }
  }

  // EMAIL VERIFICATION
  Future<void> sendEmailVerification(BuildContext context) async {
    try {
      _auth.currentUser!.sendEmailVerification();
      showSnackBar(context, 'Email verification sent!');
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!); // Display error message
    }
  }

  // GOOGLE SIGN IN
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();

        googleProvider.addScope(
          'https://www.googleapis.com/auth/contacts.readonly',
        );

        await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

        final GoogleSignInAuthentication? googleAuth =
            await googleUser?.authentication;

        if (googleAuth?.accessToken != null && googleAuth?.idToken != null) {
          // Create a new credential
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth?.accessToken,
            idToken: googleAuth?.idToken,
          );
          UserCredential userCredential = await _auth.signInWithCredential(
            credential,
          );

          // Create profile if it doesn't exist
          if (userCredential.user != null) {
            final profileService = Provider.of<ProfileService>(context, listen: false);
            try {
              // Try to get the profile using the userId
              await profileService.getProfile(userCredential.user!.uid);
            } catch (e) {
              // Get username from email (part before @)
              final username = userCredential.user!.email!.split('@')[0];
              // If profile doesn't exist, create it with valid data
              await profileService.createProfile(
                userId: userCredential.user!.uid,  // Use Firebase UID as userId
                firstName: username,
                lastName: userCredential.user!.displayName?.split(' ').last ?? 'User',
                email: userCredential.user!.email!,
                phoneNumber: '+1234567890', // Default valid phone number
                gender: 'OTHER',
              );
            }
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!); // Displaying the error message
    }
  }

  // ANONYMOUS SIGN IN
  Future<void> signInAnonymously(BuildContext context) async {
    try {
      await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!); // Displaying the error message
    }
  }

  // FACEBOOK SIGN IN
  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

      final userCredential = await _auth.signInWithCredential(facebookAuthCredential);
      
      // Create profile if it doesn't exist
      if (userCredential.user != null) {
        final profileService = Provider.of<ProfileService>(context, listen: false);
        try {
          // Try to get the profile using the userId
          await profileService.getProfile(userCredential.user!.uid);
        } catch (e) {
          // Get username from email (part before @)
          final username = userCredential.user!.email!.split('@')[0];
          // If profile doesn't exist, create it with valid data
          await profileService.createProfile(
            userId: userCredential.user!.uid,  // Use Firebase UID as userId
            firstName: username,
            lastName: userCredential.user!.displayName?.split(' ').last ?? 'User',
            email: userCredential.user!.email!,
            phoneNumber: '+1234567890', // Default valid phone number
            gender: 'OTHER',
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!); // Displaying the error message
    }
  }

  // FORGOT PASSWORD
  Future<void> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      showSnackBar(context, 'Password reset email sent!');
    } on FirebaseAuthException catch (e) {
      _handleError(e, context);
    }
  }

  // SIGN OUT
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      _handleError(e, context);
    }
  }

  // DELETE ACCOUNT
  Future<void> deleteAccount(BuildContext context) async {
    try {
      await _auth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      _handleError(e, context);
      // if an error of requires-recent-login is thrown, make sure to log
      // in user again and then delete account.
    }
  }

  void _handleError(FirebaseAuthException e, BuildContext context) {
    String message = 'An error occurred';
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found with this email';
        break;
      case 'wrong-password':
        message = 'Wrong password provided';
        break;
      case 'email-already-in-use':
        message = 'Email already in use';
        break;
      case 'weak-password':
        message = 'Password is too weak';
        break;
      case 'invalid-email':
        message = 'Email is invalid';
        break;
      case 'user-disabled':
        message = 'User account has been disabled';
        break;
      case 'too-many-requests':
        message = 'Too many requests. Try again later';
        break;
      case 'operation-not-allowed':
        message = 'Operation not allowed';
        break;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
