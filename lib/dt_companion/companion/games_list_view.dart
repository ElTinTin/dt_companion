import 'package:dt_companion/dt_companion/companion/heroes_list_view.dart';
import 'package:dt_companion/dt_companion/companion_app_theme.dart';
import 'package:dt_companion/dt_companion/extension/localization_extension.dart';
import 'package:dt_companion/dt_companion/models/games_data.dart';
import 'package:dt_companion/dt_companion/service.dart';
import 'package:dt_companion/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'match_view.dart';

class GamesListView extends StatefulWidget {
  const GamesListView(
      {Key? key, this.mainScreenAnimationController, this.mainScreenAnimation})
      : super(key: key);

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;

  @override
  _GamesListViewState createState() => _GamesListViewState();
}

class _GamesListViewState extends State<GamesListView>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  Widget getGamesList(List<GamesData> gamesListData) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 0, bottom: 0, right: 16, left: 16),
      itemCount: gamesListData.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
            .animate(CurvedAnimation(
                parent: animationController!,
                curve: Interval((1 / gamesListData.length) * index, 1.0,
                    curve: Curves.fastOutSlowIn)));
        animationController?.forward();

        return Padding(
          padding:
              const EdgeInsets.only(top: 0, bottom: 0, right: 12, left: 12),
          child: GameView(
            gamesListData: gamesListData[index],
            animation: animation,
            animationController: animationController!,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);

    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController!,
      builder: (BuildContext context, Widget? child) {
        final count = userService.gamesListData.isEmpty ? 1 : 10;
        final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
            .animate(CurvedAnimation(
                parent: animationController!,
                curve: Interval((1 / count) * 1, 1.0,
                    curve: Curves.fastOutSlowIn)));
        animationController?.forward();

        return FadeTransition(
          opacity: widget.mainScreenAnimation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.mainScreenAnimation!.value), 0.0),
            child: Container(
                height: 216,
                width: double.infinity,
                child: Stack(
                  children: [
                    if (!userService.gamesListData.isEmpty)
                      getGamesList(userService.gamesListData.take(10).toList())
                    else
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 0, left: 16, right: 8, bottom: 8),
                        child: EmptyStatsView(
                          animation: animation,
                          animationController: animationController!,
                        ),
                      )
                  ],
                )),
          ),
        );
      },
    );
  }
}

class GameView extends StatelessWidget {
  const GameView(
      {Key? key, this.gamesListData, this.animationController, this.animation})
      : super(key: key);

  final GamesData? gamesListData;
  final AnimationController? animationController;
  final Animation<double>? animation;

  String getPlayerText(
      String? playerName, String customText, BuildContext context) {
    if (playerName == customText || playerName == customText.tr(context)) {
      return "$customText".tr(context);
    } else {
      return playerName ?? "";
    }
  }

  Color getBorderColorOne(String winner, BuildContext context) {
    if (winner == 'Draw'.tr(context) || winner == 'Draw') {
      return CompanionAppTheme.drawOrange;
    } else if (winner == 'Team 1'.tr(context) ||
        winner == 'You'.tr(context) ||
        winner == 'Team 1' ||
        winner == "You") {
      return CompanionAppTheme.victoryGreen;
    } else {
      return CompanionAppTheme.defeatRed;
    }
  }

  Color getBorderColorTwo(String winner, BuildContext context) {
    if (winner == 'Draw'.tr(context) || winner == 'Draw') {
      return CompanionAppTheme.drawOrange;
    } else if (winner == 'Team 2'.tr(context) ||
        winner == 'Player 2'.tr(context) ||
        winner == 'Team 2' ||
        winner == 'Player 2') {
      return CompanionAppTheme.victoryGreen;
    } else {
      return CompanionAppTheme.defeatRed;
    }
  }

  Color getBorderColorThree(String winner, BuildContext context) {
    if (winner == 'Draw'.tr(context) || winner == 'Draw') {
      return CompanionAppTheme.drawOrange;
    } else if (winner == 'Player 3'.tr(context) || winner == 'Player 3') {
      return CompanionAppTheme.victoryGreen;
    } else {
      return CompanionAppTheme.defeatRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                100 * (1.0 - animation!.value), 0.0, 0.0),
            child: SizedBox(
              width: gamesListData?.playerTwo != "" ? 180 : 130,
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 32, left: 8, right: 8, bottom: 16),
                    child: Container(
                      width:
                          gamesListData?.gamemode != Mode.onevsone ? 180 : 150,
                      decoration: BoxDecoration(
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: HexColor("#313A44").withOpacity(0.6),
                              offset: const Offset(1.1, 4.0),
                              blurRadius: 8.0),
                        ],
                        gradient: LinearGradient(
                          colors: <HexColor>[
                            HexColor("#161A25"),
                            HexColor("#313A44"),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(8.0),
                          bottomLeft: Radius.circular(54.0),
                          topLeft: Radius.circular(8.0),
                          topRight: gamesListData?.gamemode == Mode.koth
                              ? Radius.circular(8.0)
                              : Radius.circular(54.0),
                        ),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.only(
                              top: 8, left: 8, right: 8, bottom: 8),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                if (gamesListData?.gamemode == Mode.twovstwo)
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${gamesListData?.playerOne}'
                                            .tr(context),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily:
                                              CompanionAppTheme.fontName,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          letterSpacing: 0.2,
                                          color: CompanionAppTheme.lightText,
                                        ),
                                      ),
                                      Text(
                                        ' - ${getPlayerText(gamesListData?.playerThree, "Player 3", context)}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily:
                                              CompanionAppTheme.fontName,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          letterSpacing: 0.2,
                                          color: CompanionAppTheme.lightText,
                                        ),
                                      ),
                                    ],
                                  ),
                                if (gamesListData?.gamemode == Mode.onevsone)
                                  Text(
                                    '${gamesListData?.playerOne}'.tr(context),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: CompanionAppTheme.fontName,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 0.2,
                                      color: CompanionAppTheme.lightText,
                                    ),
                                  ),
                                if (gamesListData?.gamemode == Mode.koth)
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Text(
                                        '${gamesListData?.playerOne}'
                                            .tr(context),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily:
                                              CompanionAppTheme.fontName,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          letterSpacing: 0.2,
                                          color: CompanionAppTheme.lightText,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        '${getPlayerText(gamesListData?.playerTwo, "Player 2", context)}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily:
                                              CompanionAppTheme.fontName,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          letterSpacing: 0.2,
                                          color: CompanionAppTheme.lightText,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                    ],
                                  ),
                                if (gamesListData?.gamemode ==
                                    Mode.threevsthree)
                                  Text(
                                    '${gamesListData?.playerOne.tr(context) ?? ""} - '
                                    '${getPlayerText(gamesListData?.playerTwo, "Player 2", context)} - '
                                    '${getPlayerText(gamesListData?.playerFive, "Player 5", context)}',
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: TextStyle(
                                      fontFamily: CompanionAppTheme.fontName,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 0.2,
                                      color: CompanionAppTheme.lightText,
                                    ),
                                  ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "vs.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: CompanionAppTheme.fontName,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                    letterSpacing: 0.2,
                                    color: CompanionAppTheme.lightText,
                                  ),
                                ),
                                if (gamesListData?.gamemode == Mode.koth)
                                  SizedBox(
                                    height: 16,
                                  )
                                else
                                  SizedBox(
                                    height: 8,
                                  ),
                                if (gamesListData?.gamemode == Mode.twovstwo)
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${getPlayerText(gamesListData?.playerTwo, "Player 2", context)}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily:
                                              CompanionAppTheme.fontName,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          letterSpacing: 0.2,
                                          color: CompanionAppTheme.lightText,
                                        ),
                                      ),
                                      Text(
                                        ' - ' +
                                            '${getPlayerText(gamesListData?.playerFour, "Player 4", context)}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily:
                                              CompanionAppTheme.fontName,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          letterSpacing: 0.2,
                                          color: CompanionAppTheme.lightText,
                                        ),
                                      ),
                                    ],
                                  ),
                                if (gamesListData?.gamemode == Mode.onevsone)
                                  Text(
                                    '${getPlayerText(gamesListData?.playerTwo, "Player 2", context)}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: CompanionAppTheme.fontName,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 0.2,
                                      color: CompanionAppTheme.lightText,
                                    ),
                                  ),
                                if (gamesListData?.gamemode == Mode.koth)
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${getPlayerText(gamesListData?.playerThree, "Player 3", context)}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily:
                                              CompanionAppTheme.fontName,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          letterSpacing: 0.2,
                                          color: CompanionAppTheme.lightText,
                                        ),
                                      ),
                                    ],
                                  ),
                                if (gamesListData?.gamemode ==
                                    Mode.threevsthree)
                                  Text(
                                    '${getPlayerText(gamesListData?.playerThree, "Player 3", context)} - '
                                    '${getPlayerText(gamesListData?.playerFour, "Player 4", context)} - '
                                    '${getPlayerText(gamesListData?.playerSix, "Player 6", context)}',
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: TextStyle(
                                      fontFamily: CompanionAppTheme.fontName,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 0.2,
                                      color: CompanionAppTheme.lightText,
                                    ),
                                  ),
                              ],
                            ),
                          )),
                    ),
                  ),
                  Positioned(
                    top: 8,
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
                                color: getBorderColorOne(
                                    gamesListData?.winner ?? "", context),
                                borderRadius: BorderRadius.circular(27),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: ClipOval(
                              child: Image.asset(
                                gamesListData?.playerOneImagePath ?? '',
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
                  if (gamesListData?.gamemode == Mode.koth)
                    Positioned(
                      top: 8,
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
                                      gamesListData?.winner ?? "", context),
                                  borderRadius: BorderRadius.circular(27),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: ClipOval(
                                child: Image.asset(
                                  gamesListData?.playerThreeImagePath ?? '',
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
                  if (gamesListData?.gamemode == Mode.twovstwo ||
                      gamesListData?.gamemode == Mode.threevsthree)
                    Positioned(
                      top: 8,
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
                                      gamesListData?.winner ?? "", context),
                                  borderRadius: BorderRadius.circular(27),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: ClipOval(
                                child: Image.asset(
                                  gamesListData?.playerThreeImagePath ?? '',
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
                  if (gamesListData?.gamemode == Mode.twovstwo ||
                      gamesListData?.gamemode == Mode.threevsthree)
                    Positioned(
                      bottom: 0,
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
                                      gamesListData?.winner ?? "", context),
                                  borderRadius: BorderRadius.circular(27),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: ClipOval(
                                child: Image.asset(
                                  gamesListData?.playerFourImagePath ?? '',
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
                  if (gamesListData?.gamemode == Mode.threevsthree)
                    Positioned(
                      bottom: 0,
                      right: 120,
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
                                      gamesListData?.winner ?? "", context),
                                  borderRadius: BorderRadius.circular(27),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: ClipOval(
                                child: Image.asset(
                                  gamesListData?.playerSixImagePath ?? '',
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
                  if (gamesListData?.gamemode == Mode.threevsthree)
                    Positioned(
                      top: 8,
                      left: 120,
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
                                      gamesListData?.winner ?? "", context),
                                  borderRadius: BorderRadius.circular(27),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: ClipOval(
                                child: Image.asset(
                                  gamesListData?.playerFiveImagePath ?? '',
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
                    bottom: 0,
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
                                    gamesListData?.winner ?? "", context),
                                borderRadius: BorderRadius.circular(27),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: ClipOval(
                              child: Image.asset(
                                gamesListData?.playerTwoImagePath ?? '',
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
          ),
        );
      },
    );
  }
}
