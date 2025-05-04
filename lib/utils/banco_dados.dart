import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/ingrediente.dart';
import '../models/prato.dart';

class BancoDados {
  static Future<Database> _abrirBanco() async {
    return openDatabase(
      join(await getDatabasesPath(), 'prato_certo.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE ingredientes(id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT, quantidade INTEGER)',
        );
        await db.execute(
          'CREATE TABLE pratos(id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT, ingredientes TEXT)',
        );
      },
      version: 1,
    );
  }

  // Ingrediente CRUD
  static Future<void> inserirIngrediente(Ingrediente ingrediente) async {
    final db = await _abrirBanco();
    await db.insert('ingredientes', ingrediente.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Ingrediente>> listarIngredientes() async {
    final db = await _abrirBanco();
    final List<Map<String, dynamic>> maps = await db.query('ingredientes');
    return List.generate(maps.length, (i) => Ingrediente.fromMap(maps[i]));
  }

  static Future<void> atualizarIngrediente(Ingrediente ingrediente) async {
    final db = await _abrirBanco();
    await db.update(
      'ingredientes',
      ingrediente.toMap(),
      where: 'id = ?',
      whereArgs: [ingrediente.id],
    );
  }

  static Future<void> excluirIngrediente(int id) async {
    final db = await _abrirBanco();
    await db.delete('ingredientes', where: 'id = ?', whereArgs: [id]);
  }

  // Prato CRUD
  static Future<void> inserirPrato(Prato prato) async {
    final db = await _abrirBanco();
    await db.insert('pratos', prato.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Prato>> listarPratos() async {
    final db = await _abrirBanco();
    final List<Map<String, dynamic>> maps = await db.query('pratos');
    return List.generate(maps.length, (i) => Prato.fromMap(maps[i]));
  }

  static Future<void> atualizarPrato(Prato prato) async {
    final db = await _abrirBanco();
    await db.update(
      'pratos',
      prato.toMap(),
      where: 'id = ?',
      whereArgs: [prato.id],
    );
  }

  static Future<void> excluirPrato(int id) async {
    final db = await _abrirBanco();
    await db.delete('pratos', where: 'id = ?', whereArgs: [id]);
  }
}
