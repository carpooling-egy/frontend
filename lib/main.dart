import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/services/auth/firebase_auth_methods.dart';
import 'package:frontend/routing/router.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        StreamProvider(
          create: (context) => context.read<FirebaseAuthMethods>().authState,
          initialData: null,
        ),
      ],
      child: MaterialApp.router(
        title: 'Flutter App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal), 
          useMaterial3: true,
        ),
        routerConfig: router(FirebaseAuth.instance),
      )
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
