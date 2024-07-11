import 'package:best_flutter_ui_templates/dt_companion/companion/match_view.dart';
import 'package:best_flutter_ui_templates/dt_companion/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'bottom_navigation_view/bottom_bar_view.dart';
import 'companion_app_theme.dart';
import 'companion/companion_screen.dart';
import 'models/tabIcon_data.dart';

class CompanionAppHomeScreen extends StatefulWidget {
  @override
  _CompanionAppHomeScreenState createState() => _CompanionAppHomeScreenState();
}

class _CompanionAppHomeScreenState extends State<CompanionAppHomeScreen>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  List<TabIconData> tabIconsList = <TabIconData>[
    TabIconData(
      imagePath: 'assets/dt_companion/tab_1.png',
      selectedImagePath: 'assets/dt_companion/tab_1s.png',
      index: 0,
      isSelected: true,
      animationController: null,
    ),
    TabIconData(
      imagePath: 'assets/dt_companion/tab_2.png',
      selectedImagePath: 'assets/dt_companion/tab_2s.png',
      index: 1,
      isSelected: false,
      animationController: null,
    ),
  ];

  Widget tabBody = Container(
    color: CompanionAppTheme.background,
  );

  @override
  void initState() {
    tabIconsList.forEach((TabIconData tab) {
      tab.isSelected = false;
    });
    tabIconsList[0].isSelected = true;

    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    tabBody = CompanionScreen(animationController: animationController);
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CompanionAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            tabBody,
            bottomBar(),
          ],
        ),
      ),
    );
  }

  Widget bottomBar() {
    return Column(
      children: <Widget>[
        const Expanded(
          child: SizedBox(),
        ),
        BottomBarView(
          tabIconsList: tabIconsList,
          addClick: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MatchView(
                  animationController: animationController
              )),
            );
          },
          changeIndex: (int index) {
            if (index == 0) {
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody =
                      CompanionScreen(animationController: animationController);
                });
              });
            } else if (index == 1) {
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody =
                      ProfileScreen(animationController: animationController);
                });
              });
            }
          },
        ),
      ],
    );
  }
}
