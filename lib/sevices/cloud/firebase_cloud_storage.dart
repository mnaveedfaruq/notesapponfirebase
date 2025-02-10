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

  Stream<Iterable<CloudNote>> allNotes({required ownerUserId}) {
    return notes.snapshots().map((event) => event.docs
        .map((doc) => CloudNote.fromSnapshot(doc))
        .where((note) => note.ownerUserId == ownerUserId));
  }

  void createNewNote({required String ownerUserId}) async {
    await notes
        .add({ownerUserIdFieldName: ownerUserId, textFieldName: 'test text'});
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
              return CloudNote(
                documentId: document.id,
                ownerUserId: document.data()[ownerUserIdFieldName] as String,
                text: document.data()[textFieldName] as String,
              );
            },
          );
        },
      );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }
}
