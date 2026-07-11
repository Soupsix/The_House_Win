import 'package:sqflite/sqflite.dart';

import '../../domain/models/match_model.dart';
import 'database_helper.dart';

class MatchesLocalDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> insertMatch(MatchModel match) async {
    final db = await _databaseHelper.database;

    await db.insert(
      "match_cache",
      match.toSQLite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertMatches(List<MatchModel> matches) async {
    final db = await _databaseHelper.database;

    final batch = db.batch();

    for (final match in matches) {
      batch.insert(
        "match_cache",
        match.toSQLite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> updateMatch(MatchModel match) async {
    final db = await _databaseHelper.database;

    await db.update(
      "match_cache",
      match.toSQLite(),
      where: "id=?",
      whereArgs: [match.id],
    );
  }

  Future<List<MatchModel>> getAllMatches() async {
    final db = await _databaseHelper.database;

    final maps = await db.query(
      "match_cache",
      orderBy: "utc_date ASC",
    );

    return maps.map(MatchModel.fromSQLite).toList();
  }

  Future<MatchModel?> getMatch(String id) async {
    final db = await _databaseHelper.database;

    final maps = await db.query(
      "match_cache",
      where: "id=?",
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    return MatchModel.fromSQLite(maps.first);
  }

  Future<void> deleteAllMatches() async {
    final db = await _databaseHelper.database;

    await db.delete("match_cache");
  }
}