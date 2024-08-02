import '../companion/match_view.dart';

class GamesData {
  GamesData(
      {this.playerOneImagePath = '',
        this.playerOne = '',
        this.playerOneUltimates = 0,
        this.playerTwoImagePath = '',
        this.playerTwo = '',
        this.playerTwoUltimates = 0,
        this.playerThreeImagePath = '',
        this.playerThree = '',
        this.playerThreeUltimates = 0,
        this.playerFourImagePath = '',
        this.playerFour = '',
        this.playerFourUltimates = 0,
        this.playerFiveImagePath = '',
        this.playerFive = '',
        this.playerFiveUltimates = 0,
        this.playerSixImagePath = '',
        this.playerSix = '',
        this.playerSixUltimates = 0,
        this.gamemode = Mode.onevsone,
        this.id = 0101,
        this.winner = '',
        this.date = 0,
        this.winnerHealth = 0});

  String playerOneImagePath;
  String playerOne;
  int playerOneUltimates;
  String playerTwoImagePath;
  String playerTwo;
  int playerTwoUltimates;
  String playerThreeImagePath;
  String playerThree;
  int playerThreeUltimates;
  String playerFourImagePath;
  String playerFour;
  int playerFourUltimates;
  String playerFiveImagePath;
  String playerFive;
  int playerFiveUltimates;
  String playerSixImagePath;
  String playerSix;
  int playerSixUltimates;
  Mode gamemode;
  int id;
  String winner;
  int winnerHealth;
  int date;

  Map<String, dynamic> toMap() {
    return {
      'playerOneImagePath': playerOneImagePath,
      'playerOne': playerOne,
      'playerOneUltimates': playerOneUltimates,
      'playerTwoImagePath': playerTwoImagePath,
      'playerTwo': playerTwo,
      'playerTwoUltimates': playerTwoUltimates,
      'playerThreeImagePath': playerThreeImagePath,
      'playerThree': playerThree,
      'playerThreeUltimates': playerThreeUltimates,
      'playerFourImagePath': playerFourImagePath,
      'playerFour': playerFour,
      'playerFourUltimates': playerFourUltimates,
      'playerFiveImagePath': playerFiveImagePath,
      'playerFive': playerFive,
      'playerFiveUltimates': playerFiveUltimates,
      'playerSixImagePath': playerSixImagePath,
      'playerSix': playerSix,
      'playerSixUltimates': playerSixUltimates,
      'gamemode': gamemode.toString().split('.').last,
      'id': id,
      'winner': winner,
      'date': date,
      'winnerHealth': winnerHealth
    };
  }

  factory GamesData.fromMap(Map<String, dynamic> map) {
    return GamesData(
        playerOneImagePath: map['playerOneImagePath'] ?? '',
        playerOne: map['playerOne'] ?? '',
        playerOneUltimates: map['playerOneUltimates'] ?? 0,
        playerTwoImagePath: map['playerTwoImagePath'] ?? '',
        playerTwo: map['playerTwo'] ?? '',
        playerTwoUltimates: map['playerTwoUltimates'] ?? 0,
        playerThreeImagePath: map['playerThreeImagePath'] ?? '',
        playerThree: map['playerThree'] ?? '',
        playerThreeUltimates: map['playerThreeUltimates'] ?? 0,
        playerFourImagePath: map['playerFourImagePath'] ?? '',
        playerFour: map['playerFour'] ?? '',
        playerFourUltimates: map['playerFourUltimates'] ?? 0,
        playerFiveImagePath: map['playerFiveImagePath'] ?? '',
        playerFive: map['playerFive'] ?? '',
        playerFiveUltimates: map['playerFiveUltimates'] ?? 0,
        playerSixImagePath: map['playerSixImagePath'] ?? '',
        playerSix: map['playerSix'] ?? '',
        playerSixUltimates: map['playerSixUltimates'] ?? 0,
        gamemode: Mode.values
            .firstWhere((e) => e.toString().split('.').last == map['gamemode']),
        id: map['id'] ?? 0101,
        winner: map['winner'] ?? '',
        date: map['date'] ?? 0,
        winnerHealth: map['winnerHealth'] ?? 0
    );
  }
}

