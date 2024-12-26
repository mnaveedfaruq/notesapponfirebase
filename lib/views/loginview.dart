import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebasenotesapp/firebase_options.dart';
import 'package:firebasenotesapp/widgets/messages.dart';
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
        body: FutureBuilder(
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
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: email, password: password)
                                .then((value) {
                              Message().show(context, 'Logged in');
                            });
                          } on FirebaseAuthException catch (E) {
                            debugPrint(E.code);
                            if (E.code == 'user-not-found') {
                              Message().show(context, 'User-not-found');
                            } else if (E.code == 'wrong-password') {
                              Message().show(context, 'Wrong Password');
                            } else if (E.code == 'invalid-credential') {
                              Message()
                                  .show(context, 'credentials are invalid');
                            } else {
                              Message().show(context, 'got error ${E.code} ');
                            }
                            _email.text = '';
                            _passowrd.text = '';
                          } catch (e) {
                            print(e.runtimeType);
                            print(e);
                          }
                        },
                        child: const Text('Login'))
                  ],
                );
              default:
                return const Text('Loading...');
            }
          },
        ));
  }
}
