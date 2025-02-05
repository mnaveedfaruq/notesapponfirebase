import 'dart:async';

import 'package:firebasenotesapp/sevices/sqf/crud_exception.dart';
import 'package:firebasenotesapp/sevices/sqf/sqf_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class NoteServices {
  Database? _db;

  Future<DataBaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getuser(email: email);
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  List<DataBaseNotes> _notes = [];

  //creating singleton of NoteServices
  static final NoteServices _shared = NoteServices._shredInstance();
  //creating a stream controller to handle the data
  late final StreamController<List<DataBaseNotes>> _notesStreamController;
  NoteServices._shredInstance() {
    _notesStreamController =
        StreamController<List<DataBaseNotes>>.broadcast(onListen: () {
      _notesStreamController.sink.add(_notes);
    });
  }
  factory NoteServices() => _shared;

  Stream<List<DataBaseNotes>> get allnotes => _notesStreamController.stream;

  Future<void> _catchAllNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DataBaseNotes> updateNote({
    required DataBaseNotes note,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    //make sure that note exists or we will get exception from below method
    await getSingleNote(id: note.id);

    //start to update
    final updatedRowsCount = await db.update(
      noteTable,
      where: '$idColumn=?',
      whereArgs: [note.id],
      {
        textColumn: text,
        isSyncedColumn: 0,
      },
    );
    if (updatedRowsCount == 0) {
      throw CouldNotUpdateNote();
    }
    final updatedNote = await getSingleNote(id: note.id);
    _notes.removeWhere((nte) => nte.id == updatedNote.id);
    _notes.add(updatedNote);
    _notesStreamController.add(_notes);
    return updatedNote;
  }

  Future<Iterable<DataBaseNotes>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final allNotes = await db.query(
      noteTable,
    );
    if (allNotes.isEmpty) {
      throw CouldNotFindNote();
    }
    final result = allNotes.map(
      (singleRow) => DataBaseNotes.fromRow(singleRow),
    );
    debugPrint(result.toString());
    return result;
  }

  Future<DataBaseNotes> getSingleNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final fetchedNote = await db.query(
      noteTable,
      limit: 1,
      where: '$idColumn=?',
      whereArgs: [id],
    );
    if (fetchedNote.isEmpty) {
      throw CouldNotFindNote();
    }
    final singleNote = DataBaseNotes.fromRow(fetchedNote.first);
    _notes.removeWhere((note) => note.id == id);
    _notes.add(singleNote);
    _notesStreamController.add(_notes);
    return singleNote;
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfRowsDeleted = await db.delete(noteTable);
    //for the purpose of broadcast below  function are being called after removal
    _notes = [];
    _notesStreamController.add(_notes);

    //metnod is returning number of deletions
    return numberOfRowsDeleted;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedNotesCount = await db.delete(
      noteTable,
      where: '$idColumn=?',
      whereArgs: [id],
    );
    if (deletedNotesCount == 0) {
      throw CouldNotDeleteNote();
    }
    //for the purpose of broadcast below  function are being called after removal
    final numberOfNotes = _notes.length;
    _notes.removeWhere((note) => note.id == id);
    if (_notes.length != numberOfNotes) {
      _notesStreamController.add(_notes);
    }
  }

  Future<DataBaseNotes> createNote({required DataBaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    //making sure owner exists in the database
    final dbUser = await getuser(email: owner.email);
    //comparing id of given owner with id of the dbuser
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }
    const text = 'no text provided';
    //creating a note
    final noteId = await db.insert(
      noteTable,
      {userIdColumn: owner.id, textColumn: text, isSyncedColumn: 1},
    );
    final note = DataBaseNotes(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );
    //for the purpose of broadcast below two function are being called
    _notes.add(note);
    _notesStreamController.add(_notes);
    //function is returning
    return note;
  }

  Future<DataBaseUser> getuser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable,
        limit: 1, where: '$emailColumn=?', whereArgs: [email.toLowerCase()]);
    if (results.isEmpty) {
      throw CouldNotFindUser();
    }
    //either zero 1 row will be returned
    return DataBaseUser.fromrow(results.first);
  }

  Future<DataBaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(userTable,
        limit: 1, where: '$emailColumn=?', whereArgs: [email.toLowerCase()]);
    if (result.isNotEmpty) {
      throw UserALreadyExists();
    }
    final insertedUserId =
        await db.insert(userTable, {emailColumn: email.toLowerCase()});
    return DataBaseUser(id: insertedUserId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteAccount = await db.delete(
      userTable,
      where: '$emailColumn=?',
      whereArgs: [email.toLowerCase()],
    );
    if (deleteAccount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<void> closeDb() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // we will handle the exception
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final documentPath = await getApplicationDocumentsDirectory();
      final dbPath = join(documentPath.path, dbName);
      final database = await openDatabase(dbPath);
      _db = database;
//create user table
      await database.execute(createUserTable);
      //create notes table
      await database.execute(createNoteTable);
      //for the purpose of broadcast below function are being called
      await _catchAllNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumnetDirectory();
    } catch (e) {
      print(e);
    }
  }
}

@immutable
class DataBaseUser {
  final int id;
  final String email;

  const DataBaseUser({
    required this.id,
    required this.email,
  });

  DataBaseUser.fromrow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  //if you want to ptint a certain user
  @override
  String toString() => 'person, id=$id,email=$email';

  @override
  bool operator ==(covariant DataBaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DataBaseNotes {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DataBaseNotes({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DataBaseNotes.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud = (map[isSyncedColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note, Id=$id,isSyncedWithCloud=$isSyncedWithCloud,userId=$userId, text=$text';

  @override
  bool operator ==(covariant DataBaseNotes other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
