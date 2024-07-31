import 'package:dt_companion/dt_companion/companion_app_theme.dart';
import 'package:dt_companion/dt_companion/extension/localization_extension.dart';
import 'package:dt_companion/dt_companion/extension/string_extension.dart';
import 'package:dt_companion/dt_companion/models/dta_cards.dart';
import 'package:dt_companion/dt_companion/models/heroes_list_data.dart';
import 'package:dt_companion/dt_companion/service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../models/dta_list_data.dart';

class DTAGameDetailView extends StatefulWidget {
  const DTAGameDetailView(
      {Key? key, this.animationController, required this.dtaListData})
      : super(key: key);

  final AnimationController? animationController;
  final DTAListData dtaListData;

  @override
  _DTAGameDetailViewState createState() => _DTAGameDetailViewState();
}

class _DTAGameDetailViewState extends State<DTAGameDetailView>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;
  double topBarOpacity = 0.0;
  final ScrollController scrollController = ScrollController();

  TextEditingController _scenarioNumber = TextEditingController(text: '0');
  TextEditingController _remainingSalve = TextEditingController(text: '0');
  TextEditingController _unspentGold = TextEditingController(text: '0');
  TextEditingController _unclaimedBossLoot = TextEditingController(text: '0');
  bool _exploredAllTiles = false;
  bool _won = false;
  cardType _type = cardType.common;
  String _searchQuery = "";
  TextEditingController _searchController = TextEditingController();

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

  String getImagePath(String character) {
    return "assets/dt_companion/${CharacterExtension.fromDisplayName(character)?.nameWithoutEnum}.png";
  }

  @override
  void dispose() {
    super.dispose();
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
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 32, right: 16, top: 0, bottom: 8),
                                child: InkWell(
                                  onTap: () => {Navigator.pop(context)},
                                  child: SizedBox(
                                    width: 20,
                                    height: 22,
                                    child: Icon(
                                      Icons.arrow_back_ios,
                                      color: HexColor("#658595"),
                                      size: 22,
                                    ),
                                  ),
                                )),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 8, right: 8, top: 0, bottom: 8),
                                child: Text(
                                  'dta_detail_title'.tr(context),
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
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 16, right: 16, top: 24, bottom: 8),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text(
                                        widget.dtaListData.teamName,
                                        style: TextStyle(
                                          fontFamily:
                                              CompanionAppTheme.fontName,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          color: CompanionAppTheme.lightText,
                                        ),
                                      ),
                                    ),
                                    Spacer(),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          right: 32, top: 16, bottom: 16),
                                      child: Text(
                                        '${widget.dtaListData.campaignScore}',
                                        style: TextStyle(
                                          fontFamily:
                                              CompanionAppTheme.fontName,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          color: CompanionAppTheme.lightText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: CompanionAppTheme.lightText,
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          right: 6, top: 4, bottom: 24),
                                      child: Text(
                                        widget.dtaListData.difficulty == 0
                                            ? 'dta_difficulty_normal'.tr(context)
                                            : 'dta_difficulty_veteran'.tr(context),
                                        style: TextStyle(
                                          fontFamily:
                                              CompanionAppTheme.fontName,
                                          fontWeight: FontWeight.w100,
                                          fontSize: 14,
                                          color: CompanionAppTheme.lightText,
                                        ),
                                      ),
                                    ),
                                    Spacer(),
                                    if (widget.dtaListData.legacyMode)
                                      Padding(
                                          padding: EdgeInsets.only(
                                              right: 8, top: 4, bottom: 24),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 4.0, horizontal: 16.0),
                                            decoration: BoxDecoration(
                                              color: CompanionAppTheme.lightText,
                                              borderRadius:
                                              BorderRadius.circular(20.0),
                                            ),
                                            child: Text(
                                              'dta_add_legacy'.tr(context),
                                              style: TextStyle(
                                                fontFamily:
                                                CompanionAppTheme.fontName,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color:
                                                CompanionAppTheme.darkerText,
                                              ),
                                            ),
                                          )),
                                    if (widget.dtaListData.mythic)
                                      Padding(
                                          padding: EdgeInsets.only(
                                              right: 8, top: 4, bottom: 24),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 4.0, horizontal: 16.0),
                                            decoration: BoxDecoration(
                                              color: CompanionAppTheme.lightText,
                                              borderRadius:
                                              BorderRadius.circular(20.0),
                                            ),
                                            child: Text(
                                              'dta_add_mythic'.tr(context),
                                              style: TextStyle(
                                                fontFamily:
                                                CompanionAppTheme.fontName,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color:
                                                CompanionAppTheme.darkerText,
                                              ),
                                            ),
                                          )),
                                  ],
                                ),
                                for (var player in widget.dtaListData.players)
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 54,
                                          height: 54,
                                          child: Stack(
                                            children: [
                                              ClipOval(
                                                child: Container(
                                                  width: 54,
                                                  height: 54,
                                                  decoration: BoxDecoration(
                                                    color: CompanionAppTheme
                                                        .dark_grey,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            27),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(6.0),
                                                child: ClipOval(
                                                  child: Image.asset(
                                                    getImagePath(
                                                        player.character),
                                                    width: 42,
                                                    height: 42,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 16,
                                        ),
                                        Text(
                                          player.name,
                                          style: TextStyle(
                                            fontFamily:
                                                CompanionAppTheme.fontName,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20,
                                            color: CompanionAppTheme.lightText,
                                          ),
                                        ),
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
                                                          playerCardsBottomSheet(
                                                              userService,
                                                              player),
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
                                                  width: 20,
                                                  height: 40,
                                                  child: FittedBox(
                                                    child: Image.asset(
                                                        'assets/dt_companion/card_games.png'),
                                                    fit: BoxFit.fitHeight,
                                                  ),
                                                ),
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 16,
                                      bottom: 16,
                                      left: 16,
                                      right: 16),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor:
                                        CompanionAppTheme.darkerText,
                                        backgroundColor: widget
                                            .dtaListData.inprogress
                                            ? CompanionAppTheme.lightText
                                            : Colors.grey,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                        elevation: 15.0,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 16),
                                        textStyle: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: CompanionAppTheme
                                                .darkerText)),
                                    child: Text('dta_detail_new_scenario'.tr(context)),
                                    onPressed: () {
                                      if (widget.dtaListData.inprogress) {
                                        showModalBottomSheet<void>(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (BuildContext context) {
                                            return FractionallySizedBox(
                                              heightFactor: 0.8,
                                              child:
                                              createScenarioBottomSheet(
                                                  userService),
                                            );
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 16,
                                      bottom: 16,
                                      left: 16,
                                      right: 16),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor:
                                        CompanionAppTheme.darkerText,
                                        backgroundColor:
                                        CompanionAppTheme.defeatRed,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                        elevation: 15.0,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 16),
                                        textStyle: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: CompanionAppTheme
                                                .darkerText)),
                                    child: Text('dta_detail_end_campaign'.tr(context)),
                                    onPressed: () {
                                      widget.dtaListData.inprogress = false;
                                      userService.updateDtaData(
                                          widget.dtaListData);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                scenarioCollapseView(userService),
                              ],
                            ),
                          ))
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

  Widget scenarioCollapseView(UserService userService) {
    return ExpansionPanelList(
      dividerColor: CompanionAppTheme.background,
      expandedHeaderPadding: EdgeInsets.all(4),
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          userService.expandScoreboard(widget.dtaListData, index);
        });
      },
      children: widget.dtaListData.scoreboards
          .map<ExpansionPanel>((Scoreboard scoreboard) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(
                'Scenario ${scoreboard.scenarioNumber}',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CompanionAppTheme.darkerText),
              ),
            );
          },
          body: Padding(
            padding: EdgeInsets.all(8),
            child: Container(
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 16,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'dta_detail_remaining_salves'.tr(context),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: CompanionAppTheme.darkerText),
                          ),
                          Text(
                              'dta_detail_remaining_salves_desc'.tr(context),
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w100,
                                  color: CompanionAppTheme.darkerText)),
                        ],
                      ),
                      Spacer(),
                      Text('${scoreboard.remainingSalve}',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: CompanionAppTheme.darkerText)),
                      SizedBox(
                        width: 16,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Divider(
                    color: CompanionAppTheme.background,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 16,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'dta_detail_unspent_gold'.tr(context),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: CompanionAppTheme.darkerText),
                          ),
                          Text(
                              'dta_detail_unspent_gold_desc'.tr(context),
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w100,
                                  color: CompanionAppTheme.darkerText)),
                        ],
                      ),
                      Spacer(),
                      Text('${scoreboard.unspentGold}',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: CompanionAppTheme.darkerText)),
                      SizedBox(
                        width: 16,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Divider(
                    color: CompanionAppTheme.background,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 16,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'dta_detail_unclaimed_boss'.tr(context),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: CompanionAppTheme.darkerText),
                          ),
                          Text(
                              'dta_detail_unclaimed_boss_desc'.tr(context),
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w100,
                                  color: CompanionAppTheme.darkerText)),
                        ],
                      ),
                      Spacer(),
                      Text('${scoreboard.unclaimedBossLoot}',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: CompanionAppTheme.darkerText)),
                      SizedBox(
                        width: 16,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Divider(
                    color: CompanionAppTheme.background,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 16,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'dta_detail_explored_all'.tr(context),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: CompanionAppTheme.darkerText),
                          ),
                          Text(
                              'dta_detail_explored_all_desc'.tr(context),
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w100,
                                  color: CompanionAppTheme.darkerText)),
                        ],
                      ),
                      Spacer(),
                      Text('${scoreboard.exploredAll ? 5 : 0}',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: CompanionAppTheme.darkerText)),
                      SizedBox(
                        width: 16,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Divider(
                    color: CompanionAppTheme.background,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 16,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'dta_detail_scenario_score'.tr(context),
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: CompanionAppTheme.darkerText),
                          ),
                          Text('dta_detail_scenario_score_desc'.tr(context),
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w100,
                                  color: CompanionAppTheme.darkerText)),
                        ],
                      ),
                      Spacer(),
                      Text('${widget.dtaListData.difficulty == 0 ? 20 : 30}',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: CompanionAppTheme.darkerText)),
                      SizedBox(
                        width: 16,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Divider(
                    color: CompanionAppTheme.background,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 16,
                      ),
                      Text(
                        'dta_detail_scenario_won'.tr(context),
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: CompanionAppTheme.darkerText),
                      ),
                      Spacer(),
                      if (scoreboard.won) ...[
                        Icon(
                          Icons.check,
                          color: CompanionAppTheme.victoryGreen,
                          size: 16,
                        ),
                      ] else ...[
                        Icon(
                          Icons.close,
                          color: CompanionAppTheme.defeatRed,
                          size: 16,
                        ),
                      ],
                      SizedBox(
                        width: 16,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Divider(
                    color: CompanionAppTheme.background,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 16,
                      ),
                      Text('dta_detail_total_score'.tr(context),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: CompanionAppTheme.darkerText)),
                      Spacer(),
                      Text('${scoreboard.totalScore}',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: CompanionAppTheme.darkerText)),
                      SizedBox(
                        width: 16,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
          ),
          isExpanded: scoreboard.isExpanded,
          canTapOnHeader: true,
          backgroundColor: CompanionAppTheme.lightText,
        );
      }).toList(),
    );
  }

  Widget createScenarioBottomSheet(UserService userService) {
    int getTotalScore() {
      if (_won) {
        return int.parse(_remainingSalve.text) +
            int.parse(_unspentGold.text) +
            int.parse(_unclaimedBossLoot.text) +
            (_exploredAllTiles ? 5 : 0) +
            (widget.dtaListData.difficulty == 0 ? 20 : 30);
      } else {
        return -10;
      }
    }

    return StatefulBuilder(builder:
        (BuildContext context, StateSetter setState /*You can rename this!*/) {
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
                                'dta_detail_new_scenario'.tr(context),
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: CompanionAppTheme.lightText),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 16,
                            ),
                            Text(
                              'dta_detail_scenario_number'.tr(context),
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: CompanionAppTheme.lightText),
                            ),
                            Spacer(),
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: TextFormField(
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                controller: _scenarioNumber,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  // for below version 2 use this
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                  // for version 2 and greater youcan also use this
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: CompanionAppTheme.lightText,
                                  hintText: '',
                                  contentPadding: const EdgeInsets.only(
                                      left: 8.0, bottom: 4.0, top: 4.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: CompanionAppTheme.lightText),
                                    borderRadius: BorderRadius.circular(12.5),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                    BorderSide(color: CompanionAppTheme.lightText),
                                    borderRadius: BorderRadius.circular(12.5),
                                  ),
                                ),
                                cursorColor: CompanionAppTheme.darkerText,
                              ),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Divider(
                          color: CompanionAppTheme.lightText,
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 16,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'dta_detail_remaining_salves'.tr(context),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: CompanionAppTheme.lightText),
                                ),
                                Text('dta_detail_remaining_salves_desc'.tr(context),
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w100,
                                        color: CompanionAppTheme.lightText)),
                              ],
                            ),
                            Spacer(),
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: TextFormField(
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                controller: _remainingSalve,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  // for below version 2 use this
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                  // for version 2 and greater youcan also use this
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: CompanionAppTheme.lightText,
                                  hintText: '',
                                  contentPadding: const EdgeInsets.only(
                                      left: 8.0, bottom: 4.0, top: 4.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: CompanionAppTheme.lightText),
                                    borderRadius: BorderRadius.circular(12.5),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                    BorderSide(color: CompanionAppTheme.lightText),
                                    borderRadius: BorderRadius.circular(12.5),
                                  ),
                                ),
                                cursorColor: CompanionAppTheme.darkerText,
                              ),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Divider(
                          color: CompanionAppTheme.lightText,
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 16,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'dta_detail_unspent_gold'.tr(context),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: CompanionAppTheme.lightText),
                                ),
                                Text('dta_detail_unspent_gold_desc'.tr(context),
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w100,
                                        color: CompanionAppTheme.lightText)),
                              ],
                            ),
                            Spacer(),
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: TextFormField(
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                controller: _unspentGold,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  // for below version 2 use this
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                  // for version 2 and greater youcan also use this
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: CompanionAppTheme.lightText,
                                  hintText: '',
                                  contentPadding: const EdgeInsets.only(
                                      left: 8.0, bottom: 4.0, top: 4.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: CompanionAppTheme.lightText),
                                    borderRadius: BorderRadius.circular(12.5),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                    BorderSide(color: CompanionAppTheme.lightText),
                                    borderRadius: BorderRadius.circular(12.5),
                                  ),
                                ),
                                cursorColor: CompanionAppTheme.darkerText,
                              ),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Divider(
                          color: CompanionAppTheme.lightText,
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 16,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'dta_detail_unclaimed_boss'.tr(context),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: CompanionAppTheme.lightText),
                                ),
                                Text('dta_detail_unclaimed_boss_desc'.tr(context),
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w100,
                                        color: CompanionAppTheme.lightText)),
                              ],
                            ),
                            Spacer(),
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: TextFormField(
                                onTapOutside: (event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                controller: _unclaimedBossLoot,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  // for below version 2 use this
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                  // for version 2 and greater youcan also use this
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: CompanionAppTheme.lightText,
                                  hintText: '',
                                  contentPadding: const EdgeInsets.only(
                                      left: 8.0, bottom: 4.0, top: 4.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: CompanionAppTheme.lightText),
                                    borderRadius: BorderRadius.circular(12.5),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                    BorderSide(color: CompanionAppTheme.lightText),
                                    borderRadius: BorderRadius.circular(12.5),
                                  ),
                                ),
                                cursorColor: CompanionAppTheme.darkerText,
                              ),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Divider(
                          color: CompanionAppTheme.lightText,
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 16,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'dta_detail_explored_all'.tr(context),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: CompanionAppTheme.lightText),
                                ),
                                Text('dta_detail_explored_all_desc'.tr(context),
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w100,
                                        color: CompanionAppTheme.lightText)),
                              ],
                            ),
                            Spacer(),
                            FlutterSwitch(
                              value: _exploredAllTiles,
                              activeColor: CompanionAppTheme.lightText,
                              toggleColor: CompanionAppTheme.dark_grey,
                              onToggle: (val) {
                                setState(() {
                                  _exploredAllTiles = val;
                                });
                              },
                            ),
                            SizedBox(
                              width: 16,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Divider(
                          color: CompanionAppTheme.lightText,
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 16,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'dta_detail_scenario_score'.tr(context),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: CompanionAppTheme.lightText),
                                ),
                                Text('dta_detail_scenario_score_desc'.tr(context),
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w100,
                                        color: CompanionAppTheme.lightText)),
                              ],
                            ),
                            Spacer(),
                            Text(
                              '${widget.dtaListData.difficulty == 0 ? 20 : 30}',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: CompanionAppTheme.lightText),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Divider(
                          color: CompanionAppTheme.lightText,
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 16,
                            ),
                            Text(
                              'dta_detail_scenario_won'.tr(context),
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: CompanionAppTheme.lightText),
                            ),
                            Spacer(),
                            FlutterSwitch(
                              value: _won,
                              activeColor: CompanionAppTheme.lightText,
                              toggleColor: CompanionAppTheme.dark_grey,
                              onToggle: (val) {
                                setState(() {
                                  _won = val;
                                });
                              },
                            ),
                            SizedBox(
                              width: 16,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Divider(
                          color: CompanionAppTheme.lightText,
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 16,
                            ),
                            Text('dta_detail_total_score'.tr(context),
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: CompanionAppTheme.lightText)),
                            Spacer(),
                            Text('${getTotalScore()}',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: CompanionAppTheme.lightText)),
                            SizedBox(
                              width: 16,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                foregroundColor: CompanionAppTheme.darkerText,
                                backgroundColor: CompanionAppTheme.lightText,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 15.0,
                                padding:
                                EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                                textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: CompanionAppTheme.darkerText)),
                            child: Text('match_save'.tr(context)),
                            onPressed: () {
                              widget.dtaListData.scoreboards.add(Scoreboard(
                                totalScore: getTotalScore(),
                                remainingSalve: int.parse(_remainingSalve.text),
                                scenarioNumber: int.parse(_scenarioNumber.text),
                                unspentGold: int.parse(_unspentGold.text),
                                unclaimedBossLoot: int.parse(_unclaimedBossLoot.text),
                                exploredAll: _exploredAllTiles,
                                won: _won,
                              ));
                              widget.dtaListData.campaignScore += getTotalScore();
                              userService.updateDtaData(widget.dtaListData);
                              _remainingSalve.text = "0";
                              _scenarioNumber.text = "0";
                              _unspentGold.text = "0";
                              _unclaimedBossLoot.text = "0";
                              _exploredAllTiles = false;
                              _won = false;
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        SizedBox(
                          height: 88,
                        ),
                      ],
                    ),
                  )),
            ),
          )
      );
    });
  }

  Widget playerCardsBottomSheet(UserService userService, Player player) {
    List<String> getRarityCards() {
      List<String> cards;
      switch (_type) {
        case cardType.common:
          cards = widget.dtaListData.commonCards;
          break;
        case cardType.rare:
          cards = widget.dtaListData.rareCards;
          break;
        case cardType.epic:
          cards = widget.dtaListData.epicCards;
          break;
        case cardType.legendary:
          cards = widget.dtaListData.legendaryCards;
          break;
      }
      return cards
          .where(
              (card) => card.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    List<String> getPlayerCards() {
      var cards = <String>[];
      cards.addAll(player.commonCards);
      cards.addAll(player.rareCards);
      cards.addAll(player.epicCards);
      cards.addAll(player.legendaryCards);
      return cards
          .where(
              (card) => card.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

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
                              player.name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: CompanionAppTheme.lightText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'dta_detail_search'.tr(context),
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = "";
                                });
                              },
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          onSubmitted: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                            FocusScope.of(context)
                                .unfocus(); // This will hide the keyboard
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Text(
                              'dta_detail_deck'.tr(context),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: CompanionAppTheme.lightText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: SizedBox(
                          height: 110,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: getPlayerCards().map((card) {
                              return GestureDetector(
                                onTap: () {
                                  if (widget.dtaListData.inprogress) {
                                    setState(() {
                                      userService.removeCardFromPlayer(
                                          player, card, widget.dtaListData);
                                    });
                                  }
                                },
                                child: Container(
                                  width: 120,
                                  margin: EdgeInsets.symmetric(horizontal: 8),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: CompanionAppTheme.lightText,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        card,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: CompanionAppTheme.darkerText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Text(
                              'dta_detail_loot_cards'.tr(context),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: CompanionAppTheme.lightText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        children: cardType.values.map((type) {
                          return ChoiceChip(
                            label: Text(
                                type.toString().split('.').last.tr(context)),
                            selected: _type == type,
                            onSelected: (selected) {
                              setState(() {
                                _type = type;
                              });
                            },
                            selectedColor: CompanionAppTheme.lightText,
                            backgroundColor: CompanionAppTheme.dark_grey,
                            labelStyle: TextStyle(
                              color: _type == type
                                  ? CompanionAppTheme.darkerText
                                  : CompanionAppTheme.lightText,
                            ),
                          );
                        }).toList(),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: SizedBox(
                          height: 110,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: getRarityCards().map((card) {
                              return GestureDetector(
                                onTap: () {
                                  if (widget.dtaListData.inprogress) {
                                    setState(() {
                                      userService.addCardToPlayer(player, card,
                                          widget.dtaListData, _type);
                                    });
                                  }
                                },
                                child: Container(
                                  width: 120,
                                  margin: EdgeInsets.symmetric(horizontal: 8),
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: CompanionAppTheme.dark_grey,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        card,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: CompanionAppTheme.lightText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
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
}
