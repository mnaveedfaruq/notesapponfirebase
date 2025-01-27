import 'dart:developer' as console show log;

import 'package:firebasenotesapp/constant/routes.dart';
import 'package:firebasenotesapp/sevices/auth/auth_exceptions.dart';
import 'package:firebasenotesapp/sevices/auth/auth_service.dart';
import 'package:firebasenotesapp/utilities/show_error_dialog.dart';
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
            future: AuthService.firebase().initialize(),
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
                              final userCredentials =
                                  await AuthService.firebase()
                                      .login(email: email, password: password);
                              final user = AuthService.firebase().currentUser;
                              if (user?.isEmailVerified == true) {
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
                                  'current user is ${AuthService.firebase().currentUser.toString()}');
                            } on UserNotFoundAuthException {
                              showErrorDialog(context, 'user not found');
                            } on WrongPasswordAuthException {
                              showErrorDialog(
                                  context, 'wrong password provided');
                            } on InvlalidCredentialsAuthException {
                              if (context.mounted) {
                                showErrorDialog(context, 'invalid credentials');
                              }
                            } on GenericAuthException {
                              if (context.mounted) {
                                showErrorDialog(
                                    context, 'authentication Error');
                              }
                            } on Exception catch (e) {
                              showErrorDialog(context, '${e.runtimeType}');
                            }
                            _email.text = '';
                            _passowrd.text = '';
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
