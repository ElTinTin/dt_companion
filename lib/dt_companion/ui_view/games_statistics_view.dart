import 'package:dt_companion/dt_companion/companion_app_theme.dart';
import 'package:dt_companion/dt_companion/extension/localization_extension.dart';
import 'package:dt_companion/dt_companion/models/heroes_data.dart';
import 'package:dt_companion/dt_companion/service.dart';
import 'package:dt_companion/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

import '../companion/match_view.dart';
import '../models/games_data.dart';

class GamesStatisticsView extends StatefulWidget {
  const GamesStatisticsView(
      {Key? key, this.animationController, this.animation, this.gamesListData})
      : super(key: key);

  final AnimationController? animationController;
  final Animation<double>? animation;
  final GamesData? gamesListData;

  @override
  _GamesStatisticsViewState createState() => _GamesStatisticsViewState();
}

class _GamesStatisticsViewState extends State<GamesStatisticsView>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  void showAlertDialog(BuildContext context, UserService service) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(
        "alert_cancel".tr(context),
        style: TextStyle(color: CompanionAppTheme.lightText),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
      style: ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all<Color>(CompanionAppTheme.dark_grey),
      ),
    );
    Widget continueButton = TextButton(
      child: Text(
        "alert_continue".tr(context),
        style: TextStyle(color: CompanionAppTheme.lightText),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        deleteGame(service);
      },
      style: ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all<Color>(CompanionAppTheme.darkerText),
      ),
    );

    AlertDialog alert = AlertDialog(
      title: Text(
        "alert_games_titles".tr(context),
        style: TextStyle(color: CompanionAppTheme.dark_grey),
      ),
      content: Text(
        "alert_games_desc".tr(context),
        style: TextStyle(color: CompanionAppTheme.dark_grey),
      ),
      backgroundColor: CompanionAppTheme.lightText,
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Color getBorderColorOne(String winner) {
    if (winner == 'Draw'.tr(context)) {
      return CompanionAppTheme.drawOrange;
    } else if (winner == 'Team 1'.tr(context) || winner == 'You'.tr(context)) {
      return CompanionAppTheme.victoryGreen;
    } else {
      return CompanionAppTheme.defeatRed;
    }
  }

  Color getBorderColorTwo(String winner) {
    if (winner == 'Draw'.tr(context)) {
      return CompanionAppTheme.drawOrange;
    } else if (winner == 'Team 2'.tr(context) || winner == 'Player 2'.tr(context)) {
      return CompanionAppTheme.victoryGreen;
    } else {
      return CompanionAppTheme.defeatRed;
    }
  }

  Color getBorderColorThree(String winner) {
    if (winner == 'Draw'.tr(context)) {
      return CompanionAppTheme.drawOrange;
    } else if (winner == 'Player 3'.tr(context)) {
      return CompanionAppTheme.victoryGreen;
    } else {
      return CompanionAppTheme.defeatRed;
    }
  }

  Future<void> deleteGame(UserService service) async {
    service.deleteGamesData(widget.gamesListData ?? GamesData());
    String path = widget.gamesListData?.playerOneImagePath ?? '';
    String fileName = p.basenameWithoutExtension(path);
    HeroesData hero = service.heroesListData.firstWhere(
        (hero) => p.basenameWithoutExtension(hero.imagePath) == fileName);

    if (hero.totalGamesPlayed == 1) {
      service.deleteHeroesData(hero);
    } else {
      if (widget.gamesListData?.winner == 'You'.tr(context) ||
          widget.gamesListData?.winner == 'Team 1'.tr(context)
      ) {
        hero.victories -= 1;
      } else if (widget.gamesListData?.winner == 'Draw'.tr(context)) {
        hero.draws -= 1;
      } else {
        hero.defeats -= 1;
      }
      service.updateHeroesData(hero);
    }
  }

  String getPlayerText(String? playerName, String customText, BuildContext context) {
    return (playerName ?? "") == customText ? "$customText".tr(context) : playerName ?? "";
  }

  String getVictory(BuildContext context) {
    final winner = widget.gamesListData?.winner;

    if (widget.gamesListData?.gamemode == Mode.onevsone) {
      if (winner == 'You'.tr(context) || winner == 'You') {
        return widget.gamesListData?.playerOne.tr(context) ?? '';
      } else {
        return '${getPlayerText(widget.gamesListData?.playerTwo, "Player 2", context)}';
      }
    } else if (widget.gamesListData?.gamemode == Mode.twovstwo) {
      if (winner == 'Team 1'.tr(context) || winner == 'Team 1') {
        return '${widget.gamesListData?.playerOne.tr(context)} \n${getPlayerText(widget.gamesListData?.playerThree, "Player 3", context)}';
      } else {
        return '${getPlayerText(widget.gamesListData?.playerTwo, "Player 2", context)} \n${getPlayerText(widget.gamesListData?.playerFour, "Player 4", context)}';
      }
    } else if (widget.gamesListData?.gamemode == Mode.koth) {
      if (winner == 'You'.tr(context) || winner == 'You') {
        return '${widget.gamesListData?.playerOne.tr(context)}';
      } else if (winner == 'Player 2'.tr(context) || winner == 'Player 2') {
        return '${getPlayerText(widget.gamesListData?.playerTwo, "Player 2", context)}';
      } else {
        return '${getPlayerText(widget.gamesListData?.playerThree, "Player 3", context)}';
      }
    } else {
      if (winner == 'Team 1'.tr(context) || winner == 'Team 1') {
        return '${widget.gamesListData?.playerOne.tr(context)} \n${getPlayerText(widget.gamesListData?.playerTwo, "Player 2", context)} \n${getPlayerText(widget.gamesListData?.playerFive, "Player 5", context)}';
      } else {
        return '${getPlayerText(widget.gamesListData?.playerThree, "Player 3", context)} \n${getPlayerText(widget.gamesListData?.playerFour, "Player 4", context)} \n${getPlayerText(widget.gamesListData?.playerSix, "Player 6", context)}';
      }
    }
  }

  String getDefeat(BuildContext context) {
    final winner = widget.gamesListData?.winner;

    if (widget.gamesListData?.gamemode == Mode.onevsone) {
      if (winner == 'Player 2'.tr(context) || winner == 'Player 2') {
        return widget.gamesListData?.playerOne.tr(context) ?? '';
      } else {
        return '${getPlayerText(widget.gamesListData?.playerTwo, "Player 2", context)}';
      }
    } else if (widget.gamesListData?.gamemode == Mode.twovstwo) {
      if (winner == 'Team 2'.tr(context) || winner == 'Team 2') {
        return '${widget.gamesListData?.playerOne.tr(context)} \n${getPlayerText(widget.gamesListData?.playerThree, "Player 3", context)}';
      } else {
        return '${getPlayerText(widget.gamesListData?.playerTwo, "Player 2", context)} \n${getPlayerText(widget.gamesListData?.playerFour, "Player 4", context)}';
      }
    } else if (widget.gamesListData?.gamemode == Mode.koth) {
      if (winner == 'You'.tr(context) || winner == 'You') {
        return '${getPlayerText(widget.gamesListData?.playerTwo, "Player 2", context)} \n${getPlayerText(widget.gamesListData?.playerThree, "Player 3", context)}';
      } else if (winner == 'Player 2'.tr(context) || winner == 'Player 2') {
        return '${widget.gamesListData?.playerOne.tr(context)} \n${getPlayerText(widget.gamesListData?.playerThree, "Player 3", context)}';
      } else {
        return '${widget.gamesListData?.playerOne.tr(context)} \n${getPlayerText(widget.gamesListData?.playerTwo, "Player 2", context)}';
      }
    } else {
      if (winner == 'Team 2'.tr(context) || winner == 'Team 2') {
        return '${widget.gamesListData?.playerOne.tr(context)} \n${getPlayerText(widget.gamesListData?.playerTwo, "Player 2", context)} \n${getPlayerText(widget.gamesListData?.playerFive, "Player 5", context)}';
      } else {
        return '${getPlayerText(widget.gamesListData?.playerThree, "Player 3", context)} \n${getPlayerText(widget.gamesListData?.playerFour, "Player 4", context)} \n${getPlayerText(widget.gamesListData?.playerSix, "Player 6", context)}';
      }
    }
  }

  double getBorderHeight() {
    if (widget.gamesListData?.gamemode == Mode.onevsone) {
      return 48;
    } else if (widget.gamesListData?.gamemode == Mode.twovstwo) {
      return 80;
    } else {
      return 110;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);

    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.animation!,
          child: new Transform(
            transform: new Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 16, bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <HexColor>[
                      HexColor('#161A25'),
                      HexColor('#313A44'),
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
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 16, left: 16, right: 16, bottom: 8),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8, right: 8, top: 4),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          height: getBorderHeight(),
                                          width: 2,
                                          decoration: BoxDecoration(
                                            color: HexColor('#A6BC04')
                                                .withOpacity(0.75),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(4.0)),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 4, bottom: 2),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        'victory'.tr(context),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              CompanionAppTheme
                                                                  .fontName,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 16,
                                                          letterSpacing: -0.1,
                                                          color:
                                                              CompanionAppTheme
                                                                  .victoryGreen
                                                                  .withOpacity(
                                                                      0.5),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 8,
                                                      ),
                                                      ClipOval(
                                                        child: Container(
                                                          width: 28,
                                                          height: 28,
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                CompanionAppTheme
                                                                    .victoryGreen,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              '${widget.gamesListData?.winnerHealth}',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    CompanionAppTheme
                                                                        .fontName,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                                letterSpacing:
                                                                    0.2,
                                                                color: CompanionAppTheme
                                                                    .darkerText,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 4, bottom: 3),
                                                    child: Text(
                                                      getVictory(context),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            CompanionAppTheme
                                                                .fontName,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 20,
                                                        color: CompanionAppTheme
                                                            .lightText,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          height: getBorderHeight(),
                                          width: 2,
                                          decoration: BoxDecoration(
                                            color: CompanionAppTheme.defeatRed
                                                .withOpacity(0.75),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(4.0)),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 4, bottom: 2),
                                                child: Text(
                                                  'defeat'.tr(context),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        CompanionAppTheme
                                                            .fontName,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16,
                                                    letterSpacing: -0.1,
                                                    color: CompanionAppTheme
                                                        .defeatRed
                                                        .withOpacity(0.75),
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 4, bottom: 3),
                                                    child: Text(
                                                      getDefeat(context),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            CompanionAppTheme
                                                                .fontName,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 20,
                                                        color: CompanionAppTheme
                                                            .lightText,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          )),
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Center(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            '',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily:
                                                  CompanionAppTheme.fontName,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              letterSpacing: 0.0,
                                              color: CompanionAppTheme.lightText
                                                  .withOpacity(0.75),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    left: 0,
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
                                                color: getBorderColorOne(widget
                                                        .gamesListData
                                                        ?.winner ??
                                                    ""),
                                                borderRadius:
                                                    BorderRadius.circular(27),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: ClipOval(
                                              child: Image.asset(
                                                widget.gamesListData
                                                        ?.playerOneImagePath ??
                                                    '',
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
                                  Positioned(
                                    top: -10,
                                    left: -6,
                                    child: ClipOval(
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: CompanionAppTheme.lightText,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${widget.gamesListData?.playerOneUltimates}',
                                            style: TextStyle(
                                              fontFamily:
                                                  CompanionAppTheme.fontName,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              letterSpacing: 0.2,
                                              color:
                                                  CompanionAppTheme.darkerText,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 48,
                                    left: 32,
                                    child: SizedBox(
                                      width: 54,
                                      height: 54,
                                      child: Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Text(
                                            'vs.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily:
                                                  CompanionAppTheme.fontName,
                                              fontWeight: FontWeight.w100,
                                              fontSize: 16,
                                              color:
                                                  CompanionAppTheme.lightText,
                                            ),
                                          )),
                                    ),
                                  ),
                                  if (widget.gamesListData?.gamemode ==
                                      Mode.koth) ...[
                                    Positioned(
                                      top: 0,
                                      right: 0,
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
                                                  color: getBorderColorTwo(
                                                      widget.gamesListData
                                                              ?.winner ??
                                                          ""),
                                                  borderRadius:
                                                      BorderRadius.circular(27),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: ClipOval(
                                                child: Image.asset(
                                                  widget.gamesListData
                                                          ?.playerThreeImagePath ??
                                                      '',
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
                                    Positioned(
                                      top: -10,
                                      right: -6,
                                      child: ClipOval(
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: CompanionAppTheme.lightText,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${widget.gamesListData?.playerThreeUltimates}',
                                              style: TextStyle(
                                                fontFamily:
                                                    CompanionAppTheme.fontName,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                letterSpacing: 0.2,
                                                color: CompanionAppTheme
                                                    .darkerText,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (widget.gamesListData?.gamemode ==
                                          Mode.twovstwo ||
                                      widget.gamesListData?.gamemode ==
                                          Mode.threevsthree) ...[
                                    Positioned(
                                      top: 0,
                                      left: 60,
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
                                                  color: getBorderColorOne(
                                                      widget.gamesListData
                                                              ?.winner ??
                                                          ""),
                                                  borderRadius:
                                                      BorderRadius.circular(27),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: ClipOval(
                                                child: Image.asset(
                                                  widget.gamesListData
                                                          ?.playerThreeImagePath ??
                                                      '',
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
                                    Positioned(
                                      top: -10,
                                      right: -6,
                                      child: ClipOval(
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: CompanionAppTheme.lightText,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${widget.gamesListData?.playerThreeUltimates}',
                                              style: TextStyle(
                                                fontFamily:
                                                    CompanionAppTheme.fontName,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                letterSpacing: 0.2,
                                                color: CompanionAppTheme
                                                    .darkerText,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (widget.gamesListData?.gamemode ==
                                          Mode.twovstwo ||
                                      widget.gamesListData?.gamemode ==
                                          Mode.threevsthree) ... [
                                    Positioned(
                                      bottom: -16,
                                      right: 60,
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
                                                  color: getBorderColorTwo(
                                                      widget.gamesListData
                                                          ?.winner ??
                                                          ""),
                                                  borderRadius:
                                                  BorderRadius.circular(27),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                              const EdgeInsets.all(6.0),
                                              child: ClipOval(
                                                child: Image.asset(
                                                  widget.gamesListData
                                                      ?.playerFourImagePath ??
                                                      '',
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
                                    Positioned(
                                      bottom: -20,
                                      right: 98,
                                      child: ClipOval(
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: CompanionAppTheme.lightText,
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${widget.gamesListData?.playerFourUltimates}',
                                              style: TextStyle(
                                                fontFamily:
                                                CompanionAppTheme.fontName,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                letterSpacing: 0.2,
                                                color: CompanionAppTheme
                                                    .darkerText,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (widget.gamesListData?.gamemode ==
                                      Mode.threevsthree) ... [
                                    Positioned(
                                      bottom: -64,
                                      right: 30,
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
                                                  color: getBorderColorTwo(
                                                      widget.gamesListData
                                                          ?.winner ??
                                                          ""),
                                                  borderRadius:
                                                  BorderRadius.circular(27),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                              const EdgeInsets.all(6.0),
                                              child: ClipOval(
                                                child: Image.asset(
                                                  widget.gamesListData
                                                      ?.playerSixImagePath ??
                                                      '',
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
                                    Positioned(
                                      bottom: -70,
                                      right: 20,
                                      child: ClipOval(
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: CompanionAppTheme.lightText,
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${widget.gamesListData?.playerSixUltimates}',
                                              style: TextStyle(
                                                fontFamily:
                                                CompanionAppTheme.fontName,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                letterSpacing: 0.2,
                                                color: CompanionAppTheme
                                                    .darkerText,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (widget.gamesListData?.gamemode ==
                                      Mode.threevsthree) ... [
                                    Positioned(
                                      top: -50,
                                      right: 31,
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
                                                  color: getBorderColorOne(
                                                      widget.gamesListData
                                                          ?.winner ??
                                                          ""),
                                                  borderRadius:
                                                  BorderRadius.circular(27),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                              const EdgeInsets.all(6.0),
                                              child: ClipOval(
                                                child: Image.asset(
                                                  widget.gamesListData
                                                      ?.playerFiveImagePath ??
                                                      '',
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
                                    Positioned(
                                      top: -60,
                                      right: 20,
                                      child: ClipOval(
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: CompanionAppTheme.lightText,
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${widget.gamesListData?.playerFiveUltimates}',
                                              style: TextStyle(
                                                fontFamily:
                                                CompanionAppTheme.fontName,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                letterSpacing: 0.2,
                                                color: CompanionAppTheme
                                                    .darkerText,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  Positioned(
                                    bottom: -16,
                                    right: 0,
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
                                                color: getBorderColorTwo(widget
                                                        .gamesListData
                                                        ?.winner ??
                                                    ""),
                                                borderRadius:
                                                    BorderRadius.circular(27),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: ClipOval(
                                              child: Image.asset(
                                                widget.gamesListData
                                                        ?.playerTwoImagePath ??
                                                    '',
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
                                  Positioned(
                                    bottom: -22,
                                    right: -12,
                                    child: ClipOval(
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: CompanionAppTheme.lightText,
                                          borderRadius:
                                          BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${widget.gamesListData?.playerTwoUltimates}',
                                            style: TextStyle(
                                              fontFamily:
                                              CompanionAppTheme.fontName,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              letterSpacing: 0.2,
                                              color: CompanionAppTheme
                                                  .darkerText,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Divider(
                      color: CompanionAppTheme.lightText,
                      thickness: 1,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 8),
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    widget.gamesListData?.date ?? 0)),
                            style: TextStyle(
                              fontFamily: CompanionAppTheme.fontName,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              letterSpacing: -0.1,
                              color:
                                  CompanionAppTheme.lightText.withOpacity(0.5),
                            ),
                          ),
                        ),
                        Spacer(),
                        Padding(
                            padding:
                                const EdgeInsets.only(right: 16, bottom: 8),
                            child: InkWell(
                              onTap: () =>
                                  {showAlertDialog(context, userService)},
                              child: Icon(
                                Icons.delete_forever,
                                color: CompanionAppTheme.lightText,
                                size: 26,
                              ),
                            )),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
