import 'package:best_flutter_ui_templates/dt_companion/companion_app_home_screen.dart';
import 'package:best_flutter_ui_templates/dt_companion/companion_app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';

class OnBoarding extends StatelessWidget {
  const OnBoarding({super.key});

  @override
  Widget build(BuildContext context) {
    return OnBoardingSlider(
      finishButtonText: 'Go !',
      onFinish: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => CompanionAppHomeScreen(),
          ),
        );
      },
      finishButtonStyle: FinishButtonStyle(
        backgroundColor: CompanionAppTheme.lightText,
      ),
      trailing: Text(
        '',
        style: TextStyle(
          fontSize: 16,
          color: CompanionAppTheme.lightText,
          fontWeight: FontWeight.w600,
        ),
      ),
      skipTextButton: Text(
        'Skip',
        style: TextStyle(
          fontSize: 16,
          color: CompanionAppTheme.lightText,
          fontWeight: FontWeight.w600,
        ),
      ),
      controllerColor: CompanionAppTheme.lightText,
      totalPage: 3,
      headerBackgroundColor: CompanionAppTheme.background,
      pageBackgroundColor: CompanionAppTheme.background,
      background: [
        Column(
          children: [
            SizedBox(height: 32),
            Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: CompanionAppTheme.lightText,
                          width: 5.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0), // Uniform radius
                      ),
                      child: Image.asset(
                        'assets/dt_companion/slide_1.png',
                        height: 450,
                      ),
                    ))
            ),
          ],
        ),
        Column(
          children: [
            SizedBox(height: 32),
            Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: CompanionAppTheme.lightText,
                          width: 5.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0), // Uniform radius
                      ),
                      child: Image.asset(
                        'assets/dt_companion/slide_2.png',
                        height: 450,
                      ),
                    ))
            ),
          ],
        ),
        Column(
          children: [
            SizedBox(height: 32),
            Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: CompanionAppTheme.lightText,
                          width: 5.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0), // Uniform radius
                      ),
                      child: Image.asset(
                        'assets/dt_companion/slide_3.png',
                        height: 450,
                      ),
                    ))
            ),
          ],
        ),
      ],
      speed: 1.8,
      pageBodies: [
        Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 520,
              ),
              Text(
                'All your stats ...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CompanionAppTheme.lightText,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'on your pocket! Show your supremacy yo your friends.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CompanionAppTheme.lightText,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 520,
              ),
              Text(
                'Simply way to add a match.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CompanionAppTheme.lightText,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Three modes (1v1, 2v2, KOTH). Select your character, opponents/partners names, their character and who won the game.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CompanionAppTheme.lightText,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 520,
              ),
              Text(
                'Access FAQ, more is coming.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CompanionAppTheme.lightText,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Official FAQ from Dice Throne. More functionality is coming.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CompanionAppTheme.lightText,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
