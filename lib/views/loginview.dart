import 'dart:developer' as console show log;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebasenotesapp/constant/routes.dart';
import 'package:firebasenotesapp/firebase_options.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _passowrd;
  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _passowrd = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _passowrd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('loginPage'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          FutureBuilder(
            future: Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const CircularProgressIndicator();
                case ConnectionState.done:
                  return Column(
                    children: [
                      TextField(
                        controller: _email,
                        decoration: const InputDecoration(
                            hintText: 'Enter your Email here'),
                        autocorrect: false,
                        enableSuggestions: false,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      TextField(
                        controller: _passowrd,
                        decoration: const InputDecoration(
                            hintText: 'Enter your password here'),
                        obscureText: true,
                        autocorrect: false,
                        enableSuggestions: false,
                      ),
                      TextButton(
                          onPressed: () async {
                            final email = _email.text;
                            final password = _passowrd.text;
                            try {
                              final userCredentials = await FirebaseAuth
                                  .instance
                                  .signInWithEmailAndPassword(
                                      email: email, password: password);
                              final user = FirebaseAuth.instance.currentUser;
                              if (user?.emailVerified == true) {
                                //user email is verified
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  notesViewRoute,
                                  (route) => false,
                                );
                              } else {
                                //user email is not verified
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  emailVerificationRoute,
                                  (route) => false,
                                );
                              }
                              console.log('user credentials $userCredentials');
                              console.log(
                                  'current user is ${FirebaseAuth.instance.currentUser.toString()}');
                            } on FirebaseAuthException catch (E) {
                              console.log(E.code.toString());
                              if (E.code == 'user-not-found') {
                                showErrorDialog(context, 'user not found');
                              }
                              if (E.code == 'wrong-password') {
                                showErrorDialog(
                                    context, 'wrong password provided');
                              }
                              if (E.code == 'invalid-credential') {
                                showErrorDialog(context, 'invalid credentials');
                              } else {
                                showErrorDialog(context, 'got error ${E.code}');
                              }
                              _email.text = '';
                              _passowrd.text = '';
                            } catch (e) {
                              console.log(e.runtimeType.toString());
                              console.log(e.toString());
                            }
                          },
                          child: const Text('Login'))
                    ],
                  );
                default:
                  return const Text('Loading...');
              }
            },
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text('not Registered yet? Register'))
        ],
      ),
    );
  }
}

Future<bool> showmyDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('logout'),
        content: const Text('are you sure you want to log out'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('log out')),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('cancel'))
        ],
      );
    },
  ).then(
    (value) => value ?? false,
  );
}

Future<void> showErrorDialog(
  BuildContext context,
  String message,
) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('An Error Occured'),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'))
        ],
      );
    },
  );
}
