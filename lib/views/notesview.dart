import 'package:firebasenotesapp/constant/routes.dart';
import 'package:firebasenotesapp/enums/menu_action.dart';
import 'package:firebasenotesapp/sevices/auth/auth_service.dart';
import 'package:firebasenotesapp/utilities/show_error_dialog.dart';
import 'package:flutter/material.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

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
                    await AuthService.firebase().logout();
                    if (context.mounted) {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                    }
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
