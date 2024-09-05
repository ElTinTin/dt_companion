import 'package:dt_companion/dt_companion/extension/localization_extension.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../main.dart';
import '../companion_app_theme.dart';

class TournamentScreen extends StatefulWidget {
  const TournamentScreen({Key? key, this.animationController})
      : super(key: key);

  final AnimationController? animationController;
  @override
  _TournamentScreenState createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CompanionAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            getMainListViewUI(),
            getAppBarUI(),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      ),
    );
  }

  Widget getMainListViewUI() {
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
        return AnimatedBuilder(
          animation: widget.animationController!,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                      parent: widget.animationController!,
                      curve: Interval((1 / 1) * 1, 1.0,
                          curve: Curves.fastOutSlowIn))),
              child: new Transform(
                  transform: new Matrix4.translationValues(
                      0.0,
                      30 *
                          (1.0 -
                              Tween<double>(begin: 0.0, end: 1.0)
                                  .animate(CurvedAnimation(
                                      parent: widget.animationController!,
                                      curve: Interval((1 / 1) * 1, 1.0,
                                          curve: Curves.fastOutSlowIn)))
                                  .value),
                      0.0),
                  child: Center(
                    child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Lottie.asset(
                        'assets/dt_companion/under_construct.json',
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.5,
                      ),
                            /*Container(
                          height: MediaQuery.of(context).size.height,
                          child: _PageContent(
                            matchupsLenghtList: [6, 4, 2, 1],
                          ),
                        )*/),
                  )),
            );
          },
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
                                  'tournament'.tr(context),
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

const double _matchHeight = 100;
const double _matchWidth = 240;
const double _matchRightPadding = 20;
const double _minMargin = 32;

class _PageContent extends StatefulWidget {
  final List<int> matchupsLenghtList;
  const _PageContent({
    Key? key,
    required this.matchupsLenghtList,
  }) : super(key: key);

  @override
  State<_PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<_PageContent> {
  List<double> breakpoints = [];
  List<double> verticalMargins = [];
  late ScrollController controller;

  @override
  void initState() {
    controller = ScrollController();
    populateVerticalMargins();
    populateBreakPoints();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      calculateVerticalMargins();
      calculateBreakpoints();
    });
    controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  void populateVerticalMargins() {
    verticalMargins = widget.matchupsLenghtList.map((e) => 0.0).toList();
  }

  void populateBreakPoints() {
    breakpoints = widget.matchupsLenghtList.map((e) => 0.0).toList();
  }

  void calculateBreakpoints() {
    breakpoints = List.generate(widget.matchupsLenghtList.length, (index) {
      return index * (_matchWidth + _matchRightPadding);
    });

    setState(() {});
  }

  void calculateVerticalMargins() {
    verticalMargins = List.generate(widget.matchupsLenghtList.length, (index) {
      final matchLenght = widget.matchupsLenghtList[index];
      final heightOfmatchups = matchLenght * _matchHeight;
      final verticalMargin = (MediaQuery.of(context).size.height -
              heightOfmatchups) /
          (matchLenght +
              1); // if matchups lenght is 4 we have 5 spaces that need to have this height
      return verticalMargin;
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      scrollDirection: Axis.horizontal,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final margin = _getMargin(index: index);
              return Container(
                margin:
                    EdgeInsets.only(right: _matchRightPadding, bottom: margin),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.matchupsLenghtList[index],
                    (index) => Container(
                      margin: EdgeInsets.only(top: margin),
                      child: const MatchWidget(),
                    ),
                  ),
                ),
              );
            },
            childCount: widget.matchupsLenghtList.length,
          ),
        ),
      ],
    );
  }

  double _getMargin({required int index}) {
    final initialMargin = verticalMargins[index];
    double verticalMarginMultiplier = 1;
    if (index > 0) {
      final previousBreakpoint = breakpoints[index - 1]; //Example: 0
      final currentBreakPoint = breakpoints[index]; //Example: 200
      final currentScrollOffset = controller.offset; // Ex: 180
      if (currentScrollOffset >= currentBreakPoint) {
        verticalMarginMultiplier = 0;
      } else if (currentScrollOffset <= previousBreakpoint) {
        verticalMarginMultiplier = 1;
      } else {
        final gap = currentBreakPoint - previousBreakpoint; // Ex 200 - 0
        final currentExtend =
            currentScrollOffset - previousBreakpoint; // Ex: 180 - 0
        verticalMarginMultiplier =
            1 - currentExtend / gap; // Ex: 1 - 180 / 200 = 1 - 0.9 = 0.1
      }
    }
    final marginAndverticalMarginMultiplier =
        initialMargin * verticalMarginMultiplier; // Ex: 40 * 0.1 = 4

    double margin = initialMargin;

    //Set _minMargin value if marginAndverticalMarginMultiplier is less than _minMargin
    if (marginAndverticalMarginMultiplier >= _minMargin) {
      margin = marginAndverticalMarginMultiplier;
    } else if (initialMargin < _minMargin && initialMargin > 0) {
      margin = initialMargin;
    } else {
      margin = _minMargin;
    }
    return margin;
  }
}

class MatchWidget extends StatelessWidget {
  const MatchWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: _matchHeight,
        width: _matchWidth,
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
              topRight: Radius.circular(8.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: CompanionAppTheme.grey.withOpacity(0.2),
                offset: Offset(1.1, 1.1),
                blurRadius: 10.0),
          ],
        ),
        child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: Stack(
                        children: [
                          ClipOval(
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: CompanionAppTheme.dark_grey
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(27),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/dt_companion/artificer.png',
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Quentin D.',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: CompanionAppTheme.fontName,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: CompanionAppTheme.lightText,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '(0)',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: CompanionAppTheme.fontName,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: CompanionAppTheme.lightText,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: Stack(
                        children: [
                          ClipOval(
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: CompanionAppTheme.dark_grey
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(27),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/dt_companion/artificer.png',
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Antoine',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: CompanionAppTheme.fontName,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: CompanionAppTheme.lightText,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '(0)',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: CompanionAppTheme.fontName,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: CompanionAppTheme.lightText,
                      ),
                    ),
                  ],
                ),
              ],
            )));
  }
}
