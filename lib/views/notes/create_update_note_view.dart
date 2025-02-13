import 'package:firebasenotesapp/sevices/auth/auth_service.dart';
import 'package:firebasenotesapp/sevices/cloud/cloud_note.dart';
import 'package:firebasenotesapp/sevices/cloud/firebase_cloud_storage.dart';
import 'package:firebasenotesapp/utilities/generics/get_arguments.dart';
import 'package:flutter/material.dart';

class CreateUpdateNotesView extends StatefulWidget {
  const CreateUpdateNotesView({super.key});

  @override
  State<CreateUpdateNotesView> createState() => _CreateUpdateNotesViewState();
}

class _CreateUpdateNotesViewState extends State<CreateUpdateNotesView> {
  CloudNote? _note;
  //  DataBaseNotes? _note;
  late final FirebaseCloudStorage _noteService;
  // late final NoteServices _noteService;
  late final TextEditingController textEditingController;

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();
    // Future<DataBaseNotes> createOrGetExistingNote(BuildContext context) async {
    //   final widgetNote = context.getArgument<DataBaseNotes>();
    if (widgetNote != null) {
      _note = widgetNote;
      textEditingController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    // final email = currentUser.email;
    // final owner = await _noteService.getUser(email: email);
    // final newNote = await _noteService.createNote(owner: owner);
    final userId = currentUser.id; //added for Cloud
    final newNote =
        await _noteService.createNewNote(ownerUserId: userId); //added for cloud
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (textEditingController.text.isEmpty && note != null) {
      // _noteService.deleteNote(id: note.id);
      _noteService.deleteNote(documentId: note.documentId); //added for Cloud
    }
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = textEditingController.text;
    // await _noteService.updateNote(
    //   note: note,
    //   text: text,
    // );
    await _noteService.updateNote(documentId: note.documentId, text: text);
    //added for Cloud
  }

  void _setupRemoveAndThenAddControllerListener() {
    textEditingController.removeListener(_textControllerListener);
    textEditingController.addListener(_textControllerListener);
  }

  @override
  void initState() {
    _noteService = FirebaseCloudStorage();
    // _noteService = NoteServices();
    textEditingController = TextEditingController();
    super.initState();
  }

  void _saveNoteIfTextIsNotEmpty() async {
    final note = _note;
    final text = textEditingController.text;
    if (note != null && text.isNotEmpty) {
      // await _noteService.updateNote(note: note, text: text);

      await _noteService.updateNote(
          documentId: note.documentId, text: text); //added for Cloud
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
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
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
