import 'package:firebasenotesapp/constant/routes.dart';
import 'package:firebasenotesapp/sevices/auth/auth_service.dart';
import 'package:flutter/material.dart';

class EmailVerrificationPage extends StatefulWidget {
  const EmailVerrificationPage({super.key});

  @override
  State<EmailVerrificationPage> createState() => _EmailVerrificationPageState();
}

class _EmailVerrificationPageState extends State<EmailVerrificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('verify your email'),
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              const Text(
                  'Email verification has been sent to your Email Address'),
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                        onPressed: () async {
                          await AuthService.firebase().sendEmailVerification();
                        },
                        child: const Text('resend Verification')),
                  ),
                  Expanded(
                    child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            loginRoute,
                            (route) => false,
                          );
                        },
                        child: const Text('Go to login')),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
