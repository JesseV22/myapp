import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/ingrediente.dart';
import '../models/prato.dart';
import 'dart:convert';

class BancoDados {
  static final BancoDados instance = BancoDados._init();
  static Database? _database;

  BancoDados._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('prato_certo.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Incrementado para v2
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE ingredientes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      quantidade INTEGER NOT NULL,
      unidade TEXT NOT NULL
    )
    ''');
    await db.execute('''
    CREATE TABLE pratos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      ingredientes TEXT NOT NULL
    )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE ingredientes ADD COLUMN unidade TEXT NOT NULL DEFAULT "unidade"');
    }
  }

  Future<void> inserirIngrediente(Ingrediente ingrediente) async {
    final db = await database;
    await db.insert('ingredientes', ingrediente.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    print('Ingrediente salvo: ${ingrediente.nome}, ${ingrediente.quantidade} ${ingrediente.unidade}');
  }

  Future<void> inserirPrato(Prato prato) async {
    final db = await database;
    await db.insert('pratos', prato.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    print('Prato salvo: ${prato.nome}');
  }

  Future<List<Ingrediente>> listarIngredientes() async {
    final db = await database;
    final result = await db.query('ingredientes');
    return result.map((json) => Ingrediente.fromMap(json)).toList();
  }

  Future<List<Prato>> listarPratos() async {
    final db = await database;
    final result = await db.query('pratos');
    return result.map((json) => Prato.fromMap(json)).toList();
  }

  Future<void> atualizarIngrediente(Ingrediente ingrediente) async {
    final db = await database;
    await db.update(
      'ingredientes',
      ingrediente.toMap(),
      where: 'id = ?',
      whereArgs: [ingrediente.id],
    );
  }

  Future<void> excluirIngrediente(int id) async {
    final db = await database;
    await db.delete('ingredientes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> excluirPrato(int id) async {
    final db = await database;
    await db.delete('pratos', where: 'id = ?', whereArgs: [id]);
  }
}