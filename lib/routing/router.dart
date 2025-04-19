import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';  
import 'package:firebase_auth/firebase_auth.dart';

import 'package:frontend/routing/routes.dart';
import 'package:frontend/ui/screens/home.dart';
import 'package:frontend/ui/screens/request_ride.dart';
import 'package:frontend/ui/screens/offer_ride.dart';
import 'package:frontend/ui/screens/welcome.dart';
import 'package:frontend/ui/screens/signin.dart';
import 'package:frontend/ui/screens/signup.dart';
import 'package:frontend/ui/screens/profile.dart';


GoRouter createRouter(FirebaseAuth auth) {
  return GoRouter(
    initialLocation: Routes.welcome,
    routes: [
      GoRoute(
        path: Routes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: Routes.requestRide,
        name: 'requestRide',
        builder: (context, state) => const RequestRideScreen(),
      ),
      GoRoute(
        path: Routes.offerRide,
        name: 'offerRide',
        builder: (context, state) => const OfferRideScreen(),
      ),
      GoRoute(
        path: Routes.welcome,
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: Routes.signIn,
        name: 'signIn',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: Routes.signUp,
        name: 'signUp',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: Routes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = auth.currentUser != null;
      final isAuthRoute = state.matchedLocation == Routes.signIn || state.matchedLocation == Routes.signUp;

      if (!isLoggedIn && !isAuthRoute) return Routes.welcome;
      if (isLoggedIn && isAuthRoute) return Routes.home;
      return null;
    },
  );
}
