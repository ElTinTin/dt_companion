import 'package:dt_companion/dt_companion/service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../companion_app_theme.dart';

class InitializationWidget extends StatefulWidget {
  final Widget child;

  InitializationWidget({required this.child});

  @override
  _InitializationWidgetState createState() => _InitializationWidgetState();
}

class _InitializationWidgetState extends State<InitializationWidget> {
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initialize();
  }

  Future<void> _initialize() async {
    await Provider.of<UserService>(context, listen: false).fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Container(
              color: CompanionAppTheme.background,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 32, right: 32, top: 0, bottom: 8),
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: FittedBox(
                      child: Image.asset(
                          'assets/dt_companion/logo_dt.png'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              )
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          return widget.child;
        }
      },
    );
  }
}
