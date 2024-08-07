import 'package:dt_companion/dt_companion/companion_app_theme.dart';
import 'package:dt_companion/dt_companion/extension/localization_extension.dart';
import 'package:dt_companion/dt_companion/models/friends_data.dart';
import 'package:dt_companion/dt_companion/service.dart';
import 'package:dt_companion/dt_companion/ui_view/friends_statistics_view.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class FriendsListView extends StatefulWidget {
  const FriendsListView({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;
  @override
  _FriendsListScreenState createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListView>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;

  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;
  TextEditingController _newFriend = TextEditingController();

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
    await FirebaseAnalytics.instance.logScreenView(screenName: 'FriendsListView');
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
        service.insertFriendsData(FriendsData(name: _newFriend.text));
        _newFriend.text = "";
      },
      style: ButtonStyle(
        backgroundColor:
        MaterialStateProperty.all<Color>(CompanionAppTheme.darkerText),
      ),
    );

    AlertDialog alert = AlertDialog(
      title: Text(
        "alert_friends_title".tr(context),
        style: TextStyle(color: CompanionAppTheme.dark_grey),
      ),
      content: TextField(
        decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: CompanionAppTheme.dark_grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: CompanionAppTheme.dark_grey),
          ),
          hintText: "..."
        ),
        style: TextStyle(
          color: CompanionAppTheme.dark_grey
        ),
        cursorColor: CompanionAppTheme.dark_grey,
        controller: _newFriend,
        autofocus: true,
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
            getFriendsList(userService.friendsListData),
            getAppBarUI(userService),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      ),
    );
  }

  Widget getFriendsList(List<FriendsData> friendsListData) {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.only(
        top: AppBar().preferredSize.height +
            MediaQuery.of(context).padding.top +
            80,
        bottom: 62 + MediaQuery.of(context).padding.bottom,
      ),
      itemCount: friendsListData.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
            .animate(CurvedAnimation(
                parent: widget.animationController!,
                curve: Interval((1 / friendsListData.length) * index, 1.0,
                    curve: Curves.fastOutSlowIn)));
        widget.animationController?.forward();

        return Padding(
          padding:
              const EdgeInsets.only(top: 0, bottom: 0, right: 12, left: 12),
          child: FriendsStatisticsView(
            animation: animation,
            animationController: widget.animationController!,
            friendsData: friendsListData[index],
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
                                    left: 32, right: 32, top: 4, bottom: 8),
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
                                    left: 8, right: 8, top: 4, bottom: 8),
                                child: Text(
                                  'profile_friends_title'.tr(context),
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
                                onPressed: () => {
                                  showAlertDialog(context, userService)
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
                      ),
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
