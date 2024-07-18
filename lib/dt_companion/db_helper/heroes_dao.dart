import 'package:best_flutter_ui_templates/dt_companion/models/heroes_list_data.dart';

import 'db_helper.dart';

class HeroesDAO {
  final dbHelper = HeroesDBHelper.instance;

  Future<void> insertHeroesListData(HeroesListData heroes) async {
    final db = await dbHelper.database;
    await db.insert('heroes', heroes.toMap());
  }

  Future<List<HeroesListData>> getHeroesListData() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('heroes');
    List<HeroesListData> heroesList = List.generate(maps.length, (i) {
      return HeroesListData.fromMap(maps[i]);
    });

    // Tri de la liste par nombre de parties jouées, du plus au moins joué
    heroesList.sort((a, b) => b.totalGamesPlayed.compareTo(a.totalGamesPlayed));

    return heroesList;
  }

  Future<void> updateHeroesListData(HeroesListData heroes) async {
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