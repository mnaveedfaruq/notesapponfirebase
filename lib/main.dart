import 'package:firebase_core/firebase_core.dart';
import 'package:firebasenotesapp/constant/routes.dart';
import 'package:firebasenotesapp/firebase_options.dart';
import 'package:firebasenotesapp/views/decideview.dart';
import 'package:firebasenotesapp/views/everification.dart';
import 'package:firebasenotesapp/views/homepage.dart';
import 'package:firebasenotesapp/views/loginview.dart';
import 'package:firebasenotesapp/views/notesview.dart';
import 'package:firebasenotesapp/views/registerview.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ViewDeciderpage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        '/home/': (context) => const HomePage(),
        emailVerificationRoute: (context) => const EmailVerrificationPage(),
        notesViewRoute: (context) => const NotesView()
      },
    );
  }
}
