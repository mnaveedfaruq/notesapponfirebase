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
                                      email: email, password: password)
                                  .then((value) {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/notesview/', (route) => false);
                              });
                              console.log('user credentials $userCredentials');
                              console.log(
                                  'current user is ${FirebaseAuth.instance.currentUser.toString()}');
                            } on FirebaseAuthException catch (E) {
                              console.log(E.code.toString());
                              if (E.code == 'user-not-found') {
                                console.log('user not found');
                              } else if (E.code == 'wrong-password') {
                                console.log('Wrong Password');
                              } else if (E.code == 'invalid-credential') {
                                console.log('credentials are invalid');
                              } else {
                                console.log('got error');
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
