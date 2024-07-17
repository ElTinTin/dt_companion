import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class UserDBHelper {
  UserDBHelper._();

  static final UserDBHelper instance = UserDBHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + "/user_database.db";

    return await openDatabase(
      path,
      version: 1,
      readOnly: false,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user (
            name TEXT PRIMARY KEY
          )
        ''');
      },
    );
  }
}

class HeroesDBHelper {
  HeroesDBHelper._();

  static final HeroesDBHelper instance = HeroesDBHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + "/heroes_database.db";

    return await openDatabase(
      path,
      version: 4,
      readOnly: false,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE heroes (
            name TEXT PRIMARY KEY, 
            imagePath TEXT, 
            victories INTEGER, 
            defeats INTEGER,
            draws INTEGER DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 4) {
          db.execute(
            "ALTER TABLE heroes ADD COLUMN draws INTEGER DEFAULT 0",
          );
        }
        // Handle other versions if necessary
      },
    );
  }
}

class GamesDBHelper {
  GamesDBHelper._();

  static final GamesDBHelper instance = GamesDBHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + "/games_database.db";

    return await openDatabase(
      path,
      version: 3,
      readOnly: false,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE games (
            id INTEGER PRIMARY KEY, 
            playerOneImagePath TEXT,
            playerOne TEXT,  
            playerTwoImagePath TEXT,
            playerTwo TEXT,
            playerThreeImagePath TEXT,
            playerThree TEXT,
            playerFourImagePath TEXT,
            playerFour TEXT,
            gamemode TEXT,
            winner TEXT,
            date INTEGER DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 3) {
          db.execute(
            "ALTER TABLE games ADD COLUMN date INTEGER DEFAULT 0",
          );
        }
        // Handle other versions if necessary
      },
    );
  }
}