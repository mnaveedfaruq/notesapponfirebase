import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebasenotesapp/constant/routes.dart';
import 'package:firebasenotesapp/firebase_options.dart';
import 'package:firebasenotesapp/widgets/messages.dart';
import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});
  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
          title: const Text('Signup page'),
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
                                await FirebaseAuth.instance
                                    .createUserWithEmailAndPassword(
                                        email: email, password: password)
                                    .then((value) async {
                                  await FirebaseAuth.instance.currentUser!
                                      .sendEmailVerification();
                                  Navigator.of(context)
                                      .pushNamed(emailVerificationRoute);
                                });
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'weak-password') {
                                  Message().show(context, 'password is weak');
                                  _passowrd.text = '';
                                }
                                if (e.code == 'invalid-email') {
                                  Message().show(context, 'invalid email');
                                  _email.text = '';
                                }
                                Message()
                                    .show(context, 'auth exception ${e.code}');
                              } catch (e) {
                                // ignore: use_build_context_synchronously
                                Message().show(context, e.toString());
                              }
                            },
                            child: const Text('Register'))
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
                      .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                },
                child: const Text('Already Registered? go to Login'))
          ],
        ));
  }
}
