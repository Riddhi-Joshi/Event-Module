import 'dart:math';

import 'package:events/model/event_model.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE events(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,        
        image BLOB NOT NULL,
        isFeatured INTEGER NOT NULL DEFAULT 0,        
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);

    print('================ Table Created ==============');
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'mydatabase.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createItem(EventModel event) async {
    final db = await SQLHelper.db();

    final data = event.toJson();
    final id = await db.insert('events', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);

    print("============ Created Row: id: $id");
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('events', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('events', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateItem(EventModel event) async {
    final db = await SQLHelper.db();

    final data = event.toJson();

    print(data);

    final result = await db.update('events', data, where: "id = ?", whereArgs: [event.id]);

    print("============ Updated Row: id: $result");

    return result;
  }

  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("events", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      print("Something went wrong when deleting an item: $err");
    }
  }
}
