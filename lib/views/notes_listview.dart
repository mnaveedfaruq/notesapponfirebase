import 'package:firebasenotesapp/sevices/cloud/cloud_note.dart';
// import 'package:firebasenotesapp/sevices/sqf/note_services.dart';
import 'package:firebasenotesapp/utilities/dialog/delete_dialog.dart';
import 'package:flutter/material.dart';

// typedef NoteCallBack = void Function(DataBaseNotes note);
typedef NoteCallBack = void Function(CloudNote note); //added for Cloud

class NoteListView extends StatelessWidget {
  // final List<DataBaseNotes> notes;
  final Iterable<CloudNote> notes; //added for Cloud
  final NoteCallBack onDeleteNote;
  final NoteCallBack onUpdateNote;

  const NoteListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onUpdateNote,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        // final note = notes[index];
        final note = notes.elementAt(index); //added for Cloud
        return ListTile(
          onTap: () {
            onUpdateNote(note);
          },
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
              onPressed: () async {
                final shouldDelete = await showDeleteDialog(context: context);
                if (shouldDelete == true) {
                  onDeleteNote(note);
                }
              },
              icon: const Icon(Icons.delete)),
        );
      },
    );
  }
}
