import 'dart:math';
import 'package:best_flutter_ui_templates/dt_companion/companion_app_home_screen.dart';
import 'package:best_flutter_ui_templates/dt_companion/companion_app_theme.dart';
import 'package:best_flutter_ui_templates/dt_companion/models/games_list_data.dart';
import 'package:best_flutter_ui_templates/dt_companion/models/heroes_list_data.dart';
import 'package:best_flutter_ui_templates/dt_companion/service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Mode { onevsone, twovstwo, koth, threevsthree }

class MatchView extends StatefulWidget {
  const MatchView({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  _MatchViewState createState() => _MatchViewState();
}

class _MatchViewState extends State<MatchView> with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;
  List<Widget> listViews = <Widget>[];
  double topBarOpacity = 0.0;
  Character? _playerOne;
  Character? _playerTwo;
  Character? _playerThree;
  Character? _playerFour;
  Character? _playerFive;
  Character? _playerSix;
  Mode _gamemode = Mode.onevsone;
  String? _winningTeam;
  TextEditingController _player2Controller = TextEditingController();
  TextEditingController _player3Controller = TextEditingController();
  TextEditingController _player4Controller = TextEditingController();
  TextEditingController _player5Controller = TextEditingController();
  TextEditingController _player6Controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool get _isFormValid1v1 {
    return _playerOne != null && _playerTwo != null && _winningTeam != null;
  }

  List<String> get teams {
    if (_gamemode == Mode.koth) {
      return ['You', 'Player 2', 'Player 3'];
    } else if (_gamemode == Mode.twovstwo || _gamemode == Mode.threevsthree) {
      return ['Team 1', 'Team 2', 'Draw'];
    } else {
      return ['You', 'Player 2', 'Draw'];
    }
  }

  Future<void> _setInAppReviewStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("inAppReviewStatus", 1);
  }

  Future<void> _analytics() async {
    // Analytics
    await FirebaseAnalytics.instance.logScreenView(screenName: 'MatchView');
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
    super.dispose();
  }

  int generateRandomId() {
    Random random = Random();
    int min = 1000000; // 7 digits minimum value (1 followed by 6 zeros)
    int max = 9999999; // 7 digits maximum value (7 nines)
    return min + random.nextInt(max - min + 1);
  }

  Future<void> _submit(UserService userService) async {
    if (_isFormValid1v1) {
      var winner =
          (_winningTeam == "You" || _winningTeam == "Team 1") ? true : false;

      var heroesData = HeroesListData(
          name: _playerOne!.displayName,
          imagePath: "assets/dt_companion/${_playerOne!.name}.png",
          victories: 0,
          defeats: 0,
          draws: 0);

      try {
        try {
          HeroesListData hero = userService.heroesListData
              .firstWhere((hero) => hero.name == heroesData.name);
          if (_winningTeam != 'Draw') {
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
          if (_winningTeam != 'Draw') {
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
        var gameData = GamesListData(
            playerOneImagePath: "assets/dt_companion/${_playerOne!.name}.png",
            playerOne: 'You',
            playerTwoImagePath: "assets/dt_companion/${_playerTwo!.name}.png",
            playerTwo: _player2Controller.text != "" ? _player2Controller.text : "Player 2",
            playerThreeImagePath: _playerThree != null
                ? "assets/dt_companion/${_playerThree!.name}.png"
                : "",
            playerThree:
                _player3Controller.text != "" ? _player3Controller.text : "Player 3",
            playerFourImagePath: _playerFour != null
                ? "assets/dt_companion/${_playerFour!.name}.png"
                : "",
            playerFour:
                _player4Controller.text != "" ? _player4Controller.text : "Player 4",
            playerFiveImagePath: _playerFive != null
                ? "assets/dt_companion/${_playerFive!.name}.png"
                : "",
            playerFive:
                _player5Controller.text != "" ? _player5Controller.text : "Player 5",
            playerSixImagePath: _playerSix != null
                ? "assets/dt_companion/${_playerSix!.name}.png"
                : "",
            playerSix:
                _player6Controller.text != "" ? _player6Controller.text : "Player 6",
            gamemode: _gamemode,
            id: generateRandomId(),
            winner: _winningTeam ?? "",
            date: DateTime.now().millisecondsSinceEpoch);
        userService.insertGamesData(gameData);
      } catch (e) {
        print(e);
      }

      _setInAppReviewStatus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Game submitted!')),
      );

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => CompanionAppHomeScreen(index: 0)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Missing informations')),
      );
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
                                  'Game',
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
                      CupertinoSegmentedControl<Mode>(
                        selectedColor: CompanionAppTheme.lightText,
                        borderColor: CompanionAppTheme.lightText,
                        unselectedColor: CompanionAppTheme.dark_grey,
                        children: {
                          Mode.onevsone: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 16.0),
                            child: Text('1v1'),
                          ),
                          Mode.twovstwo: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 16.0),
                            child: Text('2v2'),
                          ),
                          Mode.koth: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 16.0),
                            child: Text('KOTH'),
                          ),
                          Mode.threevsthree: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 16.0),
                            child: Text('3v3'),
                          ),
                        },
                        onValueChanged: (Mode value) {
                          setState(() {
                            _gamemode = value;
                          });
                        },
                        groupValue: _gamemode,
                      ),
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
                                          ? 'Team 1'
                                          : 'You',
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
                                    DropdownButton<Character>(
                                      menuMaxHeight: 300,
                                      hint: Text(
                                        'Select Character',
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
                                      height: 32,
                                    ),
                                    if (_gamemode == Mode.twovstwo ||
                                        _gamemode == Mode.threevsthree) ...[
                                      DropdownButton<Character>(
                                        menuMaxHeight: 300,
                                        hint: Text(
                                          'Select Character',
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
                                      SizedBox(
                                        height: 16,
                                      ),
                                      SizedBox(
                                        width: 300,
                                        child: TextField(
                                          controller: _player2Controller,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor:
                                                CompanionAppTheme.lightText,
                                            hintText: 'Player 3',
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
                                            enabledBorder: UnderlineInputBorder(
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
                                      SizedBox(
                                        height: 16,
                                      ),
                                    ],
                                    if (_gamemode == Mode.threevsthree)
                                      DropdownButton<Character>(
                                        menuMaxHeight: 300,
                                        hint: Text(
                                          'Select Character',
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
                                    if (_gamemode == Mode.threevsthree)
                                      SizedBox(
                                        height: 16,
                                      ),
                                    if (_gamemode == Mode.threevsthree)
                                      SizedBox(
                                        width: 300,
                                        child: TextField(
                                          controller: _player5Controller,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor:
                                                CompanionAppTheme.lightText,
                                            hintText: 'Player 5',
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
                                            enabledBorder: UnderlineInputBorder(
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
                                    if (_gamemode == Mode.threevsthree)
                                      SizedBox(
                                        height: 16,
                                      ),
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
                            child: Column(
                              children: [
                                Text(
                                  _gamemode == Mode.twovstwo
                                      ? 'Team 2'
                                      : 'Player 2',
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
                                DropdownButton<Character>(
                                  menuMaxHeight: 300,
                                  hint: Text(
                                    'Select Character',
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
                                SizedBox(height: 16),
                                SizedBox(
                                  width: 300,
                                  child: TextField(
                                    controller: _player3Controller,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: CompanionAppTheme.lightText,
                                      hintText: _gamemode == Mode.twovstwo
                                          ? 'Player 2'
                                          : 'Player 2',
                                      contentPadding: const EdgeInsets.only(
                                          left: 14.0, bottom: 8.0, top: 8.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: CompanionAppTheme.lightText),
                                        borderRadius:
                                            BorderRadius.circular(25.7),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: CompanionAppTheme.lightText),
                                        borderRadius:
                                            BorderRadius.circular(25.7),
                                      ),
                                    ),
                                    cursorColor: CompanionAppTheme.darkerText,
                                  ),
                                ),
                                SizedBox(height: 16),
                                if (_gamemode == Mode.twovstwo ||
                                    _gamemode == Mode.threevsthree) ...[
                                  DropdownButton<Character>(
                                    menuMaxHeight: 300,
                                    hint: Text(
                                      'Select Character',
                                      style: TextStyle(
                                        fontFamily: CompanionAppTheme.fontName,
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
                                            color: CompanionAppTheme.lightText,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  SizedBox(height: 16),
                                  SizedBox(
                                    width: 300,
                                    child: TextField(
                                      controller: _player4Controller,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: CompanionAppTheme.lightText,
                                        hintText: 'Player 4',
                                        contentPadding: const EdgeInsets.only(
                                            left: 14.0, bottom: 8.0, top: 8.0),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  CompanionAppTheme.lightText),
                                          borderRadius:
                                              BorderRadius.circular(25.7),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  CompanionAppTheme.lightText),
                                          borderRadius:
                                              BorderRadius.circular(25.7),
                                        ),
                                      ),
                                      cursorColor: CompanionAppTheme.darkerText,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                ],
                                if (_gamemode == Mode.threevsthree)
                                  DropdownButton<Character>(
                                    menuMaxHeight: 300,
                                    hint: Text(
                                      'Select Character',
                                      style: TextStyle(
                                        fontFamily: CompanionAppTheme.fontName,
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
                                            color: CompanionAppTheme.lightText,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                if (_gamemode == Mode.threevsthree)
                                  SizedBox(height: 16),
                                if (_gamemode == Mode.threevsthree)
                                  SizedBox(
                                    width: 300,
                                    child: TextField(
                                      controller: _player6Controller,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: CompanionAppTheme.lightText,
                                        hintText: 'Player 6',
                                        contentPadding: const EdgeInsets.only(
                                            left: 14.0, bottom: 8.0, top: 8.0),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  CompanionAppTheme.lightText),
                                          borderRadius:
                                              BorderRadius.circular(25.7),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  CompanionAppTheme.lightText),
                                          borderRadius:
                                              BorderRadius.circular(25.7),
                                        ),
                                      ),
                                      cursorColor: CompanionAppTheme.darkerText,
                                    ),
                                  ),
                                if (_gamemode == Mode.threevsthree)
                                  SizedBox(height: 16),
                              ],
                            )),
                      ),
                      if (_gamemode == Mode.koth)
                        SizedBox(
                          height: 16,
                        ),
                      if (_gamemode == Mode.koth)
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
                              child: Column(
                                children: [
                                  Text(
                                    'Player 3',
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
                                  DropdownButton<Character>(
                                    menuMaxHeight: 300,
                                    hint: Text(
                                      'Select Character',
                                      style: TextStyle(
                                        fontFamily: CompanionAppTheme.fontName,
                                        fontWeight: FontWeight.normal,
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
                                            color: CompanionAppTheme.lightText,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  SizedBox(height: 16),
                                  SizedBox(
                                    width: 300,
                                    child: TextField(
                                      controller: _player2Controller,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: CompanionAppTheme.lightText,
                                        hintText: 'Player 3',
                                        contentPadding: const EdgeInsets.only(
                                            left: 14.0, bottom: 8.0, top: 8.0),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  CompanionAppTheme.lightText),
                                          borderRadius:
                                              BorderRadius.circular(25.7),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  CompanionAppTheme.lightText),
                                          borderRadius:
                                              BorderRadius.circular(25.7),
                                        ),
                                      ),
                                      cursorColor: CompanionAppTheme.darkerText,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                ],
                              )),
                        ),
                      SizedBox(height: 20),
                      Text(
                        'Select Winning Team',
                        style: TextStyle(
                          fontFamily: CompanionAppTheme.fontName,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 0.2,
                          color: CompanionAppTheme.lightText,
                        ),
                      ),
                      DropdownButton<String>(
                        hint: Text(
                          'Select Winner',
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
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: CompanionAppTheme.darkerText,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 20),
                                textStyle: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold)),
                            onPressed: () async {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CompanionAppHomeScreen(index: 0)));
                            },
                            child: const Text(
                              'Quit',
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
                                    horizontal: 50, vertical: 20),
                                textStyle: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold)),
                            onPressed: () async {
                              _submit(userService);
                            },
                            child: const Text(
                              'Save',
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
      child: Scaffold(
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
      ),
    );
  }
}
