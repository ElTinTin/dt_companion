import 'package:dt_companion/dt_companion/models/heroes_data.dart';

import 'db_helper.dart';

class HeroesDAO {
  final dbHelper = HeroesDBHelper.instance;

  Future<void> insertHeroesListData(HeroesData heroes) async {
    final db = await dbHelper.database;
    await db.insert('heroes', heroes.toMap());
  }

  Future<List<HeroesData>> getHeroesListData() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('heroes');
    List<HeroesData> heroesList = List.generate(maps.length, (i) {
      return HeroesData.fromMap(maps[i]);
    });

    // Tri de la liste par nombre de parties jouées, du plus au moins joué
    heroesList.sort((a, b) => b.totalGamesPlayed.compareTo(a.totalGamesPlayed));

    return heroesList;
  }

  Future<void> updateHeroesListData(HeroesData heroes) async {
    final db = await dbHelper.database;
    await db.update('heroes', heroes.toMap(), where: 'name = ?', whereArgs: [heroes.name]);
  }

  Future<void> deleteHeroesListData(String name) async {
    final db = await dbHelper.database;
    await db.delete('heroes', where: 'name = ?', whereArgs: [name]);
  }

  Future<void> clearData() async {
    final db = await dbHelper.database;
    await db.rawDelete('DELETE FROM heroes');
  }
}