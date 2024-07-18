import 'package:best_flutter_ui_templates/dt_companion/companion_app_theme.dart';
import 'package:best_flutter_ui_templates/dt_companion/models/heroes_list_data.dart';
import 'package:best_flutter_ui_templates/dt_companion/service.dart';
import 'package:best_flutter_ui_templates/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

import '../companion/match_view.dart';
import '../models/games_list_data.dart';

class GamesStatisticsView extends StatefulWidget {
  const GamesStatisticsView(
      {Key? key, this.animationController, this.animation, this.gamesListData})
      : super(key: key);

  final AnimationController? animationController;
  final Animation<double>? animation;
  final GamesListData? gamesListData;

  @override
  _GamesStatisticsViewState createState() => _GamesStatisticsViewState();
}

class _GamesStatisticsViewState extends State<GamesStatisticsView>
    with TickerProviderStateMixin {

  double getWinPercentage(int victories, int defeats) {
    return (victories / (victories + defeats) * 100);
  }

  @override
  void initState() {
    super.initState();
  }

  Color getBorderColorOne(String winner) {
    if (winner == 'Draw') {
      return CompanionAppTheme.drawOrange;
    } else if (winner == 'Team 1' || winner == 'You'){
      return CompanionAppTheme.victoryGreen;
    } else {
      return CompanionAppTheme.defeatRed;
    }
  }

  Color getBorderColorTwo(String winner) {
    if (winner == 'Draw') {
      return CompanionAppTheme.drawOrange;
    } else if (winner == 'Team 2' || winner == 'Player 2'){
      return CompanionAppTheme.victoryGreen;
    } else {
      return CompanionAppTheme.defeatRed;
    }
  }

  Color getBorderColorThree(String winner) {
    if (winner == 'Draw') {
      return CompanionAppTheme.drawOrange;
    } else if (winner == 'Player 3') {
      return CompanionAppTheme.victoryGreen;
    } else {
      return CompanionAppTheme.defeatRed;
    }
  }

  Future<void> deleteGame(UserService service) async {
    service.deleteGamesData(widget.gamesListData ?? GamesListData());
    String path = widget.gamesListData?.playerOneImagePath ?? '';
    String fileName = p.basenameWithoutExtension(path);
    HeroesListData hero = service.heroesListData.firstWhere((hero) => p.basenameWithoutExtension(hero.imagePath) == fileName);

    if (hero.totalGamesPlayed == 1) {
      service.deleteHeroesData(fileName);
    } else {
      if (widget.gamesListData?.winner == 'You' || widget.gamesListData?.playerOne == 'Team 1') {
        hero.victories -= 1;
      } else if (widget.gamesListData?.winner == 'Draw') {
        hero.draws -= 1;
      } else {
        hero.defeats -= 1;
      }
      service.updateHeroesData(hero);
    }
  }

  String getVictory() {
    final winner = widget.gamesListData?.winner;

    if (widget.gamesListData?.gamemode == Mode.onevsone) {
      if (winner == 'You') {
        return widget.gamesListData?.playerOne ?? '';
      } else {
        return widget.gamesListData?.playerThree ?? '';
      }
    } else if (widget.gamesListData?.gamemode == Mode.twovstwo) {
      if (winner == 'Team 1') {
        return '${widget.gamesListData?.playerOne} - ${widget.gamesListData?.playerTwo}';
      } else {
        return '${widget.gamesListData?.playerThree} - ${widget.gamesListData?.playerFour}';
      }
    } else {
      if (winner == 'You') {
        return '${widget.gamesListData?.playerOne}';
      } else if (winner == 'Player 2'){
        return '${widget.gamesListData?.playerTwo}';
      } else {
        return '${widget.gamesListData?.playerThree}';
      }
    }
  }

  String getDefeat() {
    final winner = widget.gamesListData?.winner;

    if (widget.gamesListData?.gamemode == Mode.onevsone) {
      if (winner == 'Player 2') {
        return widget.gamesListData?.playerOne ?? '';
      } else {
        return widget.gamesListData?.playerThree ?? '';
      }
    } else if (widget.gamesListData?.gamemode == Mode.twovstwo) {
      if (winner == 'Team 2') {
        return '${widget.gamesListData?.playerOne} - ${widget.gamesListData?.playerTwo}';
      } else {
        return '${widget.gamesListData?.playerThree} - ${widget.gamesListData?.playerFour}';
      }
    } else {
      if (winner == 'You') {
        return '${widget.gamesListData?.playerTwo} - ${widget.gamesListData?.playerThree}';
      } else if (winner == 'Player 2'){
        return '${widget.gamesListData?.playerOne} - ${widget.gamesListData?.playerThree}';
      } else {
        return '${widget.gamesListData?.playerOne} - ${widget.gamesListData?.playerTwo}';
      }
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
                          top: 16, left: 16, right: 16, bottom: 16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                    DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(widget.gamesListData?.date ?? 0)),
                                  style: TextStyle(
                                    fontFamily: CompanionAppTheme
                                        .fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    letterSpacing: -0.1,
                                    color: CompanionAppTheme
                                        .lightText
                                        .withOpacity(0.5),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8, right: 8, top: 4),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            height: 48,
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
                                                  padding: const EdgeInsets.only(
                                                      left: 4, bottom: 2),
                                                  child: Text(
                                                    'Victory',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily: CompanionAppTheme
                                                          .fontName,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 16,
                                                      letterSpacing: -0.1,
                                                      color: CompanionAppTheme
                                                          .victoryGreen
                                                          .withOpacity(0.5),
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
                                                        getVictory(),
                                                        textAlign: TextAlign.center,
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
                                            height: 48,
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
                                                    'Defeat',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily: CompanionAppTheme
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
                                                        getDefeat(),
                                                        textAlign: TextAlign.center,
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
                            )
                          ),
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
                                                color: getBorderColorOne(widget.gamesListData?.winner ?? ""),
                                                borderRadius: BorderRadius.circular(27),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: ClipOval(
                                              child: Image.asset(
                                                widget.gamesListData?.playerOneImagePath ?? '',
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
                                  if (widget.gamesListData?.gamemode == Mode.koth)
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
                                                  color: getBorderColorTwo(widget.gamesListData?.winner ?? ""),
                                                  borderRadius: BorderRadius.circular(27),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(6.0),
                                              child: ClipOval(
                                                child: Image.asset(
                                                  widget.gamesListData?.playerThreeImagePath ?? '',
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
                                  if (widget.gamesListData?.gamemode == Mode.twovstwo)
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
                                                  color: getBorderColorOne(widget.gamesListData?.winner ?? ""),
                                                  borderRadius: BorderRadius.circular(27),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(6.0),
                                              child: ClipOval(
                                                child: Image.asset(
                                                  widget.gamesListData?.playerThreeImagePath ?? '',
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
                                  if (widget.gamesListData?.gamemode == Mode.twovstwo)
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
                                                  color: getBorderColorTwo(widget.gamesListData?.winner ?? ""),
                                                  borderRadius: BorderRadius.circular(27),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(6.0),
                                              child: ClipOval(
                                                child: Image.asset(
                                                  widget.gamesListData?.playerFourImagePath ?? '',
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
                                                color: getBorderColorTwo(widget.gamesListData?.winner ?? ""),
                                                borderRadius: BorderRadius.circular(27),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: ClipOval(
                                              child: Image.asset(
                                                widget.gamesListData?.playerTwoImagePath ?? '',
                                                width: 42,
                                                height: 42,
                                                fit: BoxFit.cover,
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
                          )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16, bottom: 16),
                          child: InkWell(
                            onTap: () => {
                              deleteGame(userService)
                            },
                            child: Icon(
                              Icons.delete_forever,
                              color: CompanionAppTheme.lightText,
                              size: 26,
                            ),
                          )
                        ),
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
