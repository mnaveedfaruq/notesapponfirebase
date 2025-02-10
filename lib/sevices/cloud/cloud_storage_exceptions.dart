class CloudStorageException implements Exception {
  const CloudStorageException();
}

//C (in crud)  means create
class CouldNotCreateNoteException extends CloudStorageException {}

// R (in crud) means read
class CouldNotGetAllNotesException extends CloudStorageException {}

// U in CRUD  means update
class CouldNotUpdateNoteException extends CloudStorageException {}

//D in CRUD  means Delete
class CouldNotDeleteException extends CloudStorageException {}
