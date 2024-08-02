import 'package:dt_companion/dt_companion/companion_app_theme.dart';
import 'package:dt_companion/dt_companion/extension/localization_extension.dart';
import 'package:dt_companion/dt_companion/models/heroes_data.dart';
import 'package:dt_companion/dt_companion/service.dart';
import 'package:dt_companion/main.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class HeroesListView extends StatefulWidget {
  const HeroesListView(
      {Key? key, this.mainScreenAnimationController, this.mainScreenAnimation})
      : super(key: key);

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;

  @override
  _HeroesListViewState createState() => _HeroesListViewState();
}

class _HeroesListViewState extends State<HeroesListView>
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

  Widget getHeroesList(List<HeroesData> heroesListData) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 0, bottom: 0, right: 16, left: 16),
      itemCount: heroesListData.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
            .animate(CurvedAnimation(
                parent: animationController!,
                curve: Interval((1 / heroesListData.length) * index, 1.0,
                    curve: Curves.fastOutSlowIn)));
        animationController?.forward();

        return HeroView(
          heroesListData: heroesListData[index],
          animation: animation,
          animationController: animationController!,
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
        final count = userService.heroesListData.isEmpty ? 1 : 10;
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
                    if (!userService.heroesListData.isEmpty)
                      getHeroesList(userService.heroesListData.take(10).toList())
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

class HeroView extends StatelessWidget {
  const HeroView(
      {Key? key, this.heroesListData, this.animationController, this.animation})
      : super(key: key);

  final HeroesData? heroesListData;
  final AnimationController? animationController;
  final Animation<double>? animation;

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
              width: 130,
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 32, left: 8, right: 8, bottom: 16),
                    child: Container(
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
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(54.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 54, left: 16, right: 16, bottom: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              heroesListData!.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: CompanionAppTheme.fontName,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.2,
                                color: CompanionAppTheme.lightText,
                              ),
                            ),
                            Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '${heroesListData?.victories} W - ${heroesListData?.draws} D - ${heroesListData?.defeats} L',
                                  style: TextStyle(
                                    fontFamily: CompanionAppTheme.fontName,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.2,
                                    color: CompanionAppTheme.lightText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 16,
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
                                heroesListData?.imagePath ?? '',
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

class EmptyStatsView extends StatelessWidget {
  const EmptyStatsView({Key? key, this.animationController, this.animation})
      : super(key: key);

  final AnimationController? animationController;
  final Animation<double>? animation;

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
              width: 130,
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 32, left: 8, right: 8, bottom: 16),
                    child: Container(
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
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(54.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 54, left: 16, right: 16, bottom: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'no_stats'.tr(context),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: CompanionAppTheme.fontName,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.2,
                                color: CompanionAppTheme.lightText,
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
