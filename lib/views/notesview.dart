import 'package:firebasenotesapp/constant/routes.dart';
import 'package:firebasenotesapp/enums/menu_action.dart';
import 'package:firebasenotesapp/sevices/auth/auth_service.dart';
import 'package:firebasenotesapp/sevices/sqf/note_services.dart';
import 'package:firebasenotesapp/utilities/dialog/logoutDialog.dart';
import 'package:firebasenotesapp/views/notes_listview.dart';
import 'package:flutter/material.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NoteServices _noteServices;
  String get userEmail => AuthService.firebase().currentUser!.email!;
  @override
  void initState() {
    _noteServices = NoteServices();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Notes',
          style: TextStyle(
            color: Colors.cyan,
            fontStyle: FontStyle.italic,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(newNotesView);
              },
              icon: const Icon(Icons.add)),
          PopupMenuButton(
            onSelected: (value) async {
              switch (value) {
                case ManuAction.logout:
                  final result = await showLogoutDialog(context);
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
      body: FutureBuilder(
        future: _noteServices.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return const Text('no connection with data in future builder');
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.active:
              return const Text("active state in future buildr");
            case ConnectionState.done:
              return StreamBuilder(
                stream: _noteServices.allnotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return const Text('no data in stream builder');
                    case ConnectionState.waiting:
                      return const Text('waiting for stream of all note ...');
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as List<DataBaseNotes>;
                        return NoteListView(
                          notes: allNotes,
                          onDeleteNote: (note) async {
                            await _noteServices.deleteNote(id: note.id);
                          },
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    case ConnectionState.done:
                      return const Text('done state of stream builder');
                  }
                },
              );
          }
        },
      ),
    );
  }
}
