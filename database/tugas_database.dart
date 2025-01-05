import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Tugas {
  final int? id;
  final String mataKuliah;
  final DateTime deadline;
  final String catatan;
  final double progress; // untuk progress bar

  Tugas({
    this.id,
    required this.mataKuliah,
    required this.deadline,
    required this.catatan,
    required this.progress,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mataKuliah': mataKuliah,
      'deadline': deadline.toIso8601String(),
      'catatan': catatan,
      'progress': progress,
    };
  }

  static Tugas fromMap(Map<String, dynamic> map) {
    return Tugas(
      id: map['id'],
      mataKuliah: map['mataKuliah'],
      deadline: DateTime.parse(map['deadline']),
      catatan: map['catatan'],
      progress: map['progress'],
    );
  }
}

class TugasDatabase {
  static final TugasDatabase instance = TugasDatabase._init();
  static Database? _database;

  TugasDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tugas.db');
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
      CREATE TABLE tugas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mataKuliah TEXT NOT NULL,
        deadline TEXT NOT NULL,
        catatan TEXT NOT NULL,
        progress REAL NOT NULL
      )
    ''');
  }

  Future<Tugas> create(Tugas tugas) async {
    final db = await instance.database;
    final id = await db.insert('tugas', tugas.toMap());
    return tugas.id == null
        ? Tugas(
            id: id,
            mataKuliah: tugas.mataKuliah,
            deadline: tugas.deadline,
            catatan: tugas.catatan,
            progress: tugas.progress,
          )
        : tugas;
  }

  Future<List<Tugas>> getAllTugas() async {
    final db = await instance.database;
    final result = await db.query('tugas', orderBy: 'deadline ASC');
    return result.map((json) => Tugas.fromMap(json)).toList();
  }

  Future<int> update(Tugas tugas) async {
    final db = await instance.database;
    return db.update(
      'tugas',
      tugas.toMap(),
      where: 'id = ?',
      whereArgs: [tugas.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'tugas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
