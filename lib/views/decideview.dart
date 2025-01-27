import 'package:firebasenotesapp/sevices/auth/auth_service.dart';
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
  final user = AuthService.firebase().currentUser;
  if (user == null) {
    return const LoginView();
  } else if (!user.isEmailVerified) {
    return const EmailVerrificationPage();
  } else if (user.isEmailVerified) {
    return const NotesView();
  }
  return const Center(
    child: CircularProgressIndicator(),
  );
}
