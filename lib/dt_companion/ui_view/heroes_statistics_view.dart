import 'package:dt_companion/dt_companion/companion_app_theme.dart';
import 'package:dt_companion/dt_companion/extension/localization_extension.dart';
import 'package:dt_companion/dt_companion/models/heroes_data.dart';
import 'package:dt_companion/main.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:provider/provider.dart';

import 'overall_statistics_view.dart';

class HeroesStatisticsView extends StatefulWidget {
  const HeroesStatisticsView(
      {Key? key, this.animationController, this.animation, this.heroesListData})
      : super(key: key);
  final AnimationController? animationController;
  final Animation<double>? animation;
  final HeroesData? heroesListData;
  @override
  _HeroesStatisticsViewState createState() => _HeroesStatisticsViewState();
}

class _HeroesStatisticsViewState extends State<HeroesStatisticsView>
    with TickerProviderStateMixin {

  double getWinPercentage(int victories, int defeats) {
    return (victories / (victories + defeats) * 100);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                child: Stack(
                  children: [
                    Padding(padding: const EdgeInsets.only(
                        top: 24, left: 16, right: 16, bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(widget.heroesListData?.name ?? '',
                            style: TextStyle(
                              fontFamily: CompanionAppTheme
                                  .fontName,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              letterSpacing: -0.1,
                              color: CompanionAppTheme
                                  .lightText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 16, left: 16, right: 16, bottom: 16),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8, right: 8, top: 4),
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(height: 16,),

                                      SizedBox(height: 56,),
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
                                                    'victories'.tr(context),
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
                                                        '${(widget.heroesListData?.victories ?? 0 * widget.animation!.value).toInt()}',
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
                                                    'defeats'.tr(context),
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
                                                        '${(widget.heroesListData?.defeats ?? 0 * widget.animation!.value).toInt()}',
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
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 16, top: 64),
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
                                                '${(getWinPercentage(widget.heroesListData?.victories ?? 0, widget.heroesListData?.defeats ?? 0) * widget.animation!.value).toStringAsFixed(2)}',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily:
                                                  CompanionAppTheme.fontName,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  letterSpacing: 0.0,
                                                  color:
                                                  CompanionAppTheme.lightText,
                                                ),
                                              ),
                                              Text(
                                                '%',
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
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: CustomPaint(
                                          painter: CurvePainter(
                                              colors: [
                                                CompanionAppTheme.victoryGreen,
                                                CompanionAppTheme.victoryGreen
                                              ],
                                              angle:
                                              (getWinPercentage(widget.heroesListData?.victories ?? 0, widget.heroesListData?.defeats ?? 0) / 100 * 360) +
                                                  (360 - 140) *
                                                      (1.0 - widget.animation!.value)),
                                          child: SizedBox(
                                            width: 108,
                                            height: 108,
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
                      ],
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: SizedBox(
                        width: 84,
                        height: 84,
                        child: Stack(
                          children: [
                            ClipOval(
                              child: Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  color: CompanionAppTheme.dark_grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(27),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: ClipOval(
                                child: Image.asset(
                                  widget.heroesListData?.imagePath ?? '',
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ),
            ),
          ),
        );
      },
    );
  }
}
