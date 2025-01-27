import 'dart:developer' as console show log;

import 'package:firebasenotesapp/sevices/auth/auth_service.dart';
import 'package:firebasenotesapp/views/everification.dart';
import 'package:firebasenotesapp/views/loginview.dart';
import 'package:firebasenotesapp/views/notesview.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('HomePage'),
        ),
        body: FutureBuilder(
          future: AuthService.firebase().initialize(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                //this code has been commented because
                // email verification not worked
                // final user = FirebaseAuth.instance.currentUser;
                // if (user?.emailVerified ?? false) {
                //   return const Text('done');
                // } else {
                //   return const EmailVerrificationPage();
                // }
                final user = AuthService.firebase().currentUser;

                if (user?.isEmailVerified ?? false) {
                  console.log("email verified");

                  return const EmailVerrificationPage();
                } else {
                  console.log("email not verified");
                  return const NotesView();
                }
              default:
                return const LoginView();
            }
          },
        ));
  }
}
