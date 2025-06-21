import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import '../ui/screens/welcome.dart';
import '../ui/screens/home.dart';
import '../ui/screens/signin.dart';
import '../ui/screens/signup.dart';
import '../ui/screens/profile.dart';
import '../ui/screens/request_ride.dart';
import '../ui/screens/offer_ride.dart';
import '../ui/screens/notifications.dart';


GoRouter router(FirebaseAuth auth) {
  return GoRouter(
    initialLocation: Routes.welcome,
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(auth.authStateChanges()), // Listen to auth state changes
    redirect: (context, state) {
      final loggedIn = auth.currentUser != null;
      final loggingIn = state.matchedLocation == Routes.signin ||
          state.matchedLocation == Routes.signup;
      final inWelcomeScreen = state.matchedLocation == Routes.welcome;

      if (!loggedIn && !loggingIn) {
        debugPrint('Redirecting to welcome screen');
        return Routes.welcome; // Redirect to welcome if not logged in
      }

      if (loggedIn && (loggingIn || inWelcomeScreen)) {
        debugPrint('Redirecting to home screen');
        return Routes.home; // Redirect to home if logged in and not already on the home screen
      }

      return null; // No redirection needed
    },
    routes: [
      GoRoute(
        path: Routes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: Routes.signin,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: Routes.signup,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: Routes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: Routes.requestRide,
        builder: (context, state) => const RequestRideScreen(),
      ),
      GoRoute(
        path: Routes.offerRide,
        builder: (context, state) => const OfferRideScreen(),
      ),
      GoRoute(
        path: Routes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}