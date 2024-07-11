import 'package:best_flutter_ui_templates/dt_companion/db_helper/db_helper.dart';
import 'package:best_flutter_ui_templates/dt_companion/models/user_data.dart';

class UserDAO {
  final dbHelper = UserDBHelper.instance;

  Future<void> insertUserData(UserData user) async {
    final db = await dbHelper.database;
    await db.insert('user', user.toMap());
  }

  Future<List<UserData>> getUserData() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('user');
    return List.generate(maps.length, (i) {
      return UserData.fromMap(maps[i]);
    });
  }

  Future<void> updateUserData(UserData user) async {
    final db = await dbHelper.database;
    await db.update('user', user.toMap(), where: 'name = ?', whereArgs: [user.name]);
  }

  Future<void> deleteUserData(int id) async {
    final db = await dbHelper.database;
    await db.delete('user', where: 'name = ?', whereArgs: [id]);
  }

  Future<void> clearData() async {
    final db = await dbHelper.database;
    await db.rawDelete('DELETE FROM user');
  }
}