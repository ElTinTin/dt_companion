import '../companion/match_view.dart';

class GamesListData {
  GamesListData(
      {this.playerOneImagePath = '',
      this.playerOne = '',
      this.playerTwoImagePath = '',
      this.playerTwo = '',
      this.playerThreeImagePath = '',
      this.playerThree = '',
      this.playerFourImagePath = '',
      this.playerFour = '',
      this.playerFiveImagePath = '',
      this.playerFive = '',
      this.playerSixImagePath = '',
      this.playerSix = '',
      this.gamemode = Mode.onevsone,
      this.id = 0101,
      this.winner = '',
      this.date = 0});

  String playerOneImagePath;
  String playerOne;
  String playerTwoImagePath;
  String playerTwo;
  String playerThreeImagePath;
  String playerThree;
  String playerFourImagePath;
  String playerFour;
  String playerFiveImagePath;
  String playerFive;
  String playerSixImagePath;
  String playerSix;
  Mode gamemode;
  int id;
  String winner;
  int date;

  Map<String, dynamic> toMap() {
    return {
      'playerOneImagePath': playerOneImagePath,
      'playerOne': playerOne,
      'playerTwoImagePath': playerTwoImagePath,
      'playerTwo': playerTwo,
      'playerThreeImagePath': playerThreeImagePath,
      'playerThree': playerThree,
      'playerFourImagePath': playerFourImagePath,
      'playerFour': playerFour,
      'playerFiveImagePath': playerFiveImagePath,
      'playerFive': playerFive,
      'playerSixImagePath': playerSixImagePath,
      'playerSix': playerSix,
      'gamemode': gamemode.toString().split('.').last,
      'id': id,
      'winner': winner,
      'date': date
    };
  }

  factory GamesListData.fromMap(Map<String, dynamic> map) {
    return GamesListData(
        playerOneImagePath: map['playerOneImagePath'] ?? '',
        playerOne: map['playerOne'] ?? '',
        playerTwoImagePath: map['playerTwoImagePath'] ?? '',
        playerTwo: map['playerTwo'] ?? '',
        playerThreeImagePath: map['playerThreeImagePath'] ?? '',
        playerThree: map['playerThree'] ?? '',
        playerFourImagePath: map['playerFourImagePath'] ?? '',
        playerFour: map['playerFour'] ?? '',
        playerFiveImagePath: map['playerFiveImagePath'] ?? '',
        playerFive: map['playerFive'] ?? '',
        playerSixImagePath: map['playerSixImagePath'] ?? '',
        playerSix: map['playerSix'] ?? '',
        gamemode: Mode.values
            .firstWhere((e) => e.toString().split('.').last == map['gamemode']),
        id: map['id'] ?? 0101,
        winner: map['winner'] ?? '',
        date: map['date'] ?? 0);
  }
}
