import 'package:dt_companion/dt_companion/companion/dta_game_detail_view.dart';
import 'package:dt_companion/dt_companion/companion_app_theme.dart';
import 'package:dt_companion/dt_companion/models/dta_data.dart';
import 'package:dt_companion/dt_companion/service.dart';
import 'package:dt_companion/dt_companion/ui_view/dta_game_view.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'dta_add_view.dart';


class DTAListView extends StatefulWidget {
  const DTAListView({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  _DTAListViewState createState() => _DTAListViewState();
}

class _DTAListViewState extends State<DTAListView>
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
    await FirebaseAnalytics.instance
        .logScreenView(screenName: 'DTAView');
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
            getDTAList(userService.dtaListData),
            getAppBarUI(),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      ),
    );
  }

  Widget getDTAList(List<DTAData> dtaListData) {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.only(
        top: AppBar().preferredSize.height +
            MediaQuery.of(context).padding.top +
            80,
        bottom: 62 + MediaQuery.of(context).padding.bottom,
      ),
      itemCount: dtaListData.length == 0 ? 1 : dtaListData.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        final Animation<double> animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
                parent: widget.animationController!,
                curve: Interval((1 / dtaListData.length) * index, 1.0,
                    curve: Curves.fastOutSlowIn)));
        widget.animationController?.forward();

        if (dtaListData.length == 0) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Lottie.asset(
                'assets/dt_companion/empty_lottie.json',
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.5,
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(
                top: 0, bottom: 0, right: 12, left: 12),
            child: InkWell(
              onTap: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DTAGameDetailView(animationController: widget.animationController!, dtaListData: dtaListData[index],)))
              },
              child: DTAGameView(
                animation: animation,
                animationController: widget.animationController!,
                dtaListData: dtaListData[index],
              ),
            )
          );
        }
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
                    color: CompanionAppTheme.dark_grey.withOpacity(topBarOpacity),
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
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 16, right: 8),
                              child: IconButton(
                                onPressed: () => {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => DTAAddView(animationController: widget.animationController!,)))
                                },
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
