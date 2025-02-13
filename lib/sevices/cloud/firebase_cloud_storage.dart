import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebasenotesapp/sevices/cloud/cloud_note.dart';
import 'package:firebasenotesapp/sevices/cloud/cloud_storage_constants.dart';
import 'package:firebasenotesapp/sevices/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection(collectionName);

  FirebaseCloudStorage._sharedInstance();

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();

  factory FirebaseCloudStorage() => _shared;

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteException();
    }
  }

  Future<void> updateNote(
      {required String documentId, required String text}) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required ownerUserId}) {
    final streamOfQuery = notes.snapshots();
    final streamOfIterableOfCloudNote = streamOfQuery.map((event) => event.docs
        .map((doc) => CloudNote.fromSnapshot(doc))
        .where((note) => note.ownerUserId == ownerUserId));
    return streamOfIterableOfCloudNote;

    // return notes.snapshots().map((event) => event.docs
    //     .map((doc) => CloudNote.fromSnapshot(doc))
    //     .where((note) => note.ownerUserId == ownerUserId));
  }

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final documentAdded = await notes
        .add({ownerUserIdFieldName: ownerUserId, textFieldName: 'test text'});

    final fetchedNote = await documentAdded.get();
    final myCloudNote = CloudNote(
        documentId: fetchedNote.id, ownerUserId: ownerUserId, text: '');
    return myCloudNote;
  }

  Future<Iterable<CloudNote>> getNote({required String ownerUserId}) async {
    try {
      return await notes
          .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
          .get()
          .then(
        (value) {
          return value.docs.map(
            (document) {
              return CloudNote.fromSnapshot(document);
            },
          );
        },
      );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }
}
