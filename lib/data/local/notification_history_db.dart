import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/models/notification_history_model.dart';

class NotificationHistoryDatabase {
  static final NotificationHistoryDatabase instance = NotificationHistoryDatabase._init();
  static Database? _database;

  NotificationHistoryDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notification_history.db');
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
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const textNullableType = 'TEXT';

    await db.execute('''
CREATE TABLE notification_history (
  id $idType,
  title $textType,
  body $textType,
  type $textType,
  receivedAt $textType,
  isRead $boolType,
  payload $textNullableType
)
''');
  }

  Future<NotificationHistoryModel> create(NotificationHistoryModel notification) async {
    final db = await instance.database;
    final json = notification.toJson();
    // Convert DateTime to string for SQLite
    json['receivedAt'] = notification.receivedAt.toIso8601String();
    // SQLite doesn't have bool, convert to 1/0
    json['isRead'] = notification.isRead ? 1 : 0;
    
    final id = await db.insert('notification_history', json);
    return notification.copyWith(id: id);
  }

  Future<List<NotificationHistoryModel>> readAllNotifications() async {
    final db = await instance.database;
    final orderBy = 'receivedAt DESC';
    final result = await db.query('notification_history', orderBy: orderBy);

    return result.map((json) {
      final map = Map<String, dynamic>.from(json);
      map['isRead'] = map['isRead'] == 1;
      return NotificationHistoryModel.fromJson(map);
    }).toList();
  }

  Future<int> markAsRead(int id) async {
    final db = await instance.database;
    return db.update(
      'notification_history',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'notification_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<int> clearAll() async {
    final db = await instance.database;
    return await db.delete('notification_history');
  }

  Future<bool> isDuplicate(String type, String title, Duration window) async {
    final db = await instance.database;
    final cutoffTime = DateTime.now().subtract(window).toIso8601String();
    
    final result = await db.query(
      'notification_history',
      where: 'type = ? AND title = ? AND receivedAt > ?',
      whereArgs: [type, title, cutoffTime],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
