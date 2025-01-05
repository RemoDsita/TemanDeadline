import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Note {
  final int? id;
  final String judul;
  final String subjek;
  final String catatan;
  final DateTime tanggalDibuat;

  Note({
    this.id,
    required this.judul,
    required this.subjek,
    required this.catatan,
    required this.tanggalDibuat,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'subjek': subjek,
      'catatan': catatan,
      'tanggalDibuat': tanggalDibuat.toIso8601String(),
    };
  }

  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      judul: map['judul'],
      subjek: map['subjek'],
      catatan: map['catatan'],
      tanggalDibuat: DateTime.parse(map['tanggalDibuat']),
    );
  }
}

class NoteDatabase {
  static final NoteDatabase instance = NoteDatabase._init();
  static Database? _database;

  NoteDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        judul TEXT NOT NULL,
        subjek TEXT NOT NULL,
        catatan TEXT NOT NULL,
        tanggalDibuat TEXT NOT NULL
      )
    ''');
  }

  Future<Note> create(Note note) async {
    final db = await instance.database;
    final id = await db.insert('notes', note.toMap());
    return note.id == null
        ? Note(
            id: id,
            judul: note.judul,
            subjek: note.subjek,
            catatan: note.catatan,
            tanggalDibuat: note.tanggalDibuat,
          )
        : note;
  }

  Future<List<Note>> getAllNotes() async {
    final db = await instance.database;
    final result = await db.query('notes', orderBy: 'tanggalDibuat DESC');
    return result.map((json) => Note.fromMap(json)).toList();
  }

  Future<int> update(Note note) async {
    final db = await instance.database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
