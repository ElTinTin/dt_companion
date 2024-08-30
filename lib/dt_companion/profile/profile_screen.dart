import 'package:dt_companion/dt_companion/extension/localization_extension.dart';
import 'package:dt_companion/dt_companion/profile/faq_screen.dart';
import 'package:dt_companion/dt_companion/profile/friends_list_view.dart';
import 'package:dt_companion/dt_companion/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_donation_buttons/donationButtons/ko-fiButton.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import '../companion_app_theme.dart';
import '../ui_view/title_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  final Uri _termsURL =
      Uri.parse('https://eltintin.github.io/dt_companion/terms.md');
  final Uri _privacyURL =
      Uri.parse('https://eltintin.github.io/dt_companion/privacy.md');

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

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
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
    final userService = Provider.of<UserService>(context);

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
        return Column(
          children: [
            AnimatedBuilder(
              animation: widget.animationController!,
              builder: (BuildContext context, Widget? child) {
                return FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: widget.animationController!,
                          curve: Interval((1 / 5) * 4, 1.0,
                              curve: Curves.fastOutSlowIn))),
                  child: new Transform(
                    transform: new Matrix4.translationValues(
                        0.0,
                        30 *
                            (1.0 -
                                Tween<double>(begin: 0.0, end: 1.0)
                                    .animate(CurvedAnimation(
                                        parent: widget.animationController!,
                                        curve: Interval((1 / 5) * 4, 1.0,
                                            curve: Curves.fastOutSlowIn)))
                                    .value),
                        0.0),
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                foregroundColor: CompanionAppTheme.darkerText,
                                backgroundColor: CompanionAppTheme.lightText,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 15.0,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 16),
                                textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: CompanionAppTheme.darkerText)),
                            child: Text('profile_friends_title'.tr(context)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FriendsListView(
                                        animationController:
                                            widget.animationController!)),
                              );
                            },
                          ),
                        )),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: widget.animationController!,
              builder: (BuildContext context, Widget? child) {
                return FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: widget.animationController!,
                          curve: Interval((1 / 5) * 4, 1.0,
                              curve: Curves.fastOutSlowIn))),
                  child: new Transform(
                    transform: new Matrix4.translationValues(
                        0.0,
                        30 *
                            (1.0 -
                                Tween<double>(begin: 0.0, end: 1.0)
                                    .animate(CurvedAnimation(
                                        parent: widget.animationController!,
                                        curve: Interval((1 / 5) * 4, 1.0,
                                            curve: Curves.fastOutSlowIn)))
                                    .value),
                        0.0),
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                foregroundColor: CompanionAppTheme.darkerText,
                                backgroundColor: CompanionAppTheme.lightText,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 15.0,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 16),
                                textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: CompanionAppTheme.darkerText)),
                            child: const Text('Rulepop'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const FAQScreen()),
                              );
                            },
                          ),
                        )),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: widget.animationController!,
              builder: (BuildContext context, Widget? child) {
                return FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: widget.animationController!,
                          curve: Interval((1 / 5) * 4, 1.0,
                              curve: Curves.fastOutSlowIn))),
                  child: new Transform(
                    transform: new Matrix4.translationValues(
                        0.0,
                        30 *
                            (1.0 -
                                Tween<double>(begin: 0.0, end: 1.0)
                                    .animate(CurvedAnimation(
                                    parent: widget.animationController!,
                                    curve: Interval((1 / 5) * 4, 1.0,
                                        curve: Curves.fastOutSlowIn)))
                                    .value),
                        0.0),
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                foregroundColor: CompanionAppTheme.darkerText,
                                backgroundColor: CompanionAppTheme.lightText,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 15.0,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 16),
                                textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: CompanionAppTheme.darkerText)),
                            child: const Text('Export local data'),
                            onPressed: () {
                              userService.backupDataToFirestore(context);
                            },
                          ),
                        )),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: widget.animationController!,
              builder: (BuildContext context, Widget? child) {
                return FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: widget.animationController!,
                          curve: Interval((1 / 5) * 4, 1.0,
                              curve: Curves.fastOutSlowIn))),
                  child: new Transform(
                    transform: new Matrix4.translationValues(
                        0.0,
                        30 *
                            (1.0 -
                                Tween<double>(begin: 0.0, end: 1.0)
                                    .animate(CurvedAnimation(
                                        parent: widget.animationController!,
                                        curve: Interval((1 / 5) * 4, 1.0,
                                            curve: Curves.fastOutSlowIn)))
                                    .value),
                        0.0),
                    child: Container(
                        height: 80,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: const SignOutButton(),
                        )),
                  ),
                );
              },
            ),
            TitleView(
              titleTxt: 'other'.tr(context),
              subTxt: '',
              animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                      parent: widget.animationController!,
                      curve: Interval((1 / 5) * 3, 1.0,
                          curve: Curves.fastOutSlowIn))),
              animationController: widget.animationController!,
            ),
            AnimatedBuilder(
              animation: widget.animationController!,
              builder: (BuildContext context, Widget? child) {
                return FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: widget.animationController!,
                          curve: Interval((1 / 5) * 4, 1.0,
                              curve: Curves.fastOutSlowIn))),
                  child: new Transform(
                    transform: new Matrix4.translationValues(
                        0.0,
                        30 *
                            (1.0 -
                                Tween<double>(begin: 0.0, end: 1.0)
                                    .animate(CurvedAnimation(
                                        parent: widget.animationController!,
                                        curve: Interval((1 / 5) * 4, 1.0,
                                            curve: Curves.fastOutSlowIn)))
                                    .value),
                        0.0),
                    child: Container(
                        height: 80,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: KofiButton(
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                Color(0xffffffff),
                              ), //text (and icon)
                            ),
                            kofiName: "quentindfabrik",
                            kofiColor: KofiColor.Red,
                            onDonation: () {
                              // Runs after the button has been pressed
                              debugPrint("On donation");
                            },
                          ),
                        )),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: widget.animationController!,
              builder: (BuildContext context, Widget? child) {
                return FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: widget.animationController!,
                          curve: Interval((1 / 5) * 5, 1.0,
                              curve: Curves.fastOutSlowIn))),
                  child: new Transform(
                      transform: new Matrix4.translationValues(
                          0.0,
                          30 *
                              (1.0 -
                                  Tween<double>(begin: 0.0, end: 1.0)
                                      .animate(CurvedAnimation(
                                          parent: widget.animationController!,
                                          curve: Interval((1 / 5) * 5, 1.0,
                                              curve: Curves.fastOutSlowIn)))
                                      .value),
                          0.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor:
                                        CompanionAppTheme.darkerText,
                                    backgroundColor:
                                        CompanionAppTheme.lightText,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 15.0,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 16),
                                    textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: CompanionAppTheme.darkerText,
                                    ),
                                  ),
                                  child: Text('profile_terms'.tr(context)),
                                  onPressed: () {
                                    _launchUrl(_termsURL);
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 32,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor:
                                        CompanionAppTheme.darkerText,
                                    backgroundColor:
                                        CompanionAppTheme.lightText,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 15.0,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 16),
                                    textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: CompanionAppTheme.darkerText,
                                    ),
                                  ),
                                  child: Text('profile_privacy'.tr(context)),
                                  onPressed: () {
                                    _launchUrl(_privacyURL);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                );
              },
            )
          ],
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
                                  'Profile',
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
