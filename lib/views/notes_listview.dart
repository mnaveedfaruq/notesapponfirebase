import 'package:firebasenotesapp/sevices/sqf/note_services.dart';
import 'package:firebasenotesapp/utilities/dialog/delete_dialog.dart';
import 'package:flutter/material.dart';

typedef DeleteNoteCallBack = void Function(DataBaseNotes note);

class NoteListView extends StatelessWidget {
  final List<DataBaseNotes> notes;
  final DeleteNoteCallBack onDeleteNote;

  const NoteListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
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
