import 'package:dt_companion/dt_companion/db_helper/db_helper.dart';
import 'package:dt_companion/dt_companion/models/friends_data.dart';

class FriendsDAO {
  final dbHelper = FriendsDBHelper.instance;

  Future<void> insertFriendsData(FriendsData user) async {
    final db = await dbHelper.database;
    await db.insert('friends', user.toMap());
  }

  Future<List<FriendsData>> getFriendsData() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('friends');
    return List.generate(maps.length, (i) {
      return FriendsData.fromMap(maps[i]);
    });
  }

  Future<void> updateFriendsData(FriendsData user) async {
    final db = await dbHelper.database;
    await db.update('friends', user.toMap(), where: 'name = ?', whereArgs: [user.name]);
  }

  Future<void> deleteFriendsData(int id) async {
    final db = await dbHelper.database;
    await db.delete('friends', where: 'name = ?', whereArgs: [id]);
  }

  Future<void> clearData() async {
    final db = await dbHelper.database;
    await db.rawDelete('DELETE FROM friends');
  }
}