import 'package:dt_companion/dt_companion/db_helper/games_dao.dart';
import 'package:dt_companion/dt_companion/db_helper/heroes_dao.dart';
import 'package:dt_companion/dt_companion/db_helper/friends_dao.dart';
import 'package:dt_companion/dt_companion/extension/localization_extension.dart';
import 'package:dt_companion/dt_companion/models/friends_data.dart';
import 'package:dt_companion/dt_companion/models/games_data.dart';
import 'package:dt_companion/dt_companion/models/heroes_data.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'db_helper/dta_dao.dart';
import 'models/dta_cards.dart';
import 'models/dta_data.dart';

class UserService with ChangeNotifier {
  GamesDAO gamesDAO = GamesDAO();
  HeroesDAO heroesDAO = HeroesDAO();
  DTAdventureDAO dtaDAO = DTAdventureDAO();
  FriendsDAO friendsDAO = FriendsDAO();

  List<GamesData> gamesListData = [];
  List<HeroesData> heroesListData = [];
  List<DTAData> dtaListData = [];
  List<FriendsData> friendsListData = [];

  int victories = 0;
  int defeats = 0;

  Future<void> fetchData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 1500));

    fetchAllData();

    notifyListeners();
  }

  Future<void> fetchAllData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print('No user is currently signed in');
        return;
      }

      String userEmail = currentUser.email!;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference userDoc =
          firestore.collection('backups').doc(userEmail);

      DocumentSnapshot snapshot = await userDoc.get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        List<GamesData> gamesData = (data['gamesListData'] as List)
            .map((item) => GamesData.fromMap(item))
            .toList();
        gamesData.sort((a, b) => DateTime.fromMillisecondsSinceEpoch(b.date).compareTo(DateTime.fromMillisecondsSinceEpoch(a.date)));
        List<HeroesData> heroesData = (data['heroesListData'] as List)
            .map((item) => HeroesData.fromMap(item))
            .toList();
        heroesData.sort((a, b) => b.totalGamesPlayed.compareTo(a.totalGamesPlayed));
        List<DTAData> dtaData = (data['dtaListData'] as List)
            .map((item) => DTAData.fromMap(item))
            .toList();
        dtaData.sort((a, b) => DateTime.fromMillisecondsSinceEpoch(b.date).compareTo(DateTime.fromMillisecondsSinceEpoch(a.date)));
        List<FriendsData> friendsData = (data['friendsListData'] as List)
            .map((item) => FriendsData.fromMap(item))
            .toList();
        friendsData.sort((a, b) => a.name.compareTo(b.name));

        gamesListData = gamesData;
        heroesListData = heroesData;
        getUserVictories();
        getUserDefeats();
        dtaListData = dtaData;
        friendsListData = friendsData;

        await FirebaseAnalytics.instance.logLogin(
          loginMethod: "google or apple",
          parameters: {},
        );

        notifyListeners();
      } else {
        await FirebaseAnalytics.instance.logEvent(
          name: "error_load_data",
          parameters: {
            "error": "No data found",
          },
        );
      }
    } catch (e) {
      print('Error during restore: $e');
    }
  }

  Future<void> insertFriendsData(FriendsData friendsData) async {
    editFriendData(friendsData, true);
    this.friendsListData.add(friendsData);
    notifyListeners();
  }

  Future<void> insertHeroesData(HeroesData hero) async {
    editHeroData(hero, true);
    this.heroesListData.add(hero);
    getUserVictories();
    getUserDefeats();
    notifyListeners();
  }

  Future<void> insertGamesData(GamesData gamesListData) async {
    editGameData(gamesListData, true);
    this.gamesListData.insert(0, gamesListData);
    notifyListeners();
  }

  Future<void> insertDtaData(DTAData game) async {
    editDTAData(game, true);
    this.dtaListData.insert(0, game);
    notifyListeners();
  }

  Future<void> updateHeroesData(HeroesData heroesListData) async {
    updateHeroData(heroesListData);
    this.heroesListData.removeWhere((item) => item.name == heroesListData.name);
    this.heroesListData.insert(0, heroesListData);
    getUserVictories();
    getUserDefeats();
    notifyListeners();
  }

  Future<void> updateDtaData(DTAData game) async {
    updateFirebaseDtaData(game);
    this.dtaListData.removeWhere((item) => item.id == game.id);
    this.dtaListData.insert(0, game);
    notifyListeners();
  }

  Future<void> updateFriendsData(FriendsData friend) async {
    updateFriendData(friend);
    this.friendsListData.removeWhere((item) => item.name == friend.name);
    this.friendsListData.insert(0, friend);
    notifyListeners();
  }

  void expandScoreboard(DTAData game, int index) async {
    game.scoreboards[index].isExpanded = !game.scoreboards[index].isExpanded;
    notifyListeners();
  }

  void addCardToPlayer(
      Player player, String card, DTAData game, cardType type) {
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
    updateDtaData(game);
    notifyListeners();
  }

  void removeCardFromPlayer(Player player, String card, DTAData game) {
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

    updateDtaData(game);
    notifyListeners();
  }

  void expandPlayer(DTAData game, int index) async {
    game.players[index].isExpanded = !game.players[index].isExpanded;
    notifyListeners();
  }

  Future<void> deleteHeroesData(HeroesData hero) async {
    editHeroData(hero, false);
    this.heroesListData.removeWhere(
        (item) => item.name == hero.name);
    getUserVictories();
    getUserDefeats();
    notifyListeners();
  }

  Future<void> deleteFriendsData(FriendsData? friend) async {
    editFriendData(friend ?? FriendsData(), false);
    this.friendsListData.removeWhere((item) => item.name == friend?.name);
    notifyListeners();
  }

  Future<void> deleteGamesData(GamesData game) async {
    editGameData(game, false);
    this.gamesListData.isNotEmpty
        ? this.gamesListData.removeWhere((item) => item.id == game.id)
        : null;
    notifyListeners();
  }

  Future<void> deleteDTAData(DTAData dta) async {
    editDTAData(dta, false);
    this.dtaListData.removeWhere((item) => item.id == dta.id);
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

  Future<void> editGameData(GamesData game, bool save) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        return;
      }

      String userEmail = currentUser.email!;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference userDoc = firestore.collection('backups').doc(userEmail);

      await firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userDoc);

        if (snapshot.exists) {
          // Vérifier si 'gamesListData' existe et n'est pas nul
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

          List<GamesData> firebaseGamesData = [];

          if (data.containsKey('gamesListData') && data['gamesListData'] != null) {
            firebaseGamesData = (data['gamesListData'] as List)
                .map((item) => GamesData.fromMap(item))
                .toList();
          }

          if (save) {
            firebaseGamesData.insert(0, game);
          } else {
            firebaseGamesData.removeWhere((item) => item.id == game.id);
          }

          List<Map<String, dynamic>> gamesData =
          firebaseGamesData.map((game) => game.toMap()).toList();

          transaction.update(userDoc, {
            'gamesListData': gamesData,
            'timestamp': FieldValue.serverTimestamp(),
          });
        } else {
          List<GamesData> firebaseGamesData = [];

          if (save) {
            firebaseGamesData.add(game);
          }

          List<Map<String, dynamic>> gamesData =
          firebaseGamesData.map((game) => game.toMap()).toList();

          transaction.set(userDoc, {
            'gamesListData': gamesData,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      await FirebaseAnalytics.instance.logEvent(
        name: "error_game",
        parameters: {
          "error": e.toString(),
        },
      );
    }
  }

  Future<void> editHeroData(HeroesData hero, bool save) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        return;
      }

      String userEmail = currentUser.email!;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference userDoc =
          firestore.collection('backups').doc(userEmail);

      await firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userDoc);

        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

          List<HeroesData> firebaseHeroesData = (data['heroesListData'] as List)
              .map((item) => HeroesData.fromMap(item))
              .toList();
          if (save) {
            firebaseHeroesData.insert(0, hero);
          } else {
            firebaseHeroesData.removeWhere((item) => item.name == hero.name);
          }

          List<Map<String, dynamic>> heroesData =
              firebaseHeroesData.map((hero) => hero.toMap()).toList();

          transaction.update(userDoc, {
            'heroesListData': heroesData,
            'timestamp': FieldValue.serverTimestamp(),
          });
        } else {
          List<Map<String, dynamic>> heroesData =
              heroesListData.map((hero) => hero.toMap()).toList();

          transaction.set(userDoc, {
            'heroesListData': heroesData,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      await FirebaseAnalytics.instance.logEvent(
        name: "error_hero",
        parameters: {
          "error": e.toString(),
        },
      );
    }
  }

  Future<void> deleteHeroData(String hero) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        return;
      }

      String userEmail = currentUser.email!;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference userDoc =
          firestore.collection('backups').doc(userEmail);
      await firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userDoc);

        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

          List<HeroesData> firebaseHeroesData = (data['heroesListData'] as List)
              .map((item) => HeroesData.fromMap(item))
              .toList();
          firebaseHeroesData.removeWhere(
                  (item) => p.basenameWithoutExtension(item.imagePath) == hero);

          List<Map<String, dynamic>> heroesData =
          firebaseHeroesData.map((hero) => hero.toMap()).toList();

          transaction.update(userDoc, {
            'heroesListData': heroesData,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      await FirebaseAnalytics.instance.logEvent(
        name: "error_hero",
        parameters: {
          "error": e.toString(),
        },
      );
    }
  }

  Future<void> editFriendData(FriendsData friend, bool save) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        return;
      }

      String userEmail = currentUser.email!;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference userDoc =
          firestore.collection('backups').doc(userEmail);

      await firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userDoc);

        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

          List<FriendsData> firebaseFriendsData =
              (data['friendsListData'] as List)
                  .map((item) => FriendsData.fromMap(item))
                  .toList();
          if (save) {
            firebaseFriendsData.insert(0, friend);
          } else {
            firebaseFriendsData.removeWhere((item) => item.name == friend.name);
          }

          List<Map<String, dynamic>> friendsData =
              firebaseFriendsData.map((dta) => dta.toMap()).toList();

          transaction.update(userDoc, {
            'friendsListData': friendsData,
            'timestamp': FieldValue.serverTimestamp(),
          });
        } else {
          List<Map<String, dynamic>> friendsData =
              friendsListData.map((dta) => dta.toMap()).toList();

          transaction.set(userDoc, {
            'friendsListData': friendsData,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      await FirebaseAnalytics.instance.logEvent(
        name: "error_friend",
        parameters: {
          "error": e.toString(),
        },
      );
    }
  }

  Future<void> editDTAData(DTAData dta, bool save) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        return;
      }

      String userEmail = currentUser.email!;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference userDoc =
          firestore.collection('backups').doc(userEmail);

      await firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userDoc);

        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

          List<DTAData> firebaseDtaData = (data['dtaListData'] as List)
              .map((item) => DTAData.fromMap(item))
              .toList();
          if (save) {
            firebaseDtaData.insert(0, dta);
          } else {
            firebaseDtaData
                .removeWhere((item) => item.teamName == dta.teamName);
          }

          List<Map<String, dynamic>> dtaData =
              firebaseDtaData.map((dta) => dta.toMap()).toList();

          transaction.update(userDoc, {
            'dtaListData': dtaData,
            'timestamp': FieldValue.serverTimestamp(),
          });
        } else {
          List<Map<String, dynamic>> dtaData =
              dtaListData.map((dta) => dta.toMap()).toList();

          transaction.set(userDoc, {
            'dtaListData': dtaData,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      await FirebaseAnalytics.instance.logEvent(
        name: "error_dta",
        parameters: {
          "error": e.toString(),
        },
      );
    }
  }

  Future<void> updateHeroData(HeroesData hero) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        return;
      }

      String userEmail = currentUser.email!;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference userDoc =
          firestore.collection('backups').doc(userEmail);
      await firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userDoc);

        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

          List<HeroesData> firebaseHeroesData = (data['heroesListData'] as List)
              .map((item) => HeroesData.fromMap(item))
              .toList();
          firebaseHeroesData.removeWhere((item) => item.name == hero.name);
          firebaseHeroesData.insert(0, hero);

          List<Map<String, dynamic>> heroesData =
          firebaseHeroesData.map((hero) => hero.toMap()).toList();

          transaction.update(userDoc, {
            'heroesListData': heroesData,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      await FirebaseAnalytics.instance.logEvent(
        name: "error_hero",
        parameters: {
          "error": e.toString(),
        },
      );
    }
  }

  Future<void> updateFirebaseDtaData(DTAData game) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        return;
      }

      String userEmail = currentUser.email!;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference userDoc =
          firestore.collection('backups').doc(userEmail);
      await firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userDoc);

        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

          List<DTAData> firebaseDtaData = (data['dtaListData'] as List)
              .map((item) => DTAData.fromMap(item))
              .toList();
          firebaseDtaData.removeWhere((item) => item.id == game.id);
          firebaseDtaData.insert(0, game);

          List<Map<String, dynamic>> dtaData =
          firebaseDtaData.map((dta) => dta.toMap()).toList();

          transaction.update(userDoc, {
            'dtaListData': dtaData,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      await FirebaseAnalytics.instance.logEvent(
        name: "error_dta",
        parameters: {
          "error": e.toString(),
        },
      );
    }
  }

  Future<void> updateFriendData(FriendsData friend) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        return;
      }

      String userEmail = currentUser.email!;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference userDoc =
          firestore.collection('backups').doc(userEmail);
      await firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userDoc);

        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

          List<FriendsData> firebaseFriendsData =
          (data['friendsListData'] as List)
              .map((item) => FriendsData.fromMap(item))
              .toList();
          firebaseFriendsData.removeWhere((item) => item.name == friend.name);
          firebaseFriendsData.insert(0, friend);

          List<Map<String, dynamic>> friendsData =
          firebaseFriendsData.map((dta) => dta.toMap()).toList();

          transaction.update(userDoc, {
            'friendsListData': friendsData,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      await FirebaseAnalytics.instance.logEvent(
        name: "error_friend",
        parameters: {
          "error": e.toString(),
        },
      );
    }
  }

  Future<void> backupDataToFirestore(BuildContext context) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        return;
      }

      String userEmail = currentUser.email!;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference userDoc =
          firestore.collection('backups').doc(userEmail);

      await firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userDoc);

        if (!snapshot.exists) {
          var gamesDAOListData = await gamesDAO.getGamesListData();
          var heroesDAOListData = await heroesDAO.getHeroesListData();
          var dtaDAOListData = await dtaDAO.getDTAListData();
          var friendsDAOListData = await friendsDAO.getFriendsData();

          List<Map<String, dynamic>> gamesData = [];
          gamesData = gamesDAOListData.map((game) => game.toMap()).toList();
          List<Map<String, dynamic>> heroesData = [];
          heroesData = heroesDAOListData.map((hero) => hero.toMap()).toList();
          List<Map<String, dynamic>> dtaData = [];
          dtaData = dtaDAOListData.map((dta) => dta.toMap()).toList();
          List<Map<String, dynamic>> friendsData = [];
          friendsData = friendsDAOListData.map((dta) => dta.toMap()).toList();

          transaction.set(userDoc, {
            'gamesListData': gamesData,
            'heroesListData': heroesData,
            'dtaListData': dtaData,
            'friendsListData': friendsData,
            'timestamp': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('backup_done'.tr(context))),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during backup: $e')),
      );
    }
  }
}
