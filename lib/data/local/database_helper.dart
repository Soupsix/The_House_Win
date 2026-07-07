import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Helper quản lý cơ sở dữ liệu SQLite local
class DatabaseHelper {
  static const String _dbName = 'the_house_wins.db';
  static const int _dbVersion = 1;

  Database? _db;

  // Lấy hoặc khởi tạo instance của Database
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  // Khởi tạo database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final pathString = join(dbPath, _dbName);
    return await openDatabase(
      pathString,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Tạo các bảng dữ liệu ban đầu
  Future<void> _onCreate(Database db, int version) async {
    // Bảng bet_history lưu lịch sử cược offline/cache
    await db.execute('''
      CREATE TABLE bet_history (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        match_id TEXT NOT NULL,
        home_team TEXT NOT NULL,
        away_team TEXT NOT NULL,
        choice TEXT NOT NULL,
        amount REAL NOT NULL,
        odds_at_time REAL NOT NULL,
        payout REAL DEFAULT 0,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        settled_at INTEGER
      );
    ''');

    // Bảng match_cache lưu cache trận đấu từ API
    await db.execute('''
      CREATE TABLE match_cache (
        id TEXT PRIMARY KEY,
        home_team TEXT NOT NULL,
        away_team TEXT NOT NULL,
        utc_date INTEGER NOT NULL,
        status TEXT NOT NULL,
        score_home INTEGER DEFAULT 0,
        score_away INTEGER DEFAULT 0,
        result TEXT,
        odds_over REAL NOT NULL,
        odds_under REAL NOT NULL,
        over_under_line REAL NOT NULL,
        is_simulated INTEGER NOT NULL DEFAULT 0,
        synced_at INTEGER NOT NULL
      );
    ''');
  }

  // Xử lý nâng cấp cơ sở dữ liệu
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Nâng cấp schema nếu version thay đổi (không drop bảng)
  }
}
