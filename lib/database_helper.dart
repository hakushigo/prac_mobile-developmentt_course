import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class DatabaseHelper {
  static Future<void> createTables(sql.Database db) async {
    await db.execute("""
        CREATE TABLE mahasiswa (
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          nim INTEGER,
          nama TEXT,
          prodi TEXT,
          angkatan INT,
          submittedAT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
          )
        """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'mahasiswa.db',
      version: 1,
      onCreate: (db, version) async {
        await createTables(db);
      },
    );
  }

  static Future<int> insertItem(int nim, String nama, String prodi, int angkatan) async {
    final db = await DatabaseHelper.db();
    final idItem = await db.insert(
        'mahasiswa', {'nim' : nim, 'nama' : nama, 'prodi' : prodi , 'angkatan' : angkatan},
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return idItem;
  }

  static Future<List<Map<String, dynamic>>> fetchAll() async {
    return (await DatabaseHelper.db()).query('mahasiswa', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> fetchById(int id) async {
    return (await DatabaseHelper.db())
        .query('mahasiswa', where: 'id = ?', whereArgs: [id], limit: 1);
  }

  static Future<int> update(int id, int? nim, String? nama, String? prodi, int? angkatan) async {
    final db = await DatabaseHelper.db();
    final updateData = {
      'nim' : nim, 
      'nama' : nama, 
      'prodi' : prodi,
      'angkatan' : angkatan
    };

    final res =
        await db.update('mahasiswa', updateData, where: "id = ?", whereArgs: [id]);

    return res;
  }

  static Future<void> destroy(int id) async {
    try {
      (await DatabaseHelper.db())
          .delete("mahasiswa", where: "id = ?", whereArgs: [id]);
    } catch (e) {
      print("Something went wrong lelelelel : $e");
    }
  }
}
