import 'package:flutter/material.dart';
import 'package:frontend/services/iroute_service.dart';
import 'package:frontend/services/valhalla_route_service.dart';
import 'package:frontend/view_models/route_info_viewmodel.dart';
import 'package:frontend/view_models/route_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/config/firebase_options.dart';
import 'package:frontend/services/auth/firebase_auth_methods.dart';
import 'package:frontend/routing/router.dart';
import 'package:frontend/services/api/api_service.dart';
import 'package:frontend/services/api/profile_service.dart';
import 'package:frontend/providers/profile_provider.dart';
import 'package:frontend/providers/ride_provider.dart';
import 'package:frontend/services/api/trip_service.dart';
import 'package:frontend/ui/screens/profile_screen.dart';
import 'package:http/http.dart' as http;

import 'config/env_config.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await EnvConfig.init();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
   @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuthMethods>(
          create: (_) => FirebaseAuthMethods(FirebaseAuth.instance),
        ),
        Provider<ApiService>(
          create: (context) => ApiService(
            http.Client(),
            context.read<FirebaseAuthMethods>(),
          ),
        ),
        Provider<ProfileService>(
          create: (context) => ProfileService(
            context.read<ApiService>(),
          ),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (context) => ProfileProvider(
            context.read<ProfileService>(),
          ),
        ),
        Provider<TripService>(
          create: (context) => TripService(
            context.read<ApiService>(),
          ),
        ),
        ChangeNotifierProvider<RideProvider>(
          create: (context) => RideProvider(
            context.read<TripService>(),
          ),
        ),
        Provider<IRouteService>(create: (_) => ValhallaRouteService()),
        ChangeNotifierProvider<RouteViewModel>(
          create: (context) =>
              RouteViewModel(context.read<IRouteService>()),
        ),
        ChangeNotifierProxyProvider<RouteViewModel, RouteInfoViewModel>(
          create: (_) => RouteInfoViewModel(),
          update: (_, routeVM, infoVM) =>
          infoVM!..updateFromRoute(routeVM.route),
        ),
      ],
      child: MaterialApp.router(
        title: 'Flutter App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        routerConfig: router(FirebaseAuth.instance),
        restorationScopeId: null,
      ),
    );
  }
}
// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final firebaseUser = context.watch<User?>();

//     if (firebaseUser != null) {
//       return const HomeScreen();
//     }
//     return const WelcomeScreen();
//   }
// }
