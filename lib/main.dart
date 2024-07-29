import 'dart:async';
import 'dart:io';
import 'package:best_flutter_ui_templates/dt_companion/companion_app_home_screen.dart';
import 'package:best_flutter_ui_templates/dt_companion/companion_app_theme.dart';
import 'package:best_flutter_ui_templates/dt_companion/init/initialization_view.dart';
import 'package:best_flutter_ui_templates/dt_companion/init/introduction_view.dart';
import 'package:best_flutter_ui_templates/dt_companion/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

int initScreen = 0;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Onboarding
  SharedPreferences prefs = await SharedPreferences.getInstance();
  initScreen = await prefs.getInt("initScreen") ?? 0;
  await prefs.setInt("initScreen", 1);
  // Mobile Ads
  unawaited(MobileAds.instance.initialize());
  // Firebase Init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Device Orientation
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_) => runApp(
        ChangeNotifierProvider<UserService>(
          create: (context) => UserService(),
          child: MyApp(),
        ),
      ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:
          !kIsWeb && Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return MaterialApp(
        title: 'DT Companion',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: CompanionAppTheme.textTheme,
          platform: TargetPlatform.iOS,
        ),
        initialRoute: initScreen == 0 ? "first" : "/",
        routes: {
          '/': (context) => InitializationWidget(
            child: CompanionAppHomeScreen(index: 0,),
          ),
          "first": (context) => InitializationWidget(
            child: OnBoarding(),
          ),
        });
  }
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}
