import 'dart:convert';

class DTAListData {
  int id;
  String teamName;
  int campaignScore;
  List<Player> players;
  bool legacyMode;
  int difficulty;
  bool mythic;
  int date;
  List<Scoreboard> scoreboards;
  bool inprogress;
  List<String> commonCards;
  List<String> rareCards;
  List<String> epicCards;
  List<String> legendaryCards;

  DTAListData({
    required this.id,
    required this.teamName,
    required this.campaignScore,
    required this.players,
    required this.legacyMode,
    required this.difficulty,
    required this.mythic,
    required this.date,
    required this.scoreboards,
    required this.inprogress,
    required this.commonCards,
    required this.rareCards,
    required this.epicCards,
    required this.legendaryCards,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teamName': teamName,
      'campaignScore': campaignScore,
      'players': json.encode(players.map((player) => player.toMap()).toList()),
      'legacyMode': legacyMode ? 1 : 0,
      'difficulty': difficulty,
      'mythic': mythic ? 1 : 0,
      'date': date,
      'scoreboards': json
          .encode(scoreboards.map((scoreboard) => scoreboard.toMap()).toList()),
      'inprogress': inprogress ? 1 : 0,
      'commonCards': json.encode(commonCards),
      'rareCards': json.encode(rareCards),
      'epicCards': json.encode(epicCards),
      'legendaryCards': json.encode(legendaryCards),
    };
  }

  factory DTAListData.fromMap(Map<String, dynamic> map) {
    var playersList = (json.decode(map['players']) as List)
        .map((playerMap) => Player.fromMap(playerMap))
        .toList();
    var scoreboardList = (json.decode(map['scoreboards']) as List)
        .map((scoreboardMap) => Scoreboard.fromMap(scoreboardMap))
        .toList();
    var commonCards =
        (json.decode(map['commonCards']) as List<dynamic>).cast<String>();
    var rareCards =
        (json.decode(map['rareCards']) as List<dynamic>).cast<String>();
    var epicCards =
        (json.decode(map['epicCards']) as List<dynamic>).cast<String>();
    var legendaryCards =
        (json.decode(map['legendaryCards']) as List<dynamic>).cast<String>();

    return DTAListData(
      id: map['id'],
      teamName: map['teamName'],
      campaignScore: map['campaignScore'],
      players: playersList,
      legacyMode: map['legacyMode'] == 1,
      difficulty: map['difficulty'],
      mythic: map['mythic'] == 1,
      date: map['date'] ?? 0,
      scoreboards: scoreboardList,
      inprogress: map['inprogress'] == 1,
      commonCards: commonCards,
      rareCards: rareCards,
      epicCards: epicCards,
      legendaryCards: legendaryCards,
    );
  }

  String toJson() => json.encode(toMap());

  factory DTAListData.fromJson(String source) =>
      DTAListData.fromMap(json.decode(source));
}

class Player {
  String name;
  String character;
  List<String> commonCards;
  List<String> rareCards;
  List<String> epicCards;
  List<String> legendaryCards;
  bool isExpanded;

  Player(
      {required this.name,
      required this.character,
      required this.commonCards,
      required this.rareCards,
      required this.epicCards,
      required this.legendaryCards,
      this.isExpanded = false});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'character': character,
      'commonCards': json.encode(commonCards),
      'rareCards': json.encode(rareCards),
      'epicCards': json.encode(epicCards),
      'legendaryCards': json.encode(legendaryCards),
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    var commonCards =
        (json.decode(map['commonCards']) as List<dynamic>).cast<String>();
    var rareCards =
        (json.decode(map['rareCards']) as List<dynamic>).cast<String>();
    var epicCards =
        (json.decode(map['epicCards']) as List<dynamic>).cast<String>();
    var legendaryCards =
        (json.decode(map['legendaryCards']) as List<dynamic>).cast<String>();

    return Player(
      name: map['name'],
      character: map['character'],
      commonCards: commonCards,
      rareCards: rareCards,
      epicCards: epicCards,
      legendaryCards: legendaryCards,
    );
  }

  String toJson() => json.encode(toMap());

  factory Player.fromJson(String source) => Player.fromMap(json.decode(source));
}

class Scoreboard {
  int totalScore;
  int remainingSalve;
  int scenarioNumber;
  int unspentGold;
  int unclaimedBossLoot;
  bool exploredAll;
  bool won;
  bool isExpanded;

  Scoreboard(
      {required this.totalScore,
      required this.remainingSalve,
      required this.scenarioNumber,
      required this.unspentGold,
      required this.unclaimedBossLoot,
      required this.exploredAll,
      required this.won,
      this.isExpanded = false});

  Map<String, dynamic> toMap() {
    return {
      'totalScore': totalScore,
      'remainingSalve': remainingSalve,
      'scenarioNumber': scenarioNumber,
      'unspentGold': unspentGold,
      'unclaimedBossLoot': unclaimedBossLoot,
      'exploredAll': exploredAll ? 1 : 0,
      'won': won ? 1 : 0,
    };
  }

  factory Scoreboard.fromMap(Map<String, dynamic> map) {
    return Scoreboard(
      totalScore: map['totalScore'],
      remainingSalve: map['remainingSalve'],
      scenarioNumber: map['scenarioNumber'],
      unspentGold: map['unspentGold'],
      unclaimedBossLoot: map['unclaimedBossLoot'],
      exploredAll: map['exploredAll'] == 1,
      won: map['won'] == 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory Scoreboard.fromJson(String source) =>
      Scoreboard.fromMap(json.decode(source));
}
