import 'dart:math';
import 'package:dt_companion/dt_companion/companion_app_home_screen.dart';
import 'package:dt_companion/dt_companion/companion_app_theme.dart';
import 'package:dt_companion/dt_companion/extension/localization_extension.dart';
import 'package:dt_companion/dt_companion/models/friends_data.dart';
import 'package:dt_companion/dt_companion/models/games_data.dart';
import 'package:dt_companion/dt_companion/models/heroes_data.dart';
import 'package:dt_companion/dt_companion/service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:overlay_tooltip/overlay_tooltip.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ui_view/tooltip.dart';

enum Mode { onevsone, twovstwo, koth, threevsthree }

class MatchView extends StatefulWidget {
  const MatchView({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  _MatchViewState createState() => _MatchViewState();
}

class _MatchViewState extends State<MatchView> with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;
  double topBarOpacity = 0.0;
  final ScrollController scrollController = ScrollController();
  final TooltipController _controller = TooltipController();

  // Player 1 - You
  Character? _playerOne;
  TextEditingController _playerOneUltimates = TextEditingController(text: '0');
  // Player 2
  Character? _playerTwo;
  TextEditingController _player2Controller = TextEditingController();
  FriendsData? _friendsTwo;
  TextEditingController _playerTwoUltimates = TextEditingController(text: '0');
  // PLayer 3
  Character? _playerThree;
  TextEditingController _player3Controller = TextEditingController();
  FriendsData? _friendsThree;
  TextEditingController _playerThreeUltimates =
      TextEditingController(text: '0');
  // PLayer 4
  Character? _playerFour;
  TextEditingController _player4Controller = TextEditingController();
  FriendsData? _friendsFour;
  TextEditingController _playerFourUltimates = TextEditingController(text: '0');
  // Player 5
  Character? _playerFive;
  TextEditingController _player5Controller = TextEditingController();
  FriendsData? _friendsFive;
  TextEditingController _playerFiveUltimates = TextEditingController(text: '0');
  // Player 6
  Character? _playerSix;
  TextEditingController _player6Controller = TextEditingController();
  FriendsData? _friendsSix;
  TextEditingController _playerSixUltimates = TextEditingController(text: '0');

  Mode _gamemode = Mode.onevsone;
  String? _winningTeam;
  bool tooltipStatus = true;

  int _kothPlayers = 3;
  int _winnerHealth = 1;

  List<Character> randomCharacters = List<Character>.from(Character.values);

  bool get _isFormValid {
    switch (_gamemode) {
      case Mode.onevsone:
        return _playerOne != null && _playerTwo != null && _winningTeam != null;
      case Mode.twovstwo:
        return _playerOne != null &&
            _playerTwo != null &&
            _playerThree != null &&
            _playerFour != null &&
            _winningTeam != null;
      case Mode.koth:
        if (_kothPlayers == 3) {
          return _playerOne != null &&
              _playerTwo != null &&
              _playerThree != null &&
              _winningTeam != null;
        } else if (_kothPlayers == 4) {
          return _playerOne != null &&
              _playerTwo != null &&
              _playerThree != null &&
              _playerFour != null &&
              _winningTeam != null;
        } else if (_kothPlayers == 5) {
          return _playerOne != null &&
              _playerTwo != null &&
              _playerThree != null &&
              _playerFour != null &&
              _playerFive != null &&
              _winningTeam != null;
        } else {
          return _playerOne != null &&
              _playerTwo != null &&
              _playerThree != null &&
              _playerFour != null &&
              _playerFive != null &&
              _playerSix != null &&
              _winningTeam != null;
        }
      case Mode.threevsthree:
        return _playerOne != null &&
            _playerTwo != null &&
            _playerThree != null &&
            _playerFour != null &&
            _playerFive != null &&
            _playerSix != null &&
            _winningTeam != null;
    }
  }

  List<String> get teams {
    if (_gamemode == Mode.koth) {
      return [
        'You'.tr(context),
        'Player 2'.tr(context),
        'Player 3'.tr(context)
      ];
    } else if (_gamemode == Mode.twovstwo || _gamemode == Mode.threevsthree) {
      return ['Team 1'.tr(context), 'Team 2'.tr(context), 'Draw'.tr(context)];
    } else {
      return ['You'.tr(context), 'Player 2'.tr(context), 'Draw'.tr(context)];
    }
  }

  Future<void> _setInAppReviewStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("inAppReviewStatus", 1);
  }

  Future<bool> _shouldShowTooltip() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasShownTooltip = prefs.getBool('hasShownTooltip') ?? false;

    if (!hasShownTooltip) {
      await prefs.setBool('hasShownTooltip', true);
      return true;
    }
    return false;
  }

  Future<void> _analytics() async {
    // Analytics
    await FirebaseAnalytics.instance.logScreenView(screenName: 'MatchView');
  }

  void _scrollALittle() {
    scrollController.animateTo(
      scrollController.position.pixels + 1,
      duration: Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));

    _analytics();

    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() {
            topBarOpacity = scrollController.offset / 24;
          });
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int generateRandomId() {
    Random random = Random();
    int min = 1000000; // 7 digits minimum value (1 followed by 6 zeros)
    int max = 9999999; // 7 digits maximum value (7 nines)
    return min + random.nextInt(max - min + 1);
  }

  String getPlayer(
      TextEditingController controller, int player, FriendsData? friend) {
    if (friend != null) {
      return friend.name;
    } else {
      return controller.text != "" ? controller.text : "Player $player";
    }
  }

  void updatePlayerData(FriendsData? playerData,
      TextEditingController controller, UserService userService) {
    bool winner = (_winningTeam == "You".tr(context) ||
        _winningTeam == "Team 1".tr(context));

    if (playerData != null) {
      if (_winningTeam != 'Draw'.tr(context)) {
        if (winner) {
          if (playerData == _friendsTwo) {
            playerData.victoriesAgainst += 1;
          } else if (playerData == _friendsThree) {
            if (_gamemode == Mode.twovstwo || _gamemode == Mode.threevsthree) {
              playerData.victoriesWith += 1;
            } else {
              playerData.defeatsAgainst += 1;
            }
          } else if (playerData == _friendsFour) {
            playerData.victoriesAgainst += 1;
          } else if (playerData == _friendsFive) {
            if (_gamemode == Mode.twovstwo || _gamemode == Mode.threevsthree) {
              playerData.defeatsWith += 1;
            } else {
              playerData.victoriesAgainst += 1;
            }
          } else {
            playerData.victoriesAgainst += 1;
          }
        } else {
          if (playerData == _friendsTwo) {
            playerData.defeatsAgainst += 1;
          } else if (playerData == _friendsThree) {
            if (_gamemode == Mode.twovstwo || _gamemode == Mode.threevsthree) {
              playerData.defeatsWith += 1;
            } else {
              playerData.defeatsAgainst += 1;
            }
          } else if (playerData == _friendsFour) {
            playerData.defeatsAgainst += 1;
          } else if (playerData == _friendsFive) {
            if (_gamemode == Mode.twovstwo || _gamemode == Mode.threevsthree) {
              playerData.defeatsWith += 1;
            } else {
              playerData.defeatsAgainst += 1;
            }
          } else {
            playerData.defeatsAgainst += 1;
          }
        }
      } else {
        if (playerData == _friendsTwo) {
          playerData.drawsAgainst += 1;
        } else if (playerData == _friendsThree) {
          if (_gamemode == Mode.twovstwo || _gamemode == Mode.threevsthree) {
            playerData.drawsWith += 1;
          } else {
            playerData.drawsAgainst += 1;
          }
        } else if (playerData == _friendsFour) {
          playerData.drawsAgainst += 1;
        } else if (playerData == _friendsFive) {
          if (_gamemode == Mode.twovstwo || _gamemode == Mode.threevsthree) {
            playerData.drawsWith += 1;
          } else {
            playerData.drawsAgainst += 1;
          }
        } else {
          playerData.drawsAgainst += 1;
        }
      }
      userService.updateFriendsData(playerData);
    } else if (controller.value.text != "") {
      FriendsData newPlayer = FriendsData(name: controller.text);
      if (_winningTeam != 'Draw'.tr(context)) {
        if (winner) {
          if (controller == _player2Controller) {
            newPlayer.victoriesAgainst += 1;
          } else if (controller == _player3Controller) {
            if (_gamemode == Mode.twovstwo || _gamemode == Mode.threevsthree) {
              newPlayer.victoriesWith += 1;
            } else {
              newPlayer.victoriesAgainst += 1;
            }
          } else if (controller == _player4Controller) {
            newPlayer.victoriesAgainst += 1;
          } else if (controller == _player5Controller) {
            if (_gamemode == Mode.twovstwo || _gamemode == Mode.threevsthree) {
              newPlayer.victoriesWith += 1;
            } else {
              newPlayer.defeatsAgainst += 1;
            }
          } else {
            newPlayer.victoriesAgainst += 1;
          }
        } else {
          if (controller == _player2Controller) {
            newPlayer.defeatsAgainst += 1;
          } else if (newPlayer == _friendsThree) {
            if (_gamemode == Mode.twovstwo || _gamemode == Mode.threevsthree) {
              newPlayer.defeatsWith += 1;
            } else {
              newPlayer.defeatsAgainst += 1;
            }
          } else if (controller == _player4Controller) {
            newPlayer.defeatsAgainst += 1;
          } else if (controller == _player5Controller) {
            if (_gamemode == Mode.twovstwo || _gamemode == Mode.threevsthree) {
              newPlayer.defeatsWith += 1;
            } else {
              newPlayer.defeatsAgainst += 1;
            }
          } else {
            newPlayer.defeatsAgainst += 1;
          }
        }
      } else {
        if (newPlayer == _friendsTwo) {
          newPlayer.drawsAgainst += 1;
        } else if (newPlayer == _friendsThree) {
          if (_gamemode == Mode.twovstwo || _gamemode == Mode.threevsthree) {
            newPlayer.drawsWith += 1;
          } else {
            newPlayer.drawsAgainst += 1;
          }
        } else if (newPlayer == _friendsFour) {
          newPlayer.drawsAgainst += 1;
        } else if (newPlayer == _friendsFive) {
          if (_gamemode == Mode.twovstwo || _gamemode == Mode.threevsthree) {
            newPlayer.drawsWith += 1;
          } else {
            newPlayer.drawsAgainst += 1;
          }
        } else {
          newPlayer.drawsAgainst += 1;
        }
      }
      userService.insertFriendsData(newPlayer);
    }
  }

  bool isNameUnique(String name, List<FriendsData> friends) {
    return !friends.map((e) => e.name).contains(name);
  }

  List<String> findNonUniqueNames(UserService userService) {
    List<String> nonUniqueNames = [];

    if (!isNameUnique(_player2Controller.text, userService.friendsListData)) {
      nonUniqueNames.add(_player2Controller.text);
    }
    if (!isNameUnique(_player3Controller.text, userService.friendsListData)) {
      nonUniqueNames.add(_player3Controller.text);
    }
    if (!isNameUnique(_player4Controller.text, userService.friendsListData)) {
      nonUniqueNames.add(_player4Controller.text);
    }
    if (!isNameUnique(_player5Controller.text, userService.friendsListData)) {
      nonUniqueNames.add(_player5Controller.text);
    }
    if (!isNameUnique(_player6Controller.text, userService.friendsListData)) {
      nonUniqueNames.add(_player6Controller.text);
    }

    return nonUniqueNames;
  }

  Future<void> _submit(UserService userService) async {
    if (isNameUnique(_player2Controller.text, userService.friendsListData) &&
        isNameUnique(_player3Controller.text, userService.friendsListData) &&
        isNameUnique(_player4Controller.text, userService.friendsListData) &&
        isNameUnique(_player5Controller.text, userService.friendsListData) &&
        isNameUnique(_player6Controller.text, userService.friendsListData)) {
      if (_isFormValid) {
        var winner = (_winningTeam == "You".tr(context) ||
                _winningTeam == "Team 1".tr(context))
            ? true
            : false;

        var heroesData = HeroesData(
            name: _playerOne!.displayName,
            imagePath: "assets/dt_companion/${_playerOne!.name}.png",
            victories: 0,
            defeats: 0,
            draws: 0);

        try {
          try {
            HeroesData hero = userService.heroesListData
                .firstWhere((hero) => hero.name == heroesData.name);
            if (_winningTeam != 'Draw'.tr(context)) {
              if (winner) {
                heroesData.victories = hero.victories + 1;
                heroesData.defeats = hero.defeats;
                heroesData.draws = hero.draws;
              } else {
                heroesData.victories = hero.victories;
                heroesData.defeats = hero.defeats + 1;
                heroesData.draws = hero.draws;
              }
            } else {
              heroesData.victories = hero.victories;
              heroesData.defeats = hero.defeats;
              heroesData.draws = hero.draws + 1;
            }
            userService.updateHeroesData(heroesData);
          } catch (e) {
            if (_winningTeam != 'Draw'.tr(context)) {
              if (winner) {
                heroesData.victories += 1;
              } else {
                heroesData.defeats += 1;
              }
            } else {
              heroesData.draws += 1;
            }

            userService.insertHeroesData(heroesData);
          }
        } catch (e) {
          print(e);
        }

        try {
          var gameData = GamesData(
              playerOneImagePath: "assets/dt_companion/${_playerOne!.name}.png",
              playerOne: 'You',
              playerOneUltimates: int.parse(_playerOneUltimates.text),
              playerTwoImagePath: "assets/dt_companion/${_playerTwo!.name}.png",
              playerTwo: getPlayer(_player2Controller, 2, _friendsTwo),
              playerTwoUltimates: int.parse(_playerTwoUltimates.text),
              playerThreeImagePath: _playerThree != null
                  ? "assets/dt_companion/${_playerThree!.name}.png"
                  : "",
              playerThree: getPlayer(_player3Controller, 3, _friendsThree),
              playerThreeUltimates: int.parse(_playerThreeUltimates.text),
              playerFourImagePath: _playerFour != null
                  ? "assets/dt_companion/${_playerFour!.name}.png"
                  : "",
              playerFourUltimates: int.parse(_playerFourUltimates.text),
              playerFour: getPlayer(_player4Controller, 4, _friendsFour),
              playerFiveImagePath: _playerFive != null
                  ? "assets/dt_companion/${_playerFive!.name}.png"
                  : "",
              playerFive: getPlayer(_player5Controller, 5, _friendsFive),
              playerFiveUltimates: int.parse(_playerFiveUltimates.text),
              playerSixImagePath: _playerSix != null
                  ? "assets/dt_companion/${_playerSix!.name}.png"
                  : "",
              playerSix: getPlayer(_player6Controller, 6, _friendsSix),
              playerSixUltimates: int.parse(_playerSixUltimates.text),
              gamemode: _gamemode,
              id: generateRandomId(),
              winner: _winningTeam ?? "",
              winnerHealth: _winnerHealth,
              date: DateTime.now().millisecondsSinceEpoch);
          userService.insertGamesData(gameData);
        } catch (e) {
          print(e);
        }

        try {
          updatePlayerData(
              _friendsTwo, _player2Controller, userService); // Joueur 2
          updatePlayerData(_friendsThree, _player3Controller,
              userService); // Joueur 3, condition inversée
          updatePlayerData(
              _friendsFour, _player4Controller, userService); // Joueur 4
          updatePlayerData(_friendsFive, _player5Controller,
              userService); // Joueur 5, condition inversée
          updatePlayerData(
              _friendsSix, _player6Controller, userService); // Joueur 6
        } catch (e) {
          print(e);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('snack_match_submitted'.tr(context))),
        );

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CompanionAppHomeScreen(index: 0)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('snack_match_missing'.tr(context))),
        );
      }
    } else {
      List<String> nonUniqueNames = findNonUniqueNames(userService);
      String nonUniqueMessage = 'The following names are not unique: ${nonUniqueNames.join(', ')}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(nonUniqueMessage)));
    }
  }

  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.animationController!,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - topBarAnimation!.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        CompanionAppTheme.dark_grey.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: CompanionAppTheme.grey
                              .withOpacity(0.4 * topBarOpacity),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16 - 8.0 * topBarOpacity,
                            bottom: 12 - 8.0 * topBarOpacity),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            if (topBarOpacity < 0.1)
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: 32, right: 32, top: 0, bottom: 8),
                                  child: InkWell(
                                    onTap: () => {},
                                    child: SizedBox(
                                      width: 20,
                                      height: 88,
                                      child: FittedBox(
                                        child: Image.asset(
                                            'assets/dt_companion/dicethronelogo.webp'),
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                  )),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 8, right: 8, top: 24, bottom: 8),
                                child: Text(
                                  'game'.tr(context),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: CompanionAppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 26 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: CompanionAppTheme.lightText,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }

  Widget getMainListViewUI(UserService userService) {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.only(
        top: AppBar().preferredSize.height +
            MediaQuery.of(context).padding.top +
            80,
        bottom: 124 + MediaQuery.of(context).padding.bottom,
      ),
      itemCount: 1,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        widget.animationController?.forward();
        return SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      CupertinoSlidingSegmentedControl<Mode>(
                        backgroundColor:
                            CompanionAppTheme.dark_grey.withOpacity(0.5),
                        thumbColor: CompanionAppTheme.lightText,
                        children: {
                          Mode.onevsone: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 16.0),
                            child: Text(
                              '1v1',
                              style: TextStyle(
                                fontFamily: CompanionAppTheme.fontName,
                                fontWeight: _gamemode == Mode.onevsone
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: _gamemode == Mode.onevsone ? 18 : 14,
                                letterSpacing: 0.2,
                                color: _gamemode == Mode.onevsone
                                    ? CompanionAppTheme.darkerText
                                    : CompanionAppTheme.lightText,
                              ),
                            ),
                          ),
                          Mode.twovstwo: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 16.0),
                            child: Text(
                              '2v2',
                              style: TextStyle(
                                fontFamily: CompanionAppTheme.fontName,
                                fontWeight: _gamemode == Mode.twovstwo
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: _gamemode == Mode.twovstwo ? 18 : 14,
                                letterSpacing: 0.2,
                                color: _gamemode == Mode.twovstwo
                                    ? CompanionAppTheme.darkerText
                                    : CompanionAppTheme.lightText,
                              ),
                            ),
                          ),
                          Mode.koth: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 16.0),
                            child: Text(
                              'KOTH',
                              style: TextStyle(
                                fontFamily: CompanionAppTheme.fontName,
                                fontWeight: _gamemode == Mode.koth
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: _gamemode == Mode.koth ? 18 : 14,
                                letterSpacing: 0.2,
                                color: _gamemode == Mode.koth
                                    ? CompanionAppTheme.darkerText
                                    : CompanionAppTheme.lightText,
                              ),
                            ),
                          ),
                          Mode.threevsthree: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 16.0),
                            child: Text(
                              '3v3',
                              style: TextStyle(
                                fontFamily: CompanionAppTheme.fontName,
                                fontWeight: _gamemode == Mode.threevsthree
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize:
                                    _gamemode == Mode.threevsthree ? 18 : 14,
                                letterSpacing: 0.2,
                                color: _gamemode == Mode.threevsthree
                                    ? CompanionAppTheme.darkerText
                                    : CompanionAppTheme.lightText,
                              ),
                            ),
                          ),
                        },
                        onValueChanged: (Mode? value) {
                          if (value != null) {
                            setState(() {
                              _gamemode = value;
                            });
                          }
                        },
                        groupValue: _gamemode,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          Spacer(),
                          Padding(
                              padding: const EdgeInsets.only(
                                  right: 16, bottom: 8),
                              child: InkWell(
                                onTap: () => {
                                  showModalBottomSheet<void>(
                                    context: context,
                                    isScrollControlled: true,
                                    builder:
                                        (BuildContext context) {
                                      return FractionallySizedBox(
                                        heightFactor: 0.8,
                                        child:
                                        randomCharacterSelector(
                                            userService),
                                      );
                                    },
                                  )
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 0,
                                      right: 16,
                                      top: 0,
                                      bottom: 0),
                                  child: SizedBox(
                                    width: 54,
                                    height: 54,
                                    child: Stack(
                                      children: [
                                        ClipOval(
                                          child: Container(
                                            width: 54,
                                            height: 54,
                                            decoration: BoxDecoration(
                                              color: CompanionAppTheme.dark_grey,
                                              borderRadius: BorderRadius.circular(27),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: ClipOval(
                                            child: Image.asset(
                                              'assets/dt_companion/question-mark.png',
                                              width: 42,
                                              height: 42,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      if (_gamemode == Mode.koth) ...[
                        Text(
                          'dta_add_number_players'.tr(context),
                          style: TextStyle(
                            fontFamily: CompanionAppTheme.fontName,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 0.2,
                            color: CompanionAppTheme.lightText,
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        NumberPicker(
                          value: _kothPlayers,
                          minValue: 3,
                          maxValue: 6,
                          step: 1,
                          itemHeight: 66,
                          itemWidth: 66,
                          selectedTextStyle: TextStyle(
                            fontFamily: CompanionAppTheme.fontName,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            letterSpacing: 0.2,
                            color: CompanionAppTheme.lightText,
                          ),
                          textStyle: TextStyle(
                            fontFamily: CompanionAppTheme.fontName,
                            fontWeight: FontWeight.w100,
                            fontSize: 18,
                            letterSpacing: 0.2,
                            color: CompanionAppTheme.lightText.withOpacity(0.5),
                          ),
                          axis: Axis.horizontal,
                          onChanged: (value) =>
                              setState(() => _kothPlayers = value),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: CompanionAppTheme.lightText, width: 4),
                          ),
                        ),
                      ],
                      SizedBox(
                        height: 32,
                      ),
                      Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                CompanionAppTheme.background,
                                CompanionAppTheme.dark_grey
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                bottomLeft: Radius.circular(8.0),
                                bottomRight: Radius.circular(8.0),
                                topRight: Radius.circular(68.0)),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color:
                                      CompanionAppTheme.grey.withOpacity(0.2),
                                  offset: Offset(1.1, 1.1),
                                  blurRadius: 10.0),
                            ],
                          ),
                          child: Padding(
                              padding: EdgeInsets.only(
                                  left: 16, right: 16, top: 24, bottom: 8),
                              child: SizedBox(
                                width: 300,
                                child: Column(
                                  children: [
                                    Text(
                                      _gamemode == Mode.twovstwo
                                          ? 'Team 1'.tr(context)
                                          : 'You'.tr(context),
                                      style: TextStyle(
                                        fontFamily: CompanionAppTheme.fontName,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        letterSpacing: 0.2,
                                        color: CompanionAppTheme.lightText,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Divider(color: CompanionAppTheme.lightText),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    DropdownButton<Character>(
                                      menuMaxHeight: 300,
                                      hint: Text(
                                        'character_select'.tr(context),
                                        style: TextStyle(
                                          fontFamily:
                                              CompanionAppTheme.fontName,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14,
                                          letterSpacing: 0.2,
                                          color: CompanionAppTheme.lightText,
                                        ),
                                      ),
                                      value: _playerOne,
                                      onChanged: (Character? newValue) {
                                        setState(() {
                                          _playerOne = newValue;
                                        });
                                      },
                                      items: Character.values
                                          .map((Character character) {
                                        return DropdownMenuItem<Character>(
                                          value: character,
                                          child: Text(
                                            character.displayName,
                                            style: TextStyle(
                                              fontFamily:
                                                  CompanionAppTheme.fontName,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              letterSpacing: 0.2,
                                              color:
                                                  CompanionAppTheme.lightText,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ultimates'.tr(context),
                                          style: TextStyle(
                                            fontFamily:
                                                CompanionAppTheme.fontName,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            letterSpacing: 0.2,
                                            color: CompanionAppTheme.lightText,
                                          ),
                                        ),
                                        Spacer(),
                                        SizedBox(
                                          width: 44,
                                          height: 44,
                                          child: TextFormField(
                                            onTapOutside: (event) {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            },
                                            controller: _playerOneUltimates,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <TextInputFormatter>[
                                              // for below version 2 use this
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9]')),
                                              // for version 2 and greater youcan also use this
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor:
                                                  CompanionAppTheme.lightText,
                                              hintText: '',
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      left: 8.0,
                                                      bottom: 4.0,
                                                      top: 4.0),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: CompanionAppTheme
                                                        .lightText),
                                                borderRadius:
                                                    BorderRadius.circular(12.5),
                                              ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: CompanionAppTheme
                                                        .lightText),
                                                borderRadius:
                                                    BorderRadius.circular(12.5),
                                              ),
                                            ),
                                            cursorColor:
                                                CompanionAppTheme.darkerText,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    if (_gamemode == Mode.twovstwo ||
                                        _gamemode == Mode.threevsthree) ...[
                                      Divider(
                                          color: CompanionAppTheme.lightText),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      DropdownButton<Character>(
                                        menuMaxHeight: 300,
                                        hint: Text(
                                          'character_select'.tr(context),
                                          style: TextStyle(
                                            fontFamily:
                                                CompanionAppTheme.fontName,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            letterSpacing: 0.2,
                                            color: CompanionAppTheme.lightText,
                                          ),
                                        ),
                                        value: _playerThree,
                                        onChanged: (Character? newValue) {
                                          setState(() {
                                            _playerThree = newValue;
                                          });
                                        },
                                        items: Character.values
                                            .map((Character character) {
                                          return DropdownMenuItem<Character>(
                                            value: character,
                                            child: Text(
                                              character.displayName,
                                              style: TextStyle(
                                                fontFamily:
                                                    CompanionAppTheme.fontName,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                letterSpacing: 0.2,
                                                color:
                                                    CompanionAppTheme.lightText,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      SizedBox(height: 32),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 150,
                                            child: TextField(
                                              controller: _player3Controller,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor:
                                                    CompanionAppTheme.lightText,
                                                hintText:
                                                    'Player 3'.tr(context),
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        left: 14.0,
                                                        bottom: 8.0,
                                                        top: 8.0),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CompanionAppTheme
                                                          .lightText),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.7),
                                                ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CompanionAppTheme
                                                          .lightText),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.7),
                                                ),
                                              ),
                                              cursorColor:
                                                  CompanionAppTheme.darkerText,
                                            ),
                                          ),
                                          Spacer(),
                                          DropdownButton<FriendsData>(
                                            menuMaxHeight: 200,
                                            hint: Text(
                                              'friend_select'.tr(context),
                                              style: TextStyle(
                                                fontFamily:
                                                    CompanionAppTheme.fontName,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14,
                                                letterSpacing: 0.2,
                                                color:
                                                    CompanionAppTheme.lightText,
                                              ),
                                            ),
                                            value: _friendsThree,
                                            onChanged: (FriendsData? newValue) {
                                              setState(() {
                                                _friendsThree = newValue;
                                              });
                                            },
                                            items: [
                                              DropdownMenuItem<FriendsData>(
                                                value: null,
                                                child: Text(
                                                  'friend_unselect'.tr(context),
                                                  style: TextStyle(
                                                    fontFamily:
                                                        CompanionAppTheme
                                                            .fontName,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    letterSpacing: 0.2,
                                                    color: CompanionAppTheme
                                                        .lightText,
                                                  ),
                                                ),
                                              ),
                                              ...userService.friendsListData
                                                  .map((FriendsData friend) {
                                                return DropdownMenuItem<
                                                    FriendsData>(
                                                  value: friend,
                                                  child: Text(
                                                    friend.name,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          CompanionAppTheme
                                                              .fontName,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      letterSpacing: 0.2,
                                                      color: CompanionAppTheme
                                                          .lightText,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                          SizedBox(
                                            width: 16,
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ultimates'.tr(context),
                                            style: TextStyle(
                                              fontFamily:
                                                  CompanionAppTheme.fontName,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              letterSpacing: 0.2,
                                              color:
                                                  CompanionAppTheme.lightText,
                                            ),
                                          ),
                                          Spacer(),
                                          SizedBox(
                                            width: 44,
                                            height: 44,
                                            child: TextFormField(
                                              onTapOutside: (event) {
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                              },
                                              controller: _playerThreeUltimates,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                // for below version 2 use this
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(r'[0-9]')),
                                                // for version 2 and greater youcan also use this
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor:
                                                    CompanionAppTheme.lightText,
                                                hintText: '',
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        left: 8.0,
                                                        bottom: 4.0,
                                                        top: 4.0),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CompanionAppTheme
                                                          .lightText),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.5),
                                                ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CompanionAppTheme
                                                          .lightText),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.5),
                                                ),
                                              ),
                                              cursorColor:
                                                  CompanionAppTheme.darkerText,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                    ],
                                    if (_gamemode == Mode.threevsthree) ...[
                                      Divider(
                                          color: CompanionAppTheme.lightText),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      DropdownButton<Character>(
                                        menuMaxHeight: 300,
                                        hint: Text(
                                          'character_select'.tr(context),
                                          style: TextStyle(
                                            fontFamily:
                                                CompanionAppTheme.fontName,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            letterSpacing: 0.2,
                                            color: CompanionAppTheme.lightText,
                                          ),
                                        ),
                                        value: _playerFive,
                                        onChanged: (Character? newValue) {
                                          setState(() {
                                            _playerFive = newValue;
                                          });
                                        },
                                        items: Character.values
                                            .map((Character character) {
                                          return DropdownMenuItem<Character>(
                                            value: character,
                                            child: Text(
                                              character.displayName,
                                              style: TextStyle(
                                                fontFamily:
                                                    CompanionAppTheme.fontName,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                letterSpacing: 0.2,
                                                color:
                                                    CompanionAppTheme.lightText,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      SizedBox(height: 32),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 150,
                                            child: TextField(
                                              controller: _player5Controller,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor:
                                                    CompanionAppTheme.lightText,
                                                hintText:
                                                    'Player 5'.tr(context),
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        left: 14.0,
                                                        bottom: 8.0,
                                                        top: 8.0),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CompanionAppTheme
                                                          .lightText),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.7),
                                                ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CompanionAppTheme
                                                          .lightText),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.7),
                                                ),
                                              ),
                                              cursorColor:
                                                  CompanionAppTheme.darkerText,
                                            ),
                                          ),
                                          Spacer(),
                                          DropdownButton<FriendsData>(
                                            menuMaxHeight: 200,
                                            hint: Text(
                                              'friend_select'.tr(context),
                                              style: TextStyle(
                                                fontFamily:
                                                    CompanionAppTheme.fontName,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14,
                                                letterSpacing: 0.2,
                                                color:
                                                    CompanionAppTheme.lightText,
                                              ),
                                            ),
                                            value: _friendsFive,
                                            onChanged: (FriendsData? newValue) {
                                              setState(() {
                                                _friendsFive = newValue;
                                              });
                                            },
                                            items: [
                                              DropdownMenuItem<FriendsData>(
                                                value: null,
                                                child: Text(
                                                  'friend_unselect'.tr(context),
                                                  style: TextStyle(
                                                    fontFamily:
                                                        CompanionAppTheme
                                                            .fontName,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    letterSpacing: 0.2,
                                                    color: CompanionAppTheme
                                                        .lightText,
                                                  ),
                                                ),
                                              ),
                                              ...userService.friendsListData
                                                  .map((FriendsData friend) {
                                                return DropdownMenuItem<
                                                    FriendsData>(
                                                  value: friend,
                                                  child: Text(
                                                    friend.name,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          CompanionAppTheme
                                                              .fontName,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      letterSpacing: 0.2,
                                                      color: CompanionAppTheme
                                                          .lightText,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                          SizedBox(
                                            width: 16,
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ultimates'.tr(context),
                                            style: TextStyle(
                                              fontFamily:
                                                  CompanionAppTheme.fontName,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              letterSpacing: 0.2,
                                              color:
                                                  CompanionAppTheme.lightText,
                                            ),
                                          ),
                                          Spacer(),
                                          SizedBox(
                                            width: 44,
                                            height: 44,
                                            child: TextFormField(
                                              onTapOutside: (event) {
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                              },
                                              controller: _playerThreeUltimates,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                // for below version 2 use this
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(r'[0-9]')),
                                                // for version 2 and greater youcan also use this
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor:
                                                    CompanionAppTheme.lightText,
                                                hintText: '',
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        left: 8.0,
                                                        bottom: 4.0,
                                                        top: 4.0),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CompanionAppTheme
                                                          .lightText),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.5),
                                                ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CompanionAppTheme
                                                          .lightText),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.5),
                                                ),
                                              ),
                                              cursorColor:
                                                  CompanionAppTheme.darkerText,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                    ]
                                  ],
                                ),
                              ))),
                      SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              CompanionAppTheme.background,
                              CompanionAppTheme.dark_grey
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              bottomLeft: Radius.circular(8.0),
                              bottomRight: Radius.circular(8.0),
                              topRight: Radius.circular(68.0)),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: CompanionAppTheme.grey.withOpacity(0.2),
                                offset: Offset(1.1, 1.1),
                                blurRadius: 10.0),
                          ],
                        ),
                        child: Padding(
                            padding: EdgeInsets.only(
                                left: 16, right: 16, top: 24, bottom: 8),
                            child: SizedBox(
                              width: 300,
                              child: Column(
                                children: [
                                  Text(
                                    _gamemode == Mode.twovstwo
                                        ? 'Team 2'.tr(context)
                                        : 'Player 2'.tr(context),
                                    style: TextStyle(
                                      fontFamily: CompanionAppTheme.fontName,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      letterSpacing: 0.2,
                                      color: CompanionAppTheme.lightText,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Divider(color: CompanionAppTheme.lightText),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  DropdownButton<Character>(
                                    menuMaxHeight: 300,
                                    hint: Text(
                                      'character_select'.tr(context),
                                      style: TextStyle(
                                        fontFamily: CompanionAppTheme.fontName,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                        letterSpacing: 0.2,
                                        color: CompanionAppTheme.lightText,
                                      ),
                                    ),
                                    value: _playerTwo,
                                    onChanged: (Character? newValue) {
                                      setState(() {
                                        _playerTwo = newValue;
                                      });
                                    },
                                    items: Character.values
                                        .map((Character character) {
                                      return DropdownMenuItem<Character>(
                                        value: character,
                                        child: Text(
                                          character.displayName,
                                          style: TextStyle(
                                            fontFamily:
                                                CompanionAppTheme.fontName,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            letterSpacing: 0.2,
                                            color: CompanionAppTheme.lightText,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  OverlayTooltipItem(
                                      tooltipVerticalPosition:
                                          TooltipVerticalPosition.TOP,
                                      displayIndex: 0,
                                      tooltip: (controller) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15),
                                          child: MTooltip(
                                              title: 'tooltip_player_select'
                                                  .tr(context),
                                              controller: controller),
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          SizedBox(height: 32),
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 150,
                                                child: TextField(
                                                  controller:
                                                      _player2Controller,
                                                  decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: CompanionAppTheme
                                                        .lightText,
                                                    hintText:
                                                        'Player 2'.tr(context),
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                            left: 14.0,
                                                            bottom: 8.0,
                                                            top: 8.0),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color:
                                                              CompanionAppTheme
                                                                  .lightText),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25.7),
                                                    ),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color:
                                                              CompanionAppTheme
                                                                  .lightText),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25.7),
                                                    ),
                                                  ),
                                                  cursorColor: CompanionAppTheme
                                                      .darkerText,
                                                ),
                                              ),
                                              Spacer(),
                                              DropdownButton<FriendsData>(
                                                menuMaxHeight: 200,
                                                hint: Text(
                                                  'friend_select'.tr(context),
                                                  style: TextStyle(
                                                    fontFamily:
                                                        CompanionAppTheme
                                                            .fontName,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 14,
                                                    letterSpacing: 0.2,
                                                    color: CompanionAppTheme
                                                        .lightText,
                                                  ),
                                                ),
                                                value: _friendsTwo,
                                                onChanged:
                                                    (FriendsData? newValue) {
                                                  setState(() {
                                                    _friendsTwo = newValue;
                                                  });
                                                },
                                                items: [
                                                  DropdownMenuItem<FriendsData>(
                                                    value: null,
                                                    child: Text(
                                                      'friend_unselect'
                                                          .tr(context),
                                                      style: TextStyle(
                                                        fontFamily:
                                                            CompanionAppTheme
                                                                .fontName,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        letterSpacing: 0.2,
                                                        color: CompanionAppTheme
                                                            .lightText,
                                                      ),
                                                    ),
                                                  ),
                                                  ...userService.friendsListData
                                                      .map(
                                                          (FriendsData friend) {
                                                    return DropdownMenuItem<
                                                        FriendsData>(
                                                      value: friend,
                                                      child: Text(
                                                        friend.name,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              CompanionAppTheme
                                                                  .fontName,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                          letterSpacing: 0.2,
                                                          color:
                                                              CompanionAppTheme
                                                                  .lightText,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ],
                                              ),
                                              SizedBox(
                                                width: 16,
                                              )
                                            ],
                                          ),
                                        ],
                                      )),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ultimates'.tr(context),
                                        style: TextStyle(
                                          fontFamily:
                                              CompanionAppTheme.fontName,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          letterSpacing: 0.2,
                                          color: CompanionAppTheme.lightText,
                                        ),
                                      ),
                                      Spacer(),
                                      SizedBox(
                                        width: 44,
                                        height: 44,
                                        child: TextFormField(
                                          onTapOutside: (event) {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          controller: _playerTwoUltimates,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            // for below version 2 use this
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'[0-9]')),
                                            // for version 2 and greater youcan also use this
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor:
                                                CompanionAppTheme.lightText,
                                            hintText: '',
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    left: 8.0,
                                                    bottom: 4.0,
                                                    top: 4.0),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: CompanionAppTheme
                                                      .lightText),
                                              borderRadius:
                                                  BorderRadius.circular(12.5),
                                            ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: CompanionAppTheme
                                                      .lightText),
                                              borderRadius:
                                                  BorderRadius.circular(12.5),
                                            ),
                                          ),
                                          cursorColor:
                                              CompanionAppTheme.darkerText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  if (_gamemode == Mode.twovstwo ||
                                      _gamemode == Mode.threevsthree) ...[
                                    Divider(color: CompanionAppTheme.lightText),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    DropdownButton<Character>(
                                      menuMaxHeight: 300,
                                      hint: Text(
                                        'character_select'.tr(context),
                                        style: TextStyle(
                                          fontFamily:
                                              CompanionAppTheme.fontName,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14,
                                          letterSpacing: 0.2,
                                          color: CompanionAppTheme.lightText,
                                        ),
                                      ),
                                      value: _playerFour,
                                      onChanged: (Character? newValue) {
                                        setState(() {
                                          _playerFour = newValue;
                                        });
                                      },
                                      items: Character.values
                                          .map((Character character) {
                                        return DropdownMenuItem<Character>(
                                          value: character,
                                          child: Text(
                                            character.displayName,
                                            style: TextStyle(
                                              fontFamily:
                                                  CompanionAppTheme.fontName,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              letterSpacing: 0.2,
                                              color:
                                                  CompanionAppTheme.lightText,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    SizedBox(height: 32),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 150,
                                          child: TextField(
                                            controller: _player4Controller,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor:
                                                  CompanionAppTheme.lightText,
                                              hintText: 'Player 4'.tr(context),
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      left: 14.0,
                                                      bottom: 8.0,
                                                      top: 8.0),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: CompanionAppTheme
                                                        .lightText),
                                                borderRadius:
                                                    BorderRadius.circular(25.7),
                                              ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: CompanionAppTheme
                                                        .lightText),
                                                borderRadius:
                                                    BorderRadius.circular(25.7),
                                              ),
                                            ),
                                            cursorColor:
                                                CompanionAppTheme.darkerText,
                                          ),
                                        ),
                                        Spacer(),
                                        DropdownButton<FriendsData>(
                                          menuMaxHeight: 200,
                                          hint: Text(
                                            'friend_select'.tr(context),
                                            style: TextStyle(
                                              fontFamily:
                                                  CompanionAppTheme.fontName,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14,
                                              letterSpacing: 0.2,
                                              color:
                                                  CompanionAppTheme.lightText,
                                            ),
                                          ),
                                          value: _friendsFour,
                                          onChanged: (FriendsData? newValue) {
                                            setState(() {
                                              _friendsFour = newValue;
                                            });
                                          },
                                          items: [
                                            DropdownMenuItem<FriendsData>(
                                              value: null,
                                              child: Text(
                                                'friend_unselect'.tr(context),
                                                style: TextStyle(
                                                  fontFamily: CompanionAppTheme
                                                      .fontName,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  letterSpacing: 0.2,
                                                  color: CompanionAppTheme
                                                      .lightText,
                                                ),
                                              ),
                                            ),
                                            ...userService.friendsListData
                                                .map((FriendsData friend) {
                                              return DropdownMenuItem<
                                                  FriendsData>(
                                                value: friend,
                                                child: Text(
                                                  friend.name,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        CompanionAppTheme
                                                            .fontName,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    letterSpacing: 0.2,
                                                    color: CompanionAppTheme
                                                        .lightText,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 16,
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ultimates'.tr(context),
                                          style: TextStyle(
                                            fontFamily:
                                                CompanionAppTheme.fontName,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            letterSpacing: 0.2,
                                            color: CompanionAppTheme.lightText,
                                          ),
                                        ),
                                        Spacer(),
                                        SizedBox(
                                          width: 44,
                                          height: 44,
                                          child: TextFormField(
                                            onTapOutside: (event) {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            },
                                            controller: _playerFourUltimates,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <TextInputFormatter>[
                                              // for below version 2 use this
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9]')),
                                              // for version 2 and greater youcan also use this
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor:
                                                  CompanionAppTheme.lightText,
                                              hintText: '',
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      left: 8.0,
                                                      bottom: 4.0,
                                                      top: 4.0),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: CompanionAppTheme
                                                        .lightText),
                                                borderRadius:
                                                    BorderRadius.circular(12.5),
                                              ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: CompanionAppTheme
                                                        .lightText),
                                                borderRadius:
                                                    BorderRadius.circular(12.5),
                                              ),
                                            ),
                                            cursorColor:
                                                CompanionAppTheme.darkerText,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 16,
                                    )
                                  ],
                                  if (_gamemode == Mode.threevsthree) ...[
                                    Divider(color: CompanionAppTheme.lightText),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    DropdownButton<Character>(
                                      menuMaxHeight: 300,
                                      hint: Text(
                                        'character_select'.tr(context),
                                        style: TextStyle(
                                          fontFamily:
                                              CompanionAppTheme.fontName,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14,
                                          letterSpacing: 0.2,
                                          color: CompanionAppTheme.lightText,
                                        ),
                                      ),
                                      value: _playerSix,
                                      onChanged: (Character? newValue) {
                                        setState(() {
                                          _playerSix = newValue;
                                        });
                                      },
                                      items: Character.values
                                          .map((Character character) {
                                        return DropdownMenuItem<Character>(
                                          value: character,
                                          child: Text(
                                            character.displayName,
                                            style: TextStyle(
                                              fontFamily:
                                                  CompanionAppTheme.fontName,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              letterSpacing: 0.2,
                                              color:
                                                  CompanionAppTheme.lightText,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    SizedBox(height: 32),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 150,
                                          child: TextField(
                                            controller: _player6Controller,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor:
                                                  CompanionAppTheme.lightText,
                                              hintText: 'Player 6'.tr(context),
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      left: 14.0,
                                                      bottom: 8.0,
                                                      top: 8.0),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: CompanionAppTheme
                                                        .lightText),
                                                borderRadius:
                                                    BorderRadius.circular(25.7),
                                              ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: CompanionAppTheme
                                                        .lightText),
                                                borderRadius:
                                                    BorderRadius.circular(25.7),
                                              ),
                                            ),
                                            cursorColor:
                                                CompanionAppTheme.darkerText,
                                          ),
                                        ),
                                        Spacer(),
                                        DropdownButton<FriendsData>(
                                          menuMaxHeight: 200,
                                          hint: Text(
                                            'friend_select'.tr(context),
                                            style: TextStyle(
                                              fontFamily:
                                                  CompanionAppTheme.fontName,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14,
                                              letterSpacing: 0.2,
                                              color:
                                                  CompanionAppTheme.lightText,
                                            ),
                                          ),
                                          value: _friendsSix,
                                          onChanged: (FriendsData? newValue) {
                                            setState(() {
                                              _friendsSix = newValue;
                                            });
                                          },
                                          items: [
                                            DropdownMenuItem<FriendsData>(
                                              value: null,
                                              child: Text(
                                                'friend_unselect'.tr(context),
                                                style: TextStyle(
                                                  fontFamily: CompanionAppTheme
                                                      .fontName,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  letterSpacing: 0.2,
                                                  color: CompanionAppTheme
                                                      .lightText,
                                                ),
                                              ),
                                            ),
                                            ...userService.friendsListData
                                                .map((FriendsData friend) {
                                              return DropdownMenuItem<
                                                  FriendsData>(
                                                value: friend,
                                                child: Text(
                                                  friend.name,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        CompanionAppTheme
                                                            .fontName,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    letterSpacing: 0.2,
                                                    color: CompanionAppTheme
                                                        .lightText,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 16,
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ultimates'.tr(context),
                                          style: TextStyle(
                                            fontFamily:
                                                CompanionAppTheme.fontName,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            letterSpacing: 0.2,
                                            color: CompanionAppTheme.lightText,
                                          ),
                                        ),
                                        Spacer(),
                                        SizedBox(
                                          width: 44,
                                          height: 44,
                                          child: TextFormField(
                                            onTapOutside: (event) {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            },
                                            controller: _playerSixUltimates,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <TextInputFormatter>[
                                              // for below version 2 use this
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9]')),
                                              // for version 2 and greater youcan also use this
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor:
                                                  CompanionAppTheme.lightText,
                                              hintText: '',
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      left: 8.0,
                                                      bottom: 4.0,
                                                      top: 4.0),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: CompanionAppTheme
                                                        .lightText),
                                                borderRadius:
                                                    BorderRadius.circular(12.5),
                                              ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: CompanionAppTheme
                                                        .lightText),
                                                borderRadius:
                                                    BorderRadius.circular(12.5),
                                              ),
                                            ),
                                            cursorColor:
                                                CompanionAppTheme.darkerText,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 16,
                                    )
                                  ]
                                ],
                              ),
                            )),
                      ),
                      if (_gamemode == Mode.koth)
                        SizedBox(
                          height: 16,
                        ),
                      if (_gamemode == Mode.koth) ...[
                        if (_kothPlayers > 2)
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  CompanionAppTheme.background,
                                  CompanionAppTheme.dark_grey
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8.0),
                                  bottomLeft: Radius.circular(8.0),
                                  bottomRight: Radius.circular(8.0),
                                  topRight: Radius.circular(68.0)),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color:
                                        CompanionAppTheme.grey.withOpacity(0.2),
                                    offset: Offset(1.1, 1.1),
                                    blurRadius: 10.0),
                              ],
                            ),
                            child: Padding(
                                padding: EdgeInsets.only(
                                    left: 16, right: 16, top: 24, bottom: 8),
                                child: SizedBox(
                                  width: 300,
                                  child: Column(
                                    children: [
                                      Text(
                                        'Player 3'.tr(context),
                                        style: TextStyle(
                                          fontFamily:
                                              CompanionAppTheme.fontName,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          letterSpacing: 0.2,
                                          color: CompanionAppTheme.lightText,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                      Divider(
                                          color: CompanionAppTheme.lightText),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      DropdownButton<Character>(
                                        menuMaxHeight: 300,
                                        hint: Text(
                                          'character_select'.tr(context),
                                          style: TextStyle(
                                            fontFamily:
                                                CompanionAppTheme.fontName,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14,
                                            letterSpacing: 0.2,
                                            color: CompanionAppTheme.lightText,
                                          ),
                                        ),
                                        value: _playerThree,
                                        onChanged: (Character? newValue) {
                                          setState(() {
                                            _playerThree = newValue!;
                                          });
                                        },
                                        items: Character.values
                                            .map((Character character) {
                                          return DropdownMenuItem<Character>(
                                            value: character,
                                            child: Text(
                                              character.displayName,
                                              style: TextStyle(
                                                fontFamily:
                                                    CompanionAppTheme.fontName,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                letterSpacing: 0.2,
                                                color:
                                                    CompanionAppTheme.lightText,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      SizedBox(height: 32),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 150,
                                            child: TextField(
                                              controller: _player3Controller,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor:
                                                    CompanionAppTheme.lightText,
                                                hintText:
                                                    'Player 3'.tr(context),
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        left: 14.0,
                                                        bottom: 8.0,
                                                        top: 8.0),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CompanionAppTheme
                                                          .lightText),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.7),
                                                ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CompanionAppTheme
                                                          .lightText),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.7),
                                                ),
                                              ),
                                              cursorColor:
                                                  CompanionAppTheme.darkerText,
                                            ),
                                          ),
                                          Spacer(),
                                          DropdownButton<FriendsData>(
                                            menuMaxHeight: 200,
                                            hint: Text(
                                              'friend_select'.tr(context),
                                              style: TextStyle(
                                                fontFamily:
                                                    CompanionAppTheme.fontName,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14,
                                                letterSpacing: 0.2,
                                                color:
                                                    CompanionAppTheme.lightText,
                                              ),
                                            ),
                                            value: _friendsThree,
                                            onChanged: (FriendsData? newValue) {
                                              setState(() {
                                                _friendsThree = newValue;
                                              });
                                            },
                                            items: [
                                              DropdownMenuItem<FriendsData>(
                                                value: null,
                                                child: Text(
                                                  'friend_unselect'.tr(context),
                                                  style: TextStyle(
                                                    fontFamily:
                                                        CompanionAppTheme
                                                            .fontName,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    letterSpacing: 0.2,
                                                    color: CompanionAppTheme
                                                        .lightText,
                                                  ),
                                                ),
                                              ),
                                              ...userService.friendsListData
                                                  .map((FriendsData friend) {
                                                return DropdownMenuItem<
                                                    FriendsData>(
                                                  value: friend,
                                                  child: Text(
                                                    friend.name,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          CompanionAppTheme
                                                              .fontName,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      letterSpacing: 0.2,
                                                      color: CompanionAppTheme
                                                          .lightText,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                          SizedBox(
                                            width: 16,
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ultimates'.tr(context),
                                            style: TextStyle(
                                              fontFamily:
                                                  CompanionAppTheme.fontName,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              letterSpacing: 0.2,
                                              color:
                                                  CompanionAppTheme.lightText,
                                            ),
                                          ),
                                          Spacer(),
                                          SizedBox(
                                            width: 44,
                                            height: 44,
                                            child: TextFormField(
                                              onTapOutside: (event) {
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                              },
                                              controller: _playerThreeUltimates,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                // for below version 2 use this
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(r'[0-9]')),
                                                // for version 2 and greater youcan also use this
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor:
                                                    CompanionAppTheme.lightText,
                                                hintText: '',
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        left: 8.0,
                                                        bottom: 4.0,
                                                        top: 4.0),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CompanionAppTheme
                                                          .lightText),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.5),
                                                ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CompanionAppTheme
                                                          .lightText),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.5),
                                                ),
                                              ),
                                              cursorColor:
                                                  CompanionAppTheme.darkerText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        if (_kothPlayers > 3) ...[
                          SizedBox(
                            height: 16,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  CompanionAppTheme.background,
                                  CompanionAppTheme.dark_grey
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8.0),
                                  bottomLeft: Radius.circular(8.0),
                                  bottomRight: Radius.circular(8.0),
                                  topRight: Radius.circular(68.0)),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color:
                                        CompanionAppTheme.grey.withOpacity(0.2),
                                    offset: Offset(1.1, 1.1),
                                    blurRadius: 10.0),
                              ],
                            ),
                            child: Padding(
                                padding: EdgeInsets.only(
                                    left: 16, right: 16, top: 24, bottom: 8),
                                child: SizedBox(
                                  width: 300,
                                  child: Column(
                                    children: [
                                      Text(
                                        'Player 4'.tr(context),
                                        style: TextStyle(
                                          fontFamily:
                                              CompanionAppTheme.fontName,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          letterSpacing: 0.2,
                                          color: CompanionAppTheme.lightText,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                      Divider(
                                          color: CompanionAppTheme.lightText),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      DropdownButton<Character>(
                                        menuMaxHeight: 300,
                                        hint: Text(
                                          'character_select'.tr(context),
                                          style: TextStyle(
                                            fontFamily:
                                                CompanionAppTheme.fontName,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14,
                                            letterSpacing: 0.2,
                                            color: CompanionAppTheme.lightText,
                                          ),
                                        ),
                                        value: _playerFour,
                                        onChanged: (Character? newValue) {
                                          setState(() {
                                            _playerFour = newValue!;
                                          });
                                        },
                                        items: Character.values
                                            .map((Character character) {
                                          return DropdownMenuItem<Character>(
                                            value: character,
                                            child: Text(
                                              character.displayName,
                                              style: TextStyle(
                                                fontFamily:
                                                    CompanionAppTheme.fontName,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                letterSpacing: 0.2,
                                                color:
                                                    CompanionAppTheme.lightText,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      SizedBox(height: 32),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 150,
                                            child: TextField(
                                              controller: _player4Controller,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor:
                                                    CompanionAppTheme.lightText,
                                                hintText:
                                                    'Player 4'.tr(context),
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        left: 14.0,
                                                        bottom: 8.0,
                                                        top: 8.0),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CompanionAppTheme
                                                          .lightText),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.7),
                                                ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CompanionAppTheme
                                                          .lightText),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.7),
                                                ),
                                              ),
                                              cursorColor:
                                                  CompanionAppTheme.darkerText,
                                            ),
                                          ),
                                          Spacer(),
                                          DropdownButton<FriendsData>(
                                            menuMaxHeight: 200,
                                            hint: Text(
                                              'friend_select'.tr(context),
                                              style: TextStyle(
                                                fontFamily:
                                                    CompanionAppTheme.fontName,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14,
                                                letterSpacing: 0.2,
                                                color:
                                                    CompanionAppTheme.lightText,
                                              ),
                                            ),
                                            value: _friendsFour,
                                            onChanged: (FriendsData? newValue) {
                                              setState(() {
                                                _friendsFour = newValue;
                                              });
                                            },
                                            items: [
                                              DropdownMenuItem<FriendsData>(
                                                value: null,
                                                child: Text(
                                                  'friend_unselect'.tr(context),
                                                  style: TextStyle(
                                                    fontFamily:
                                                        CompanionAppTheme
                                                            .fontName,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    letterSpacing: 0.2,
                                                    color: CompanionAppTheme
                                                        .lightText,
                                                  ),
                                                ),
                                              ),
                                              ...userService.friendsListData
                                                  .map((FriendsData friend) {
                                                return DropdownMenuItem<
                                                    FriendsData>(
                                                  value: friend,
                                                  child: Text(
                                                    friend.name,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          CompanionAppTheme
                                                              .fontName,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      letterSpacing: 0.2,
                                                      color: CompanionAppTheme
                                                          .lightText,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                          SizedBox(
                                            width: 16,
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ultimates'.tr(context),
                                            style: TextStyle(
                                              fontFamily:
                                                  CompanionAppTheme.fontName,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              letterSpacing: 0.2,
                                              color:
                                                  CompanionAppTheme.lightText,
                                            ),
                                          ),
                                          Spacer(),
                                          SizedBox(
                                            width: 44,
                                            height: 44,
                                            child: TextFormField(
                                              onTapOutside: (event) {
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                              },
                                              controller: _playerFourUltimates,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                // for below version 2 use this
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(r'[0-9]')),
                                                // for version 2 and greater youcan also use this
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor:
                                                    CompanionAppTheme.lightText,
                                                hintText: '',
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        left: 8.0,
                                                        bottom: 4.0,
                                                        top: 4.0),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CompanionAppTheme
                                                          .lightText),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.5),
                                                ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CompanionAppTheme
                                                          .lightText),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.5),
                                                ),
                                              ),
                                              cursorColor:
                                                  CompanionAppTheme.darkerText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ],
                        if (_kothPlayers > 4) ...[
                          SizedBox(
                            height: 16,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  CompanionAppTheme.background,
                                  CompanionAppTheme.dark_grey
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8.0),
                                  bottomLeft: Radius.circular(8.0),
                                  bottomRight: Radius.circular(8.0),
                                  topRight: Radius.circular(68.0)),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color:
                                        CompanionAppTheme.grey.withOpacity(0.2),
                                    offset: Offset(1.1, 1.1),
                                    blurRadius: 10.0),
                              ],
                            ),
                            child: Padding(
                                padding: EdgeInsets.only(
                                    left: 16, right: 16, top: 24, bottom: 8),
                                child: SizedBox(
                                  width: 300,
                                  child: Column(
                                    children: [
                                      Text(
                                        'Player 5'.tr(context),
                                        style: TextStyle(
                                          fontFamily:
                                              CompanionAppTheme.fontName,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          letterSpacing: 0.2,
                                          color: CompanionAppTheme.lightText,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                      Divider(
                                          color: CompanionAppTheme.lightText),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      DropdownButton<Character>(
                                        menuMaxHeight: 300,
                                        hint: Text(
                                          'character_select'.tr(context),
                                          style: TextStyle(
                                            fontFamily:
                                                CompanionAppTheme.fontName,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14,
                                            letterSpacing: 0.2,
                                            color: CompanionAppTheme.lightText,
                                          ),
                                        ),
                                        value: _playerFive,
                                        onChanged: (Character? newValue) {
                                          setState(() {
                                            _playerFive = newValue!;
                                          });
                                        },
                                        items: Character.values
                                            .map((Character character) {
                                          return DropdownMenuItem<Character>(
                                            value: character,
                                            child: Text(
                                              character.displayName,
                                              style: TextStyle(
                                                fontFamily:
                                                    CompanionAppTheme.fontName,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                letterSpacing: 0.2,
                                                color:
                                                    CompanionAppTheme.lightText,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      SizedBox(height: 32),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 150,
                                            child: TextField(
                                              controller: _player5Controller,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor:
                                                    CompanionAppTheme.lightText,
                                                hintText:
                                                    'Player 5'.tr(context),
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        left: 14.0,
                                                        bottom: 8.0,
                                                        top: 8.0),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CompanionAppTheme
                                                          .lightText),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.7),
                                                ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CompanionAppTheme
                                                          .lightText),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.7),
                                                ),
                                              ),
                                              cursorColor:
                                                  CompanionAppTheme.darkerText,
                                            ),
                                          ),
                                          Spacer(),
                                          DropdownButton<FriendsData>(
                                            menuMaxHeight: 200,
                                            hint: Text(
                                              'friend_select'.tr(context),
                                              style: TextStyle(
                                                fontFamily:
                                                    CompanionAppTheme.fontName,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14,
                                                letterSpacing: 0.2,
                                                color:
                                                    CompanionAppTheme.lightText,
                                              ),
                                            ),
                                            value: _friendsFive,
                                            onChanged: (FriendsData? newValue) {
                                              setState(() {
                                                _friendsFive = newValue;
                                              });
                                            },
                                            items: [
                                              DropdownMenuItem<FriendsData>(
                                                value: null,
                                                child: Text(
                                                  'friend_unselect'.tr(context),
                                                  style: TextStyle(
                                                    fontFamily:
                                                        CompanionAppTheme
                                                            .fontName,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    letterSpacing: 0.2,
                                                    color: CompanionAppTheme
                                                        .lightText,
                                                  ),
                                                ),
                                              ),
                                              ...userService.friendsListData
                                                  .map((FriendsData friend) {
                                                return DropdownMenuItem<
                                                    FriendsData>(
                                                  value: friend,
                                                  child: Text(
                                                    friend.name,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          CompanionAppTheme
                                                              .fontName,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      letterSpacing: 0.2,
                                                      color: CompanionAppTheme
                                                          .lightText,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                          SizedBox(
                                            width: 16,
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ultimates'.tr(context),
                                            style: TextStyle(
                                              fontFamily:
                                                  CompanionAppTheme.fontName,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              letterSpacing: 0.2,
                                              color:
                                                  CompanionAppTheme.lightText,
                                            ),
                                          ),
                                          Spacer(),
                                          SizedBox(
                                            width: 44,
                                            height: 44,
                                            child: TextFormField(
                                              onTapOutside: (event) {
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                              },
                                              controller: _playerFiveUltimates,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                // for below version 2 use this
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(r'[0-9]')),
                                                // for version 2 and greater youcan also use this
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor:
                                                    CompanionAppTheme.lightText,
                                                hintText: '',
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        left: 8.0,
                                                        bottom: 4.0,
                                                        top: 4.0),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CompanionAppTheme
                                                          .lightText),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.5),
                                                ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CompanionAppTheme
                                                          .lightText),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.5),
                                                ),
                                              ),
                                              cursorColor:
                                                  CompanionAppTheme.darkerText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ],
                        if (_kothPlayers > 5) ...[
                          SizedBox(
                            height: 16,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  CompanionAppTheme.background,
                                  CompanionAppTheme.dark_grey
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8.0),
                                  bottomLeft: Radius.circular(8.0),
                                  bottomRight: Radius.circular(8.0),
                                  topRight: Radius.circular(68.0)),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color:
                                        CompanionAppTheme.grey.withOpacity(0.2),
                                    offset: Offset(1.1, 1.1),
                                    blurRadius: 10.0),
                              ],
                            ),
                            child: Padding(
                                padding: EdgeInsets.only(
                                    left: 16, right: 16, top: 24, bottom: 8),
                                child: SizedBox(
                                  width: 300,
                                  child: Column(
                                    children: [
                                      Text(
                                        'Player 6'.tr(context),
                                        style: TextStyle(
                                          fontFamily:
                                              CompanionAppTheme.fontName,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          letterSpacing: 0.2,
                                          color: CompanionAppTheme.lightText,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                      Divider(
                                          color: CompanionAppTheme.lightText),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      DropdownButton<Character>(
                                        menuMaxHeight: 300,
                                        hint: Text(
                                          'character_select'.tr(context),
                                          style: TextStyle(
                                            fontFamily:
                                                CompanionAppTheme.fontName,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14,
                                            letterSpacing: 0.2,
                                            color: CompanionAppTheme.lightText,
                                          ),
                                        ),
                                        value: _playerSix,
                                        onChanged: (Character? newValue) {
                                          setState(() {
                                            _playerSix = newValue!;
                                          });
                                        },
                                        items: Character.values
                                            .map((Character character) {
                                          return DropdownMenuItem<Character>(
                                            value: character,
                                            child: Text(
                                              character.displayName,
                                              style: TextStyle(
                                                fontFamily:
                                                    CompanionAppTheme.fontName,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                letterSpacing: 0.2,
                                                color:
                                                    CompanionAppTheme.lightText,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      SizedBox(height: 32),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 150,
                                            child: TextField(
                                              controller: _player6Controller,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor:
                                                    CompanionAppTheme.lightText,
                                                hintText:
                                                    'Player 6'.tr(context),
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        left: 14.0,
                                                        bottom: 8.0,
                                                        top: 8.0),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CompanionAppTheme
                                                          .lightText),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.7),
                                                ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CompanionAppTheme
                                                          .lightText),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          25.7),
                                                ),
                                              ),
                                              cursorColor:
                                                  CompanionAppTheme.darkerText,
                                            ),
                                          ),
                                          Spacer(),
                                          DropdownButton<FriendsData>(
                                            menuMaxHeight: 200,
                                            hint: Text(
                                              'friend_select'.tr(context),
                                              style: TextStyle(
                                                fontFamily:
                                                    CompanionAppTheme.fontName,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14,
                                                letterSpacing: 0.2,
                                                color:
                                                    CompanionAppTheme.lightText,
                                              ),
                                            ),
                                            value: _friendsSix,
                                            onChanged: (FriendsData? newValue) {
                                              setState(() {
                                                _friendsSix = newValue;
                                              });
                                            },
                                            items: [
                                              DropdownMenuItem<FriendsData>(
                                                value: null,
                                                child: Text(
                                                  'friend_unselect'.tr(context),
                                                  style: TextStyle(
                                                    fontFamily:
                                                        CompanionAppTheme
                                                            .fontName,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    letterSpacing: 0.2,
                                                    color: CompanionAppTheme
                                                        .lightText,
                                                  ),
                                                ),
                                              ),
                                              ...userService.friendsListData
                                                  .map((FriendsData friend) {
                                                return DropdownMenuItem<
                                                    FriendsData>(
                                                  value: friend,
                                                  child: Text(
                                                    friend.name,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          CompanionAppTheme
                                                              .fontName,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      letterSpacing: 0.2,
                                                      color: CompanionAppTheme
                                                          .lightText,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                          SizedBox(
                                            width: 16,
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ultimates'.tr(context),
                                            style: TextStyle(
                                              fontFamily:
                                                  CompanionAppTheme.fontName,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              letterSpacing: 0.2,
                                              color:
                                                  CompanionAppTheme.lightText,
                                            ),
                                          ),
                                          Spacer(),
                                          SizedBox(
                                            width: 44,
                                            height: 44,
                                            child: TextFormField(
                                              onTapOutside: (event) {
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                              },
                                              controller: _playerSixUltimates,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                // for below version 2 use this
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(r'[0-9]')),
                                                // for version 2 and greater youcan also use this
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor:
                                                    CompanionAppTheme.lightText,
                                                hintText: '',
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        left: 8.0,
                                                        bottom: 4.0,
                                                        top: 4.0),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CompanionAppTheme
                                                          .lightText),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.5),
                                                ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: CompanionAppTheme
                                                          .lightText),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.5),
                                                ),
                                              ),
                                              cursorColor:
                                                  CompanionAppTheme.darkerText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                          )
                        ]
                      ],
                      SizedBox(height: 32),
                      DropdownButton<String>(
                        hint: Text(
                          'select_winner'.tr(context),
                          style: TextStyle(
                            fontFamily: CompanionAppTheme.fontName,
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                            letterSpacing: 0.2,
                            color: CompanionAppTheme.lightText,
                          ),
                        ),
                        value: _winningTeam,
                        onChanged: (String? newValue) {
                          setState(() {
                            _winningTeam = newValue;
                          });
                        },
                        items: teams.map((String team) {
                          return DropdownMenuItem<String>(
                            value: team,
                            child: Text(
                              team,
                              style: TextStyle(
                                fontFamily: CompanionAppTheme.fontName,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.2,
                                color: CompanionAppTheme.lightText,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      Text(
                        'winner_health'.tr(context),
                        style: TextStyle(
                          fontFamily: CompanionAppTheme.fontName,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 0.2,
                          color: CompanionAppTheme.lightText,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      NumberPicker(
                        value: _winnerHealth,
                        minValue: 1,
                        maxValue: 100,
                        step: 1,
                        itemHeight: 44,
                        itemWidth: 44,
                        selectedTextStyle: TextStyle(
                          fontFamily: CompanionAppTheme.fontName,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          letterSpacing: 0.2,
                          color: CompanionAppTheme.lightText,
                        ),
                        textStyle: TextStyle(
                          fontFamily: CompanionAppTheme.fontName,
                          fontWeight: FontWeight.w100,
                          fontSize: 14,
                          letterSpacing: 0.2,
                          color: CompanionAppTheme.lightText.withOpacity(0.5),
                        ),
                        axis: Axis.horizontal,
                        onChanged: (value) =>
                            setState(() => _winnerHealth = value),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: CompanionAppTheme.lightText, width: 4),
                        ),
                      ),
                      /*SafeArea(
                        child: SizedBox(
                          width: adSize.width.toDouble(),
                          height: adSize.height.toDouble(),
                          child: _bannerAdOne == null
                          // Nothing to render yet.
                              ? SizedBox()
                          // The actual ad.
                              : AdWidget(ad: _bannerAdOne!),
                        ),
                      ),*/
                      SizedBox(
                        height: 32,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: CompanionAppTheme.darkerText,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 36, vertical: 24),
                                textStyle: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold)),
                            onPressed: () async {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CompanionAppHomeScreen(index: 0)));
                            },
                            child: Text(
                              'match_quit'.tr(context),
                              style: TextStyle(
                                fontFamily: CompanionAppTheme.fontName,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.2,
                                color: CompanionAppTheme.lightText,
                              ),
                            ),
                          ),
                          SizedBox(width: 32),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: CompanionAppTheme.lightText,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 36, vertical: 24),
                                textStyle: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold)),
                            onPressed: () async {
                              _submit(userService);
                            },
                            child: Text(
                              'match_save'.tr(context),
                              style: TextStyle(
                                fontFamily: CompanionAppTheme.fontName,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.2,
                                color: CompanionAppTheme.darkerText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);

    return Container(
        color: CompanionAppTheme.background,
        child: OverlayTooltipScaffold(
            overlayColor: Colors.red.withOpacity(.4),
            tooltipAnimationCurve: Curves.linear,
            tooltipAnimationDuration: const Duration(milliseconds: 1000),
            controller: _controller,
            // if you need to have control over the background overlay for gestures
            preferredOverlay: GestureDetector(
              onTap: () {
                _controller.dismiss();
                //move the overlay forward or backwards, or dismiss the overlay
              },
              child: Container(
                height: double.infinity,
                width: double.infinity,
                color: CompanionAppTheme.background.withOpacity(.75),
              ),
            ),
            startWhen: (initializedWidgetLength) async {
              await Future.delayed(const Duration(milliseconds: 500));
              bool shouldShowTooltip = await _shouldShowTooltip();
              return initializedWidgetLength == 1 && shouldShowTooltip;
            },
            builder: (context) => Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Stack(
                    children: <Widget>[
                      getMainListViewUI(userService),
                      getAppBarUI(),
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom,
                      )
                    ],
                  ),
                )));
  }

  Widget randomCharacterSelector(UserService userService) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          color: CompanionAppTheme.background,
          child: SingleChildScrollView(
            child: SizedBox(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Text(
                              'Randomizer',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: CompanionAppTheme.lightText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Wrap(
                        spacing: 8.0,
                        children: Character.values.map((character) {
                          return ChoiceChip(
                            label: Text(
                                character.displayName),
                            selected: randomCharacters.contains(character),
                            onSelected: (selected) {
                              setState(() {
                                if (randomCharacters.contains(character)) {
                                  randomCharacters.removeWhere((element) => element == character);
                                } else {
                                  randomCharacters.add(character);
                                }
                              });
                            },
                            selectedColor: CompanionAppTheme.lightText,
                            backgroundColor: CompanionAppTheme.dark_grey,
                            labelStyle: TextStyle(
                              color: randomCharacters.contains(character)
                                  ? CompanionAppTheme.darkerText
                                  : CompanionAppTheme.lightText,
                            ),
                          );
                        }).toList(),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: CompanionAppTheme.lightText,
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 20),
                            textStyle: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          setState(() {
                            switch(_gamemode) {
                              case Mode.onevsone:
                                _playerOne = getRandomCharacter(randomCharacters);
                                _playerTwo = getRandomCharacter(randomCharacters);
                              case Mode.twovstwo:
                                _playerOne = getRandomCharacter(randomCharacters);
                                _playerTwo = getRandomCharacter(randomCharacters);
                                _playerThree = getRandomCharacter(randomCharacters);
                                _playerFour = getRandomCharacter(randomCharacters);
                              case Mode.koth:
                                switch(_kothPlayers) {
                                  case 3:
                                    _playerOne = getRandomCharacter(randomCharacters);
                                    _playerTwo = getRandomCharacter(randomCharacters);
                                    _playerThree = getRandomCharacter(randomCharacters);
                                  case 4:
                                    _playerOne = getRandomCharacter(randomCharacters);
                                    _playerTwo = getRandomCharacter(randomCharacters);
                                    _playerThree = getRandomCharacter(randomCharacters);
                                    _playerFour = getRandomCharacter(randomCharacters);
                                  case 5:
                                    _playerOne = getRandomCharacter(randomCharacters);
                                    _playerTwo = getRandomCharacter(randomCharacters);
                                    _playerThree = getRandomCharacter(randomCharacters);
                                    _playerFour = getRandomCharacter(randomCharacters);
                                    _playerFive = getRandomCharacter(randomCharacters);
                                  case 6:
                                    _playerOne = getRandomCharacter(randomCharacters);
                                    _playerTwo = getRandomCharacter(randomCharacters);
                                    _playerThree = getRandomCharacter(randomCharacters);
                                    _playerFour = getRandomCharacter(randomCharacters);
                                    _playerFive = getRandomCharacter(randomCharacters);
                                    _playerSix = getRandomCharacter(randomCharacters);
                                }
                              case Mode.threevsthree:
                                _playerOne = getRandomCharacter(randomCharacters);
                                _playerTwo = getRandomCharacter(randomCharacters);
                                _playerThree = getRandomCharacter(randomCharacters);
                                _playerFour = getRandomCharacter(randomCharacters);
                                _playerFive = getRandomCharacter(randomCharacters);
                                _playerSix = getRandomCharacter(randomCharacters);
                            }
                            randomCharacters = List<Character>.from(Character.values);
                            Navigator.pop(context);
                            _scrollALittle();
                          });
                        },
                        child: Text(
                          'randomize_button'.tr(context),
                          style: TextStyle(
                            fontFamily: CompanionAppTheme.fontName,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.2,
                            color: CompanionAppTheme.darkerText,
                          ),
                        ),
                      ),
                      SizedBox(height: 88,)
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Character getRandomCharacter(List<Character> characters) {
    final random = Random();
    int index = random.nextInt(characters.length);
    return characters.removeAt(index);
  }
}
