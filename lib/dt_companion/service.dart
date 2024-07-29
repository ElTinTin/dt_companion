import 'package:dt_companion/dt_companion/db_helper/games_dao.dart';
import 'package:dt_companion/dt_companion/db_helper/heroes_dao.dart';
import 'package:dt_companion/dt_companion/models/games_list_data.dart';
import 'package:dt_companion/dt_companion/models/heroes_list_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'db_helper/dta_dao.dart';
import 'models/dta_cards.dart';
import 'models/dta_list_data.dart';

class UserService with ChangeNotifier {
  GamesDAO gamesDAO = GamesDAO();
  HeroesDAO heroesDAO = HeroesDAO();
  DTAdventureDAO dtaDAO = DTAdventureDAO();

  List<GamesListData> gamesListData = [];
  List<HeroesListData> heroesListData = [];
  List<DTAListData> dtaListData = [];

  int victories = 0;
  int defeats = 0;

  Future<void> fetchData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 1500));

    fetchHeroesData();
    fetchGamesData();
    fetchDTAData();

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

  Future<void> fetchDTAData() async {
    dtaListData = await dtaDAO.getDTAListData();
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

  Future<void> insertDtaData(DTAListData game) async {
    dtaDAO.insertDTAListData(game);
    this.dtaListData.insert(0, game);
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

  Future<void> updateDtaData(DTAListData game) async {
    dtaDAO.updateDTAListData(game);
    this.dtaListData.removeWhere((item)=> item.id == game.id);
    this.dtaListData.insert(0, game);
    notifyListeners();
  }

  void expandScoreboard(DTAListData game, int index) async {
    game.scoreboards[index].isExpanded = !game.scoreboards[index].isExpanded;
    notifyListeners();
  }

  void addCardToPlayer(Player player, String card, DTAListData game, cardType type) {
    switch (type) {
      case cardType.common:
        player.commonCards.insert(0, card);
        game.commonCards.removeWhere((e) => e == card);
      case cardType.rare:
        player.rareCards.insert(0, card);
        game.rareCards.removeWhere((e) => e == card);
      case cardType.epic:
        player.epicCards.insert(0, card);
        game.epicCards.removeWhere((e) => e == card);
      case cardType.legendary:
        player.legendaryCards.insert(0, card);
        game.legendaryCards.removeWhere((e) => e == card);
    }
    notifyListeners();
  }

  void removeCardFromPlayer(Player player, String card, DTAListData game) {
    var type = cardType.common;
    if (rareDTACardsList.contains(card)) {
      type = cardType.rare;
    } else if (epicDTACardsList.contains(card)) {
      type = cardType.epic;
    } else if (legendaryDTACardsList.contains(card)) {
      type = cardType.legendary;
    }

    switch (type) {
      case cardType.common:
        player.commonCards.removeWhere((item) => item == card);
        game.commonCards.add(card);
        game.commonCards.sort((a, b) => a.compareTo(b));
      case cardType.rare:
        player.rareCards.removeWhere((item) => item == card);
        game.rareCards.add(card);
        game.rareCards.sort((a, b) => a.compareTo(b));
      case cardType.epic:
        player.epicCards.removeWhere((item) => item == card);
        game.epicCards.add(card);
        game.epicCards.sort((a, b) => a.compareTo(b));
      case cardType.legendary:
        player.legendaryCards.removeWhere((item) => item == card);
        game.legendaryCards.add(card);
        game.legendaryCards.sort((a, b) => a.compareTo(b));
    }

    notifyListeners();
  }

  void expandPlayer(DTAListData game, int index) async {
    game.players[index].isExpanded = !game.players[index].isExpanded;
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

  Future<void> deleteDTAData(DTAListData dta) async {
    dtaDAO.deleteDTAListData(dta.id);
    this.dtaListData.removeWhere((item)=> item.id == dta.id);
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
      List<Map<String, dynamic>> dtaData = dtaListData.map((dta) => dta.toMap()).toList();

      await userDoc.set({
        'gamesListData': gamesData,
        'heroesListData': heroesData,
        'dtaListData': dtaData,
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
        List<DTAListData> dtaData = (data['dtaListData'] as List)
            .map((item) => DTAListData.fromMap(item))
            .toList();

        await insertFetchedData(gamesData, heroesData, dtaData);

        notifyListeners();
      } else {
        print('No backup data found');
      }
    } catch (e) {
      print('Error during restore: $e');
    }
  }

  Future<void> insertFetchedData(List<GamesListData> gamesData, List<HeroesListData> heroesData, List<DTAListData> dtaData) async {
    gamesDAO.clearData();
    heroesDAO.clearData();
    dtaDAO.clearData();

    for (var game in gamesData) {
      await gamesDAO.insertGamesListData(game);
    }
    gamesListData = await gamesDAO.getGamesListData();

    for (var hero in heroesData) {
      await heroesDAO.insertHeroesListData(hero);
    }
    heroesListData = await heroesDAO.getHeroesListData();

    for (var dta in dtaData) {
      await dtaDAO.insertDTAListData(dta);
    }
    dtaListData = await dtaDAO.getDTAListData();

    getUserVictories();
    getUserDefeats();
    notifyListeners();
  }
}