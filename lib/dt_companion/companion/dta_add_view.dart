import 'dart:math';

import 'package:dt_companion/dt_companion/extension/localization_extension.dart';
import 'package:dt_companion/dt_companion/models/dta_cards.dart';
import 'package:dt_companion/dt_companion/models/dta_list_data.dart';
import 'package:dt_companion/dt_companion/profile/faq_screen.dart';
import 'package:dt_companion/dt_companion/service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_switch/flutter_switch.dart';

import '../companion_app_home_screen.dart';
import '../companion_app_theme.dart';
import '../models/heroes_list_data.dart';

class DTAAddView extends StatefulWidget {
  const DTAAddView({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  _DTAAddViewState createState() => _DTAAddViewState();
}

class _DTAAddViewState extends State<DTAAddView> with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  TextEditingController _teamNameController = TextEditingController();
  int _numberOfPlayers = 1;
  bool _legacyMode = false;
  int _difficulty = 0;
  bool _mythic = false;
  TextEditingController _player2Controller = TextEditingController();
  TextEditingController _player3Controller = TextEditingController();
  TextEditingController _player4Controller = TextEditingController();
  Character? _playerOne;
  Character? _playerTwo;
  Character? _playerThree;
  Character? _playerFour;

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));

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

  bool get _isFormValid {
    return _playerOne != null && _teamNameController.text != "";
  }

  int generateRandomId() {
    Random random = Random();
    int min = 1000000; // 7 digits minimum value (1 followed by 6 zeros)
    int max = 9999999; // 7 digits maximum value (7 nines)
    return min + random.nextInt(max - min + 1);
  }

  Future<void> _submit(UserService userService) async {
    if (_isFormValid) {
      List<Player> players = [
        Player(
            name: 'You',
            character: _playerOne!.displayName,
            commonCards: [],
            rareCards: [],
            epicCards: [],
            legendaryCards: [])
      ];

      if (_numberOfPlayers > 1) {
        players.add(Player(
            name: _player2Controller.text == ""
                ? "Player 2"
                : _player2Controller.text,
            character: _playerTwo!.displayName,
            commonCards: [],
            rareCards: [],
            epicCards: [],
            legendaryCards: []));
      }

      if (_numberOfPlayers > 2) {
        players.add(Player(
            name: _player3Controller.text == ""
                ? "Player 3"
                : _player3Controller.text,
            character: _playerThree!.displayName,
            commonCards: [],
            rareCards: [],
            epicCards: [],
            legendaryCards: []));
      }

      if (_numberOfPlayers > 3) {
        players.add(Player(
            name: _player4Controller.text == ""
                ? "Player 4"
                : _player4Controller.text,
            character: _playerFour!.displayName,
            commonCards: [],
            rareCards: [],
            epicCards: [],
            legendaryCards: []));
      }

      var dtaData = DTAListData(
          id: generateRandomId(),
          teamName: _teamNameController.text,
          campaignScore: 0,
          players: players,
          legacyMode: _legacyMode,
          difficulty: _difficulty,
          mythic: _mythic,
          date: DateTime.now().millisecondsSinceEpoch,
          scoreboards: [],
          inprogress: true,
          commonCards: List.from(commonDTACardsList),
          rareCards: List.from(rareDTACardsList),
          epicCards: List.from(epicDTACardsList),
          legendaryCards: List.from(legendaryDTACardsList));

      try {
        userService.insertDtaData(dtaData);
      } catch (e) {
        print(e);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('dta_add_created'.tr(context))),
      );

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CompanionAppHomeScreen(index: 1)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('snack_match_missing'.tr(context))),
      );
    }
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

  Widget getMainListViewUI(UserService userService) {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.only(
        top: AppBar().preferredSize.height +
            MediaQuery.of(context).padding.top +
            80,
        bottom: 62 + MediaQuery.of(context).padding.bottom,
      ),
      itemCount: 1,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        widget.animationController?.forward();
        return SingleChildScrollView(
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
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
                                child: Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 16.0,
                                          left: 16.0,
                                          right: 16.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'dta_add_team_name'.tr(context),
                                                style: TextStyle(
                                                  fontFamily: CompanionAppTheme
                                                      .fontName,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  letterSpacing: 0.2,
                                                  color: CompanionAppTheme
                                                      .lightText,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          SizedBox(
                                            width: 300,
                                            child: TextField(
                                              controller: _teamNameController,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor:
                                                    CompanionAppTheme.lightText,
                                                hintText: 'dta_add_required'.tr(context),
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
                                        ],
                                      )),
                                  Divider(
                                    color: CompanionAppTheme.lightText,
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16.0, horizontal: 16.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'dta_add_number_players'.tr(context),
                                                style: TextStyle(
                                                  fontFamily: CompanionAppTheme
                                                      .fontName,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  letterSpacing: 0.2,
                                                  color: CompanionAppTheme
                                                      .lightText,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          NumberPicker(
                                            value: _numberOfPlayers,
                                            minValue: 1,
                                            maxValue: 4,
                                            step: 1,
                                            itemHeight: 66,
                                            itemWidth: 66,
                                            selectedTextStyle: TextStyle(
                                              fontFamily:
                                                  CompanionAppTheme.fontName,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 28,
                                              letterSpacing: 0.2,
                                              color:
                                                  CompanionAppTheme.lightText,
                                            ),
                                            textStyle: TextStyle(
                                              fontFamily:
                                                  CompanionAppTheme.fontName,
                                              fontWeight: FontWeight.w100,
                                              fontSize: 18,
                                              letterSpacing: 0.2,
                                              color: CompanionAppTheme.lightText
                                                  .withOpacity(0.5),
                                            ),
                                            axis: Axis.horizontal,
                                            onChanged: (value) => setState(
                                                () => _numberOfPlayers = value),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                  color: CompanionAppTheme
                                                      .lightText,
                                                  width: 4),
                                            ),
                                          ),
                                        ],
                                      )),
                                  Divider(
                                    color: CompanionAppTheme.lightText,
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16.0, horizontal: 16.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'dta_add_legacy'.tr(context),
                                                style: TextStyle(
                                                  fontFamily: CompanionAppTheme
                                                      .fontName,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  letterSpacing: 0.2,
                                                  color: CompanionAppTheme
                                                      .lightText,
                                                ),
                                              ),
                                              Spacer(),
                                              FlutterSwitch(
                                                value: _legacyMode,
                                                activeColor:
                                                    CompanionAppTheme.lightText,
                                                toggleColor:
                                                    CompanionAppTheme.dark_grey,
                                                onToggle: (val) {
                                                  setState(() {
                                                    _legacyMode = val;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      )),
                                  Divider(
                                    color: CompanionAppTheme.lightText,
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16.0, horizontal: 16.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'dta_add_difficulty'.tr(context),
                                                style: TextStyle(
                                                  fontFamily: CompanionAppTheme
                                                      .fontName,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  letterSpacing: 0.2,
                                                  color: CompanionAppTheme
                                                      .lightText,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          CupertinoSegmentedControl<int>(
                                            selectedColor:
                                                CompanionAppTheme.lightText,
                                            borderColor:
                                                CompanionAppTheme.lightText,
                                            unselectedColor:
                                                CompanionAppTheme.dark_grey,
                                            children: {
                                              0: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 16.0),
                                                child: Text('dta_difficulty_normal'.tr(context)),
                                              ),
                                              1: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 16.0),
                                                child: Text('dta_difficulty_veteran'.tr(context)),
                                              ),
                                            },
                                            onValueChanged: (int value) {
                                              setState(() {
                                                _difficulty = value;
                                              });
                                            },
                                            groupValue: _difficulty,
                                          ),
                                        ],
                                      )),
                                  Divider(
                                    color: CompanionAppTheme.lightText,
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16.0, horizontal: 16.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'dta_add_mythic'.tr(context),
                                                style: TextStyle(
                                                  fontFamily: CompanionAppTheme
                                                      .fontName,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  letterSpacing: 0.2,
                                                  color: CompanionAppTheme
                                                      .lightText,
                                                ),
                                              ),
                                              Spacer(),
                                              FlutterSwitch(
                                                value: _mythic,
                                                activeColor:
                                                    CompanionAppTheme.lightText,
                                                toggleColor:
                                                    CompanionAppTheme.dark_grey,
                                                onToggle: (val) {
                                                  setState(() {
                                                    _mythic = val;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      )),
                                  Divider(
                                    color: CompanionAppTheme.lightText,
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16.0, horizontal: 16.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'You'.tr(context),
                                                style: TextStyle(
                                                  fontFamily: CompanionAppTheme
                                                      .fontName,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  letterSpacing: 0.2,
                                                  color: CompanionAppTheme
                                                      .lightText,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              DropdownButton<Character>(
                                                menuMaxHeight: 300,
                                                hint: Text(
                                                  'character_select'.tr(context),
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
                                                value: _playerOne,
                                                onChanged:
                                                    (Character? newValue) {
                                                  setState(() {
                                                    _playerOne = newValue;
                                                  });
                                                },
                                                items: Character.values
                                                    .map((Character character) {
                                                  return DropdownMenuItem<
                                                      Character>(
                                                    value: character,
                                                    child: Text(
                                                      character.displayName,
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
                                              ),
                                            ],
                                          ),
                                        ],
                                      )),
                                  if (_numberOfPlayers > 1)
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16.0, horizontal: 16.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'Player 2'.tr(context),
                                                  style: TextStyle(
                                                    fontFamily:
                                                        CompanionAppTheme
                                                            .fontName,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    letterSpacing: 0.2,
                                                    color: CompanionAppTheme
                                                        .lightText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                DropdownButton<Character>(
                                                  menuMaxHeight: 300,
                                                  hint: Text(
                                                    'character_select'.tr(context),
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
                                                  value: _playerTwo,
                                                  onChanged:
                                                      (Character? newValue) {
                                                    setState(() {
                                                      _playerTwo = newValue;
                                                    });
                                                  },
                                                  items: Character.values.map(
                                                      (Character character) {
                                                    return DropdownMenuItem<
                                                        Character>(
                                                      value: character,
                                                      child: Text(
                                                        character.displayName,
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
                                                ),
                                                SizedBox(
                                                  height: 16,
                                                ),
                                                SizedBox(
                                                  width: 300,
                                                  child: TextField(
                                                    controller:
                                                        _player2Controller,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor:
                                                          CompanionAppTheme
                                                              .lightText,
                                                      hintText: 'Player 2'.tr(context),
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
                                                            BorderRadius
                                                                .circular(25.7),
                                                      ),
                                                      enabledBorder:
                                                          UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                CompanionAppTheme
                                                                    .lightText),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25.7),
                                                      ),
                                                    ),
                                                    cursorColor:
                                                        CompanionAppTheme
                                                            .darkerText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )),
                                  if (_numberOfPlayers > 2)
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16.0, horizontal: 16.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'Player 3'.tr(context),
                                                  style: TextStyle(
                                                    fontFamily:
                                                        CompanionAppTheme
                                                            .fontName,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    letterSpacing: 0.2,
                                                    color: CompanionAppTheme
                                                        .lightText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                DropdownButton<Character>(
                                                  menuMaxHeight: 300,
                                                  hint: Text(
                                                    'character_select'.tr(context),
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
                                                  value: _playerThree,
                                                  onChanged:
                                                      (Character? newValue) {
                                                    setState(() {
                                                      _playerThree = newValue;
                                                    });
                                                  },
                                                  items: Character.values.map(
                                                      (Character character) {
                                                    return DropdownMenuItem<
                                                        Character>(
                                                      value: character,
                                                      child: Text(
                                                        character.displayName,
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
                                                ),
                                                SizedBox(
                                                  height: 16,
                                                ),
                                                SizedBox(
                                                  width: 300,
                                                  child: TextField(
                                                    controller:
                                                        _player3Controller,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor:
                                                          CompanionAppTheme
                                                              .lightText,
                                                      hintText: 'Player 3'.tr(context),
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
                                                            BorderRadius
                                                                .circular(25.7),
                                                      ),
                                                      enabledBorder:
                                                          UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                CompanionAppTheme
                                                                    .lightText),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25.7),
                                                      ),
                                                    ),
                                                    cursorColor:
                                                        CompanionAppTheme
                                                            .darkerText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )),
                                  if (_numberOfPlayers > 3)
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16.0, horizontal: 16.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'Player 4'.tr(context),
                                                  style: TextStyle(
                                                    fontFamily:
                                                        CompanionAppTheme
                                                            .fontName,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    letterSpacing: 0.2,
                                                    color: CompanionAppTheme
                                                        .lightText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                DropdownButton<Character>(
                                                  menuMaxHeight: 300,
                                                  hint: Text(
                                                    'character_select'.tr(context),
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
                                                  value: _playerFour,
                                                  onChanged:
                                                      (Character? newValue) {
                                                    setState(() {
                                                      _playerFour = newValue;
                                                    });
                                                  },
                                                  items: Character.values.map(
                                                      (Character character) {
                                                    return DropdownMenuItem<
                                                        Character>(
                                                      value: character,
                                                      child: Text(
                                                        character.displayName,
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
                                                ),
                                                SizedBox(
                                                  height: 16,
                                                ),
                                                SizedBox(
                                                  width: 300,
                                                  child: TextField(
                                                    controller:
                                                        _player4Controller,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor:
                                                          CompanionAppTheme
                                                              .lightText,
                                                      hintText: 'Player 4'.tr(context),
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
                                                            BorderRadius
                                                                .circular(25.7),
                                                      ),
                                                      enabledBorder:
                                                          UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                CompanionAppTheme
                                                                    .lightText),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25.7),
                                                      ),
                                                    ),
                                                    cursorColor:
                                                        CompanionAppTheme
                                                            .darkerText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )),
                                ]),
                              ))),
                      SizedBox(height: 16),
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
                                          CompanionAppHomeScreen(
                                            index: 1,
                                          )));
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
                                    horizontal: 50, vertical: 20),
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
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
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
                                child: SizedBox(
                                  width: 20,
                                  height: 88,
                                  child: FittedBox(
                                    child: Image.asset(
                                        'assets/dt_companion/dicethronelogo.webp'),
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 8, right: 8, top: 24, bottom: 8),
                                child: Text(
                                  'DTA',
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
}
