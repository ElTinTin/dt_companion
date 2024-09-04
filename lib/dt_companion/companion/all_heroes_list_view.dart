import 'package:dt_companion/dt_companion/companion_app_theme.dart';
import 'package:dt_companion/dt_companion/extension/localization_extension.dart';
import 'package:dt_companion/dt_companion/models/heroes_data.dart';
import 'package:dt_companion/dt_companion/service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../ui_view/heroes_statistics_view.dart';

class AllHeroesListView extends StatefulWidget {
  const AllHeroesListView({Key? key, this.animationController})
      : super(key: key);

  final AnimationController? animationController;
  @override
  _AllHeroesListScreenState createState() => _AllHeroesListScreenState();
}

class _AllHeroesListScreenState extends State<AllHeroesListView>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;

  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

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

  Future<void> _analytics() async {
    // Analytics
    await FirebaseAnalytics.instance.logScreenView(screenName: 'FriendsView');
  }

  void showAlertDialog(BuildContext context, UserService service) {
    Character? _newCharacter;

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
        var heroesData = HeroesData(
            name: _newCharacter!.displayName,
            imagePath: "assets/dt_companion/${_newCharacter!.name}.png",
            victories: 0,
            defeats: 0,
            draws: 0);
        Navigator.of(context).pop();
        service.insertHeroesData(heroesData);
      },
      style: ButtonStyle(
        backgroundColor:
        MaterialStateProperty.all<Color>(CompanionAppTheme.darkerText),
      ),
    );

    AlertDialog alert = AlertDialog(
      title: Text(
        "alert_heroes_add_title".tr(context),
        style: TextStyle(color: CompanionAppTheme.dark_grey),
      ),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return DropdownButton<Character>(
            menuMaxHeight: 300,
            hint: Text(
              'character_select'.tr(context),
              style: TextStyle(
                fontFamily: CompanionAppTheme.fontName,
                fontWeight: FontWeight.normal,
                fontSize: 14,
                letterSpacing: 0.2,
                color: CompanionAppTheme.dark_grey,
              ),
            ),
            value: _newCharacter,
            onChanged: (Character? newValue) {
              setState(() {
                _newCharacter = newValue;
              });
            },
            items: Character.values.where((Character character) {
              return !service.heroesListData
                  .any((hero) => hero.name == character.displayName);
            }).map((Character character) {
              return DropdownMenuItem<Character>(
                value: character,
                child: Text(
                  character.displayName,
                  style: TextStyle(
                    fontFamily: CompanionAppTheme.fontName,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.2,
                    color: CompanionAppTheme.dark_grey,
                  ),
                ),
              );
            }).toList(),
          );
        },
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

    return Container(
      color: CompanionAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            getHeroesList(userService.heroesListData),
            getAppBarUI(userService),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      ),
    );
  }

  Widget getHeroesList(List<HeroesData> heroesListData) {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.only(
        top: AppBar().preferredSize.height +
            MediaQuery.of(context).padding.top +
            80,
        bottom: 62 + MediaQuery.of(context).padding.bottom,
      ),
      itemCount: heroesListData.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
            .animate(CurvedAnimation(
                parent: widget.animationController!,
                curve: Interval((1 / heroesListData.length) * index, 1.0,
                    curve: Curves.fastOutSlowIn)));
        widget.animationController?.forward();

        return Padding(
          padding:
              const EdgeInsets.only(top: 0, bottom: 0, right: 12, left: 12),
          child: HeroesStatisticsView(
            animation: animation,
            animationController: widget.animationController!,
            heroesListData: heroesListData[index],
          ),
        );
      },
    );
  }

  Widget getAppBarUI(UserService userService) {
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
                                    left: 32, right: 32, top: 0, bottom: 8),
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
                                  'heroes'.tr(context),
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
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 0, right: 8),
                              child: IconButton(
                                onPressed: () =>
                                    {showAlertDialog(context, userService)},
                                icon: Icon(
                                  Icons.add_circle,
                                  color: CompanionAppTheme.lightText,
                                  size: 33,
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
