import 'package:dt_companion/dt_companion/db_helper/db_helper.dart';
import 'package:dt_companion/dt_companion/models/dta_data.dart';

class DTAdventureDAO {
  final dbHelper = DTADBHelper.instance;

  Future<void> insertDTAListData(DTAData game) async {
    final db = await dbHelper.database;
    await db.insert('dta', game.toMap());
  }

  Future<List<DTAData>> getDTAListData() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('dta');

    List<DTAData> dtaList = List.generate(maps.length, (i) {
      return DTAData.fromMap(maps[i]);
    });

    dtaList.sort((a, b) => DateTime.fromMillisecondsSinceEpoch(b.date).compareTo(DateTime.fromMillisecondsSinceEpoch(a.date)));

    return dtaList;
  }

  Future<void> updateDTAListData(DTAData game) async {
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