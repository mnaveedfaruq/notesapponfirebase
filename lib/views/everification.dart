import 'package:firebase_auth/firebase_auth.dart';
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
              const Text('please verfy your email here'),
              const SizedBox(
                height: 30,
              ),
              TextButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    await user?.sendEmailVerification();
                  },
                  child: const Text('verify my Email'))
            ],
          ),
        ));
  }
}
