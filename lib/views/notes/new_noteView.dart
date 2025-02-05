import 'package:firebasenotesapp/sevices/auth/auth_service.dart';
import 'package:firebasenotesapp/sevices/sqf/note_services.dart';
import 'package:flutter/material.dart';

class NewNotesView extends StatefulWidget {
  const NewNotesView({super.key});

  @override
  State<NewNotesView> createState() => _NewNotesViewState();
}

class _NewNotesViewState extends State<NewNotesView> {
  DataBaseNotes? _note;
  late final NoteServices _noteService;
  late final TextEditingController textEditingController;

  Future<DataBaseNotes> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _noteService.getuser(email: email);
    return await _noteService.createNote(owner: owner);
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (textEditingController.text.isEmpty && note != null) {
      _noteService.deleteNote(id: note.id);
    }
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = textEditingController.text;
    await _noteService.updateNote(
      note: note,
      text: text,
    );
  }

  void _setupRemoveAndThenAddControllerListener() {
    textEditingController.removeListener(_textControllerListener);
    textEditingController.addListener(_textControllerListener);
  }

  @override
  void initState() {
    _noteService = NoteServices();
    textEditingController = TextEditingController();
    super.initState();
  }

  void _saveNoteIfTextIsNotEmpty() async {
    final note = _note;
    final text = textEditingController.text;
    if (note != null && text.isNotEmpty) {
      await _noteService.updateNote(note: note, text: text);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextIsNotEmpty();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data as DataBaseNotes;
              _setupRemoveAndThenAddControllerListener();
              return TextField(
                controller: textEditingController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Start Typing Your Note',
                ),
              );
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
