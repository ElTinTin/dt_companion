import 'package:dt_companion/dt_companion/companion/all_games_list_view.dart';
import 'package:dt_companion/dt_companion/companion/all_heroes_list_view.dart';
import 'package:dt_companion/dt_companion/companion/games_list_view.dart';
import 'package:dt_companion/dt_companion/extension/localization_extension.dart';
import 'package:dt_companion/dt_companion/ui_view/overall_statistics_view.dart';
import 'package:dt_companion/dt_companion/ui_view/title_view.dart';
import 'package:dt_companion/dt_companion/companion_app_theme.dart';
import 'package:dt_companion/dt_companion/companion/heroes_list_view.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class CompanionScreen extends StatefulWidget {
  const CompanionScreen({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  _CompanionScreenState createState() => _CompanionScreenState();
}

class _CompanionScreenState extends State<CompanionScreen>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  final InAppReview inAppReview = InAppReview.instance;

  int inAppReviewStatus = 0;
  int inAppReviewDate = 0;

  final AdSize adSize = AdSize.banner;
  BannerAd? _bannerAdOne;
  final String adOneUnitId = Platform.isAndroid
  // Use this ad unit on Android...
      ? 'ca-app-pub-9004659002329377/1360544789'
  // ... or this one on iOS.
      : 'ca-app-pub-9004659002329377/4587960461';

  @override
  void dispose() {
    _bannerAdOne?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));

    _getInAppReviewStatus();
    _analytics();
    /*_inAppReview();*/
    /*_loadAd();*/

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
        .logScreenView(screenName: 'HomeView');
  }

  Future<void> _inAppReview() async {
    if (await inAppReview.isAvailable()) {
      DateTime referenceDate = DateTime.parse('1970-01-01T00:00:00Z');
      DateTime inAppDate = DateTime.fromMillisecondsSinceEpoch(inAppReviewDate);
      var dateIsCorrect = inAppDate == referenceDate ? false : true;
      if (inAppReviewStatus == 1 && dateIsCorrect ? inAppDate.difference(DateTime.now()).inDays > 90 : true) {
        inAppReview.requestReview();
        _setInAppReviewDate();
      }
    }
  }

  Future<void> _getInAppReviewStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    inAppReviewStatus = await prefs.getInt("inAppReviewStatus") ?? 0;
    inAppReviewDate = await prefs.getInt("inAppReviewDate") ?? 0;
  }

  Future<void> _setInAppReviewDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("inAppReviewDate", DateTime.now().millisecondsSinceEpoch);
  }

  void _loadAd() {
    final bannerAdOne = BannerAd(
      size: adSize,
      adUnitId: adOneUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAdOne = ad as BannerAd;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );

    // Start loading.
    bannerAdOne.load();
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
        bottom: 124 + MediaQuery.of(context).padding.bottom,
      ),
      itemCount: 1,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        widget.animationController?.forward();
        return SingleChildScrollView(
          child: Stack(
            children: [
              Center(
                child:
                Column(
                  children: [
                    TitleView(
                      titleTxt: 'overall_stats'.tr(context),
                      subTxt: '',
                      animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                          parent: widget.animationController!,
                          curve:
                          Interval((1 / 8) * 1, 1.0, curve: Curves.fastOutSlowIn))),
                      animationController: widget.animationController!,
                    ),
                    OverallStatisticsView(
                        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                            parent: widget.animationController!,
                            curve:
                            Interval((1 / 8) * 2, 1.0, curve: Curves.fastOutSlowIn))),
                        animationController: widget.animationController!
                    ),
                    /*AnimatedBuilder(
                      animation: widget.animationController!,
                      builder: (BuildContext context, Widget? child) {
                        return FadeTransition(
                          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                              parent: widget.animationController!,
                              curve: Interval((1 / 8) * 3, 1.0, curve: Curves.fastOutSlowIn))),
                          child: new Transform(
                            transform: new Matrix4.translationValues(
                                0.0, 30 * (1.0 - Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                                parent: widget.animationController!,
                                curve: Interval((1 / 8) * 3, 1.0, curve: Curves.fastOutSlowIn))).value), 0.0),
                            child: SafeArea(
                              child: SizedBox(
                                width: adSize.width.toDouble(),
                                height: adSize.height.toDouble(),
                                child: _bannerAdOne == null
                                // Nothing to render yet.
                                    ? SizedBox()
                                // The actual ad.
                                    : AdWidget(ad: _bannerAdOne!),
                              ),
                            ),
                          ),
                        );
                      },
                    ),*/
                    SizedBox(height: 16,),
                    TitleView(
                      titleTxt: 'heroes_stats'.tr(context),
                      subTxt: 'more'.tr(context),
                      animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                          parent: widget.animationController!,
                          curve:
                          Interval((1 / 8) * 4, 1.0, curve: Curves.fastOutSlowIn))),
                      animationController: widget.animationController!,
                      route: AllHeroesListView(
                        animationController: widget.animationController,
                      ),
                    ),
                    HeroesListView(
                      mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                              parent: widget.animationController!,
                              curve: Interval((1 / 8) * 5, 1.0,
                                  curve: Curves.fastOutSlowIn))),
                      mainScreenAnimationController: widget.animationController,
                    ),
                    SizedBox(height: 16,),
                    TitleView(
                      titleTxt: 'games_history'.tr(context),
                      subTxt: 'more'.tr(context),
                      animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                          parent: widget.animationController!,
                          curve:
                          Interval((1 / 8) * 7, 1.0, curve: Curves.fastOutSlowIn))),
                      animationController: widget.animationController!,
                      route: AllGamesListView(
                        animationController: widget.animationController,
                      ),
                    ),
                    GamesListView(
                      mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                              parent: widget.animationController!,
                              curve: Interval((1 / 8) * 8, 1.0,
                                  curve: Curves.fastOutSlowIn))),
                      mainScreenAnimationController: widget.animationController,
                    ),
                  ],
                ),
              )
            ],
          ),
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
                                    left: 32,
                                    right: 32,
                                    top: 0,
                                    bottom: 8),
                                child: InkWell(
                                  onTap: () => {
                                  },
                                  child: SizedBox(
                                    width: 20,
                                    height: 88,
                                    child: FittedBox(
                                      child: Image.asset(
                                          'assets/dt_companion/dicethronelogo.webp'),
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                )
                              ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 8,
                                    right: 8,
                                    top: 24,
                                    bottom: 8),
                                child: Text(
                                  "companion".tr(context),
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
