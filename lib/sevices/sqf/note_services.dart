import 'package:firebasenotesapp/sevices/sqf/crud_exception.dart';
import 'package:firebasenotesapp/sevices/sqf/sqf_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class NoteServices {
  Database? _db;

  Future<DataBaseNotes> updateNote({
    required DataBaseNotes note,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();
    await getSingleNote(id: note.id);
    final updatedRowsCount = await db.update(
      noteTable,
      {
        textColumn: text,
        isSyncedColumn: 0,
      },
    );
    if (updatedRowsCount == 0) {
      throw CouldNotUpdateNote();
    }
    return await getSingleNote(id: note.id);
  }

  Future<Iterable<DataBaseNotes>> getAllNotes() async {
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
    return result;
  }

  Future<DataBaseNotes> getSingleNote({required int id}) async {
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
    return DataBaseNotes.fromRow(fetchedNote.first);
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    final numberOfRowsDeleted = await db.delete(noteTable);
    return numberOfRowsDeleted;
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedNotesCount = await db.delete(
      noteTable,
      where: '$idColumn=?',
      whereArgs: [id],
    );
    if (deletedNotesCount == 0) {
      throw CouldNotDeleteNote();
    }
  }

  Future<DataBaseNotes> createNote({required DataBaseUser owner}) async {
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
    return note;
  }

  Future<DataBaseUser> getuser({required String email}) async {
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
