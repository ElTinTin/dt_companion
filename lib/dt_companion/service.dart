import 'package:dt_companion/dt_companion/db_helper/games_dao.dart';
import 'package:dt_companion/dt_companion/db_helper/heroes_dao.dart';
import 'package:dt_companion/dt_companion/db_helper/user_dao.dart';
import 'package:dt_companion/dt_companion/models/games_list_data.dart';
import 'package:dt_companion/dt_companion/models/heroes_list_data.dart';
import 'package:dt_companion/dt_companion/models/user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import 'package:cloud_firestore/cloud_firestore.dart';


class UserService with ChangeNotifier {
  GamesDAO gamesDAO = GamesDAO();
  HeroesDAO heroesDAO = HeroesDAO();

  List<GamesListData> gamesListData = [];
  List<HeroesListData> heroesListData = [];
  int victories = 0;
  int defeats = 0;

  Future<void> fetchData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 1500));

    fetchHeroesData();
    fetchGamesData();

    notifyListeners();
  }

  Future<void> fetchGamesData() async {
    gamesListData = await gamesDAO.getGamesListData();
  }

  Future<void> fetchHeroesData() async {
    heroesListData = await heroesDAO.getHeroesListData();
    getUserVictories();
    getUserDefeats();
  }

  Future<void> insertHeroesData(HeroesListData heroesListData) async {
    heroesDAO.insertHeroesListData(heroesListData);
    this.heroesListData.add(heroesListData);
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
    this.heroesListData.removeWhere((item)=> item.name == heroesListData.name);
    this.heroesListData.insert(0, heroesListData);
    getUserVictories();
    getUserDefeats();
    notifyListeners();
  }

  Future<void> deleteHeroesData(String hero) async {
    heroesDAO.deleteHeroesListData(hero);
    this.heroesListData.removeWhere((item)=> p.basenameWithoutExtension(item.imagePath) == hero);
    getUserVictories();
    getUserDefeats();
    notifyListeners();
  }

  Future<void> deleteGamesData(GamesListData game) async {
    gamesDAO.deleteGamesListData(game.id);
    this.gamesListData.isNotEmpty
        ? this.gamesListData.removeWhere((item)=> item.id == game.id)
        : null;
    notifyListeners();
  }

  void getUserVictories() {
    int totalVictories = 0;

    for (var hero in heroesListData) {
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

  Future<void> backupDataToFirestore() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print('No user is currently signed in');
        return;
      }

      String userEmail = currentUser.email!;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference userDoc = firestore.collection('backups').doc(userEmail);

      List<Map<String, dynamic>> gamesData = gamesListData.map((game) => game.toMap()).toList();
      List<Map<String, dynamic>> heroesData = heroesListData.map((hero) => hero.toMap()).toList();
      //List<Map<String, dynamic>> dtaData = dtaListData.map((dta) => dta.toMap()).toList();

      await userDoc.set({
        'gamesListData': gamesData,
        'heroesListData': heroesData,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Backup successful');
    } catch (e) {
      print('Error during backup: $e');
    }
  }

  Future<void> restoreDataFromFirestore() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print('No user is currently signed in');
        return;
      }

      String userEmail = currentUser.email!;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference userDoc = firestore.collection('backups').doc(userEmail);

      DocumentSnapshot snapshot = await userDoc.get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        List<GamesListData> gamesData = (data['gamesListData'] as List)
            .map((item) => GamesListData.fromMap(item))
            .toList();
        List<HeroesListData> heroesData = (data['heroesListData'] as List)
            .map((item) => HeroesListData.fromMap(item))
            .toList();

        await insertFetchedData(gamesData, heroesData);

        notifyListeners();
      } else {
        print('No backup data found');
      }
    } catch (e) {
      print('Error during restore: $e');
    }
  }

  Future<void> insertFetchedData(List<GamesListData> gamesData, List<HeroesListData> heroesData) async {
    for (var game in gamesData) {
      await gamesDAO.insertGamesListData(game);
    }
    gamesListData = await gamesDAO.getGamesListData();

    for (var hero in heroesData) {
      await heroesDAO.insertHeroesListData(hero);
    }
    heroesListData = await heroesDAO.getHeroesListData();

    getUserVictories();
    getUserDefeats();
    notifyListeners();
  }

}