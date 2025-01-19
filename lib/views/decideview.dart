import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasenotesapp/views/everification.dart';
import 'package:firebasenotesapp/views/loginview.dart';
import 'package:firebasenotesapp/views/notesview.dart';
import 'package:flutter/material.dart';

class ViewDeciderpage extends StatefulWidget {
  const ViewDeciderpage({super.key});

  @override
  State<ViewDeciderpage> createState() => _ViewDeciderpageState();
}

class _ViewDeciderpageState extends State<ViewDeciderpage> {
  @override
  Widget build(BuildContext context) {
    return getpage(context);
  }
}

Widget getpage(BuildContext context) {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return const LoginView();
  } else if (!user.emailVerified) {
    return const EmailVerrificationPage();
  } else if (user.emailVerified) {
    return const NotesView();
  }
  return const Center(
    child: CircularProgressIndicator(),
  );
}
