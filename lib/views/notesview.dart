import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasenotesapp/constant/routes.dart';
import 'package:flutter/material.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

enum ManuAction { logout }

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('main view'),
        actions: [
          PopupMenuButton(
            onSelected: (value) async {
              switch (value) {
                case ManuAction.logout:
                  final result = await showmyDialog(context);
                  if (result) {
                    await FirebaseAuth.instance.signOut().then((result) =>
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil(loginRoute, (_) => false));
                  }

                  break;
                default:
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<ManuAction>(
                    value: ManuAction.logout, child: Text('logout'))
              ];
            },
          )
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
              child: Text('ok'))
        ],
      );
    },
  );
}
