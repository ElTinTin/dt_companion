import 'dart:async';
import 'dart:io';
import 'package:dt_companion/dt_companion/companion_app_home_screen.dart';
import 'package:dt_companion/dt_companion/companion_app_theme.dart';
import 'package:dt_companion/dt_companion/init/initialization_view.dart';
import 'package:dt_companion/dt_companion/init/introduction_view.dart';
import 'package:dt_companion/dt_companion/service.dart';
import 'package:dt_companion/dt_companion/ui_view/auth_gate.dart';
import 'package:dt_companion/dt_companion/ui_view/signin_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'AppLocalizations.dart';
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
          textTheme: CompanionAppTheme.textTheme,
          platform: TargetPlatform.iOS,
        ),
        supportedLocales: const [Locale('en'), Locale('fr')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          for (var locale in supportedLocales) {
            if (deviceLocale != null && deviceLocale.languageCode == locale.languageCode) {
              return deviceLocale;
            }
          }
          return supportedLocales.first;
        },
        initialRoute: initScreen == 0 ? "first" : "/",
        routes: {
          '/': (context) => InitializationWidget(
            child: AuthGate(),
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
