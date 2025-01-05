import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebasenotesapp/firebase_options.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('HomePage'),
        ),
        body: FutureBuilder(
          future: Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform),
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
                final user = FirebaseAuth.instance.currentUser;
                if (user?.emailVerified ?? false) {
                  debugPrint('email is not verified');
                } else {
                  debugPrint('email is verified');
                }
                return const Text('done');
              default:
                return const Text('loading ..');
            }
          },
        ));
  }
}
