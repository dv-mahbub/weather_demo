import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:weather_demo/models/database_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._constructor();
  static Database? _db;

  final String _forcastTableName = 'forcast';
  final String _forecastIdColumnName = 'id';
  final String _forecastLatColumnName = 'lat';
  final String _forecastLongColumnName = 'long';
  final String _forecastJsonColumnName = 'json';

  DatabaseService._constructor();

  Future<Database> database() async {
    if (_db != null) {
      return _db!;
    } else {
      _db = await getDatabase();
      return _db!;
    }
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'master_db.db');
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE $_forcastTableName(
          $_forecastIdColumnName INTEGER PRIMARY KEY,
          $_forecastLatColumnName REAL NOT NULL,
          $_forecastLongColumnName REAL NOT NULL,
          $_forecastJsonColumnName TEXT NOT NULL
        )
      ''');
      },
    );
    return database;
  }

  void addForecast(
      {required double lat, required double long, required String json}) async {
    await deleteAllForecasts();

    final Database db = await database();
    await db.insert(
      _forcastTableName,
      {
        _forecastLatColumnName: lat,
        _forecastLongColumnName: long,
        _forecastJsonColumnName: json,
      },
    );
  }

  Future<List<DatabaseModel>> getForecast() async {
    final db = await database();
    final data = await db.query(_forcastTableName);
    List<DatabaseModel> forecasts = data.map((e) {
      return DatabaseModel(
        id: e[_forecastIdColumnName] as int, // Casting to int
        lat: e[_forecastLatColumnName] as double, // Casting to double
        long: e[_forecastLongColumnName] as double, // Casting to double
        json: e[_forecastJsonColumnName] as String, // Casting to String
      );
    }).toList();
    return forecasts;
  }

  Future<void> deleteAllForecasts() async {
    final db = await database();
    await db.delete(_forcastTableName);
  }
}
