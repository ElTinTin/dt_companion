import 'package:best_flutter_ui_templates/dt_companion/db_helper/games_dao.dart';
import 'package:best_flutter_ui_templates/dt_companion/db_helper/heroes_dao.dart';
import 'package:best_flutter_ui_templates/dt_companion/db_helper/user_dao.dart';
import 'package:best_flutter_ui_templates/dt_companion/models/games_list_data.dart';
import 'package:best_flutter_ui_templates/dt_companion/models/heroes_list_data.dart';
import 'package:best_flutter_ui_templates/dt_companion/models/user_data.dart';
import 'package:flutter/cupertino.dart';


class UserService with ChangeNotifier {
  UserDAO userDAO = UserDAO();
  GamesDAO gamesDAO = GamesDAO();
  HeroesDAO heroesDAO = HeroesDAO();

  List<UserData> userData = [];
  List<GamesListData> gamesListData = [];
  List<HeroesListData> heroesListData = [];
  int victories = 0;
  int defeats = 0;

  Future<void> fetchData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 1500));

    fetchUserData();
    fetchHeroesData();
    fetchGamesData();

    notifyListeners();
  }

  Future<void> fetchUserData() async {
    userData = await userDAO.getUserData();
  }

  Future<void> fetchGamesData() async {
    gamesListData = await gamesDAO.getGamesListData();
  }

  Future<void> fetchHeroesData() async {
    heroesListData = await heroesDAO.getHeroesListData();
    getUserVictories();
    getUserDefeats();
  }

  Future<void> insertUserData(UserData userData) async {
    userDAO.insertUserData(userData);
    this.userData.add(userData);
    notifyListeners();
  }

  Future<void> insertHeroesData(HeroesListData heroesListData) async {
    heroesDAO.insertHeroesListData(heroesListData);
    this.heroesListData.insert(0, heroesListData);
    getUserVictories();
    getUserDefeats();
    notifyListeners();
  }

  Future<void> insertGamesData(GamesListData gamesListData) async {
    gamesDAO.insertGamesListData(gamesListData);
    this.gamesListData.insert(0, gamesListData);
    notifyListeners();
  }

  Future<void> updateHeroesData(HeroesListData heroesListData) async {
    heroesDAO.updateHeroesListData(heroesListData);
    this.heroesListData.isNotEmpty
        ? this.heroesListData.removeWhere((item)=>item.name == heroesListData.name)
        : null;
    this.heroesListData.insert(0, heroesListData);
    getUserVictories();
    getUserDefeats();
    notifyListeners();
  }

  void getUserVictories() {
    int totalVictories = 0;

    for (var hero in heroesListData) {
      print(hero.name);
      print(hero.victories);
      totalVictories += hero.victories;
    }

    victories = totalVictories;
  }

  void getUserDefeats() {
    int totalDefeats = 0;

    for (var hero in heroesListData) {
      totalDefeats += hero.defeats;
    }

    defeats = totalDefeats;
  }
}