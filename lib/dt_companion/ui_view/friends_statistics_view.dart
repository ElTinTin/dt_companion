import 'package:dt_companion/dt_companion/companion_app_theme.dart';
import 'package:dt_companion/dt_companion/extension/localization_extension.dart';
import 'package:dt_companion/dt_companion/models/friends_data.dart';
import 'package:dt_companion/dt_companion/models/heroes_data.dart';
import 'package:dt_companion/main.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:provider/provider.dart';

import '../service.dart';
import 'overall_statistics_view.dart';

class FriendsStatisticsView extends StatefulWidget {
  const FriendsStatisticsView(
      {Key? key, this.animationController, this.animation, this.friendsData})
      : super(key: key);
  final AnimationController? animationController;
  final Animation<double>? animation;
  final FriendsData? friendsData;
  @override
  _FriendsStatisticsViewState createState() => _FriendsStatisticsViewState();
}

class _FriendsStatisticsViewState extends State<FriendsStatisticsView>
    with TickerProviderStateMixin {

  double getWinPercentage(int victories, int defeats) {
    return (victories / (victories + defeats) * 100);
  }

  bool _isExpanded = false;

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
        service.deleteFriendsData(widget.friendsData?.name ?? "");
      },
      style: ButtonStyle(
        backgroundColor:
        MaterialStateProperty.all<Color>(CompanionAppTheme.darkerText),
      ),
    );

    AlertDialog alert = AlertDialog(
      title: Text(
        "alert_games_title".tr(context),
        style: TextStyle(color: CompanionAppTheme.dark_grey),
      ),
      content: Text(
        "alert_friends_delete_desc".tr(context),
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

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);

    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.animation!,
          child: Transform(
            transform: Matrix4.translationValues(
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
                      topRight: Radius.circular(_isExpanded ? 38.0 : 8.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: CompanionAppTheme.grey.withOpacity(0.2),
                        offset: Offset(1.1, 1.1),
                        blurRadius: 10.0),
                  ],
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.friendsData?.name ?? '',
                              style: TextStyle(
                                fontFamily: CompanionAppTheme.fontName,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                letterSpacing: -0.1,
                                color: CompanionAppTheme.lightText,
                              ),
                            ),
                            Icon(
                              _isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: CompanionAppTheme.lightText,
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: _isExpanded ? null : 0,
                      child: _isExpanded
                          ? Column(
                        children: [
                          _buildStatisticsRow(context),
                          Divider(
                            color: CompanionAppTheme.lightText,
                            thickness: 1,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 16, bottom: 8),
                                child: InkWell(
                                  onTap: () =>
                                  {
                                    showAlertDialog(context, userService)
                                  },
                                  child: Icon(
                                    Icons.delete_forever,
                                    color: CompanionAppTheme.lightText,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
      child: Column(
        children: [
          _buildStatisticsItem(
              context,
              'assets/dt_companion/fight.png',
              'victories',
              widget.friendsData?.victoriesAgainst ?? 0,
              CompanionAppTheme.victoryGreen,
              'defeats',
              widget.friendsData?.defeatsAgainst ?? 0,
              CompanionAppTheme.defeatRed
          ),
          _buildStatisticsItem(
              context,
              'assets/dt_companion/handshake.png',
              'victories',
              widget.friendsData?.victoriesWith ?? 0,
              CompanionAppTheme.victoryGreen,
              'defeats',
              widget.friendsData?.defeatsWith ?? 0,
              CompanionAppTheme.defeatRed
          ),
          // Ajoutez plus de statistiques ici si nécessaire
        ],
      ),
    );
  }

  Widget _buildStatisticsItem(BuildContext context, String imagePath,
      String victoryLabelKey, int victoryValue, Color victoryColor,
      String defeatLabelKey, int defeatValue, Color defeatColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 44,
            height: 44,
            child: FittedBox(
              child: Image.asset(imagePath),
              fit: BoxFit.fitHeight,
            ),
          ),
          SizedBox(width: 16,),
          Container(
            height: 48,
            width: 2,
            decoration: BoxDecoration(
              color: victoryColor.withOpacity(0.75),
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 2),
                  child: Text(
                    victoryLabelKey.tr(context),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: CompanionAppTheme.fontName,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      letterSpacing: -0.1,
                      color: victoryColor.withOpacity(0.5),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 3),
                  child: Text(
                    '$victoryValue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: CompanionAppTheme.fontName,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: CompanionAppTheme.lightText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16,),
          Container(
            height: 48,
            width: 2,
            decoration: BoxDecoration(
              color: defeatColor.withOpacity(0.75),
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 2),
                  child: Text(
                    defeatLabelKey.tr(context),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: CompanionAppTheme.fontName,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      letterSpacing: -0.1,
                      color: defeatColor.withOpacity(0.75),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 3),
                  child: Text(
                    '$defeatValue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: CompanionAppTheme.fontName,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: CompanionAppTheme.lightText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
