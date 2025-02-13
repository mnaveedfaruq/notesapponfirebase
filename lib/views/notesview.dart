import 'package:firebasenotesapp/constant/routes.dart';
import 'package:firebasenotesapp/enums/menu_action.dart';
import 'package:firebasenotesapp/sevices/auth/auth_service.dart';
import 'package:firebasenotesapp/sevices/cloud/cloud_note.dart';
import 'package:firebasenotesapp/sevices/cloud/firebase_cloud_storage.dart';
import 'package:firebasenotesapp/utilities/dialog/logoutDialog.dart';
import 'package:firebasenotesapp/views/notes_listview.dart';
import 'package:flutter/material.dart';

// class NotesView extends StatefulWidget {
//   const NotesView({super.key});

//   @override
//   State<NotesView> createState() => _NotesViewState();
// }

// class _NotesViewState extends State<NotesView> {
//   late final NoteServices _noteServices;
//   String get userEmail => AuthService.firebase().currentUser!.email;
//   @override
//   void initState() {
//     _noteServices = NoteServices();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Your Notes',
//           style: TextStyle(
//             color: Colors.cyan,
//             fontStyle: FontStyle.italic,
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           IconButton(
//               onPressed: () {
//                 Navigator.of(context).pushNamed(createUpdateNotesViewRoute);
//               },
//               icon: const Icon(Icons.add)),
//           PopupMenuButton(
//             onSelected: (value) async {
//               switch (value) {
//                 case ManuAction.logout:
//                   final result = await showLogoutDialog(context);
//                   if (result) {
//                     await AuthService.firebase().logout();
//                     if (context.mounted) {
//                       Navigator.of(context)
//                           .pushNamedAndRemoveUntil(loginRoute, (_) => false);
//                     }
//                   }

//                   break;
//                 default:
//               }
//             },
//             itemBuilder: (context) {
//               return [
//                 const PopupMenuItem<ManuAction>(
//                     value: ManuAction.logout, child: Text('logout'))
//               ];
//             },
//           )
//         ],
//       ),
//       body: FutureBuilder(
//         future: _noteServices.getOrCreateUser(email: userEmail),
//         builder: (context, snapshot) {
//           switch (snapshot.connectionState) {
//             case ConnectionState.none:
//               return const Text('no connection with data in future builder');
//             case ConnectionState.waiting:
//               return const Center(child: CircularProgressIndicator());
//             case ConnectionState.active:
//               return const Text("active state in future buildr");
//             case ConnectionState.done:
//               return StreamBuilder(
//                 stream: _noteServices.allnotes,
//                 builder: (context, snapshot) {
//                   switch (snapshot.connectionState) {
//                     case ConnectionState.none:
//                       return const Text('no data in stream builder');
//                     case ConnectionState.waiting:
//                       return const Text('waiting for stream of all note ...');
//                     case ConnectionState.active:
//                       if (snapshot.hasData) {
//                         final allNotes = snapshot.data as List<DataBaseNotes>;
//                         return NoteListView(
//                           notes: allNotes,
//                           onDeleteNote: (note) async {
//                             await _noteServices.deleteNote(id: note.id);
//                           },
//                           onUpdateNote: (DataBaseNotes note) {
//                             Navigator.of(context).pushNamed(
//                               createUpdateNotesViewRoute,
//                               arguments: note,
//                             );
//                           },
//                         );
//                       } else {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//                     case ConnectionState.done:
//                       return const Text('done state of stream builder');
//                   }
//                 },
//               );
//           }
//         },
//       ),
//     );
//   }
// }

//upper code was used for SQFLite

// the lower code is being written for CLoud
class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _noteService;
  String get userId => AuthService.firebase().currentUser!.id;
  @override
  void initState() {
    _noteService = FirebaseCloudStorage();
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
                Navigator.of(context).pushNamed(createUpdateNotesViewRoute);
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
      body: StreamBuilder(
        stream: _noteService.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return const Text('no data in stream builder');
            case ConnectionState.waiting:
              return const Text('waiting for stream of all note ...');
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                return NoteListView(
                  notes: allNotes,
                  onDeleteNote: (note) async {
                    await _noteService.deleteNote(documentId: note.documentId);
                  },
                  onUpdateNote: (CloudNote note) {
                    Navigator.of(context).pushNamed(
                      createUpdateNotesViewRoute,
                      arguments: note,
                    );
                  },
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            case ConnectionState.done:
              return const Text('done state of stream builder');
          }
        },
      ),
    );
  }
}
