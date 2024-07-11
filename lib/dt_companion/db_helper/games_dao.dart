import 'package:best_flutter_ui_templates/dt_companion/db_helper/db_helper.dart';
import 'package:best_flutter_ui_templates/dt_companion/models/games_list_data.dart';

class GamesDAO {
  final dbHelper = GamesDBHelper.instance;

  Future<void> insertGamesListData(GamesListData games) async {
    final db = await dbHelper.database;
    await db.insert('games', games.toMap());
  }

  Future<List<GamesListData>> getGamesListData() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('games');
    return List.generate(maps.length, (i) {
      return GamesListData.fromMap(maps[i]);
    });
  }

  Future<void> updateGamesListData(GamesListData games) async {
    final db = await dbHelper.database;
    await db.update('games', games.toMap(), where: 'id = ?', whereArgs: [games.id]);
  }

  Future<void> deleteGamesListData(int id) async {
    final db = await dbHelper.database;
    await db.delete('games', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearData() async {
    final db = await dbHelper.database;
    await db.rawDelete('DELETE FROM games');
  }
}