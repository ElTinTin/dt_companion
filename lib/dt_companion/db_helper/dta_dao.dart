import 'package:best_flutter_ui_templates/dt_companion/db_helper/db_helper.dart';
import 'package:best_flutter_ui_templates/dt_companion/models/dta_list_data.dart';
import 'package:best_flutter_ui_templates/dt_companion/models/games_list_data.dart';

class DTAdventureDAO {
  final dbHelper = DTADBHelper.instance;

  Future<void> insertDTAListData(DTAListData game) async {
    final db = await dbHelper.database;
    await db.insert('dta', game.toMap());
  }

  Future<List<DTAListData>> getDTAListData() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('dta');

    List<DTAListData> dtaList = List.generate(maps.length, (i) {
      return DTAListData.fromMap(maps[i]);
    });

    dtaList.sort((a, b) => DateTime.fromMillisecondsSinceEpoch(b.date).compareTo(DateTime.fromMillisecondsSinceEpoch(a.date)));

    return dtaList;
  }

  Future<void> updateDTAListData(DTAListData game) async {
    final db = await dbHelper.database;
    await db.update('dta', game.toMap(), where: 'id = ?', whereArgs: [game.id]);
  }

  Future<void> deleteDTAListData(int id) async {
    final db = await dbHelper.database;
    await db.delete('dta', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearData() async {
    final db = await dbHelper.database;
    await db.rawDelete('DELETE FROM dta');
  }
}