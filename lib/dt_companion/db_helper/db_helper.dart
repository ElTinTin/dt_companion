import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class FriendsDBHelper {
  FriendsDBHelper._();

  static final FriendsDBHelper instance = FriendsDBHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + "/friends_database.db";

    return await openDatabase(
      path,
      version: 1,
      readOnly: false,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE friends (
            name TEXT PRIMARY KEY,
            victories INTEGER,
            defeats INTEGER
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
      version: 5,
      readOnly: false,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE games (
            id INTEGER PRIMARY KEY, 
            playerOneImagePath TEXT,
            playerOne TEXT,
            playerOneUltimates INTEGER,  
            playerTwoImagePath TEXT,
            playerTwo TEXT,
            playerTwoUltimates INTEGER,
            playerThreeImagePath TEXT,
            playerThree TEXT,
            playerThreeUltimates INTEGER,
            playerFourImagePath TEXT,
            playerFour TEXT,
            playerFourUltimates INTEGER,
            playerFiveImagePath TEXT,
            playerFive TEXT,
            playerFiveUltimates INTEGER,
            playerSixImagePath TEXT,
            playerSix TEXT,
            playerSixUltimates INTEGER,
            gamemode TEXT,
            winner TEXT,
            date INTEGER DEFAULT 0,
            winnerHealth INTEGER
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
        if (oldVersion < 4) {
          db.execute(
            "ALTER TABLE games ADD COLUMN playerFive TEXT",
          );
          db.execute(
            "ALTER TABLE games ADD COLUMN playerSix TEXT",
          );
          db.execute(
            "ALTER TABLE games ADD COLUMN playerFiveImagePath TEXT",
          );
          db.execute(
            "ALTER TABLE games ADD COLUMN playerSixImagePath TEXT",
          );
        }
        if (oldVersion < 5) {
          db.execute(
            "ALTER TABLE games ADD COLUMN playerOneUltimates TEXT",
          );
          db.execute(
            "ALTER TABLE games ADD COLUMN playerTwoUltimates TEXT",
          );
          db.execute(
            "ALTER TABLE games ADD COLUMN playerThreeUltimates TEXT",
          );
          db.execute(
            "ALTER TABLE games ADD COLUMN playerFourUltimates TEXT",
          );
          db.execute(
            "ALTER TABLE games ADD COLUMN playerFiveUltimates TEXT",
          );
          db.execute(
            "ALTER TABLE games ADD COLUMN playerSixUltimates TEXT",
          );
          db.execute(
            "ALTER TABLE games ADD COLUMN winnerHealth INTEGER",
          );
        }
      },
    );
  }
}

class DTADBHelper {
  DTADBHelper._();

  static final DTADBHelper instance = DTADBHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + "/dta_database.db";

    return await openDatabase(
      path,
      version: 1,
      readOnly: false,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE dta (
            id INTEGER PRIMARY KEY,
            teamName TEXT, 
            players TEXT,
            legacyMode BOOLEAN, 
            difficulty INTEGER, 
            mythic BOOLEAN,
            date INTEGER DEFAULT 0,
            scoreboards TEXT,
            inprogress BOOLEAN,
            campaignScore INTEGER,
            commonCards TEXT,
            rareCards TEXT,
            epicCards TEXT,
            legendaryCards TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        // Handle other versions if necessary
      },
    );
  }
}