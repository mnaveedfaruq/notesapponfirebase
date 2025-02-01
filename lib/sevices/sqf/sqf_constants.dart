const dbName = 'notes.db';
const noteTable = 'notes';
const userTable = 'users';
const idColumn = "id";
const emailColumn = "email";
const userIdColumn = "userId";
const textColumn = "text";
const isSyncedColumn = "isSyncedWithCloud";
const createUserTable = '''
CREATE TABLE  IF NOT EXISTS "$userTable" (
"$idColumn" INTEGER NOT NULL,
"$emailColumn" TEXT NOT NULL UNIQUE,
PRIMARY KEY ("id"  AUTOINCREMENT)
);''';
const createNoteTable = '''
CREATE TABLE IF NOT EXISTS "$noteTable"(
"$idColumn" INTEGER NOT NULL,
"$userIdColumn" INTEGER NOT NULL,
"$textColumn" TEXT,
"$isSyncedColumn" INTEGER NOT NULL DEFAULT 0,
FOREIGN  KEY("$userIdColumn") REFERENCES "$userTable"("$idColumn"),
PRIMARY KEY("$idColumn" AUTOINCREMENT)
);

''';
