import 'package:dt_companion/dt_companion/companion_app_theme.dart';
import 'package:dt_companion/dt_companion/models/dta_data.dart';
import 'package:dt_companion/dt_companion/models/heroes_data.dart';
import 'package:dt_companion/dt_companion/service.dart';
import 'package:dt_companion/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DTAGameView extends StatefulWidget {
  const DTAGameView(
      {Key? key, this.animationController, this.animation, this.dtaListData})
      : super(key: key);

  final AnimationController? animationController;
  final Animation<double>? animation;
  final DTAData? dtaListData;

  @override
  _DTAGameViewState createState() => _DTAGameViewState();
}

class _DTAGameViewState extends State<DTAGameView>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  void showAlertDialog(BuildContext context, UserService service) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(
        "Cancel",
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
        "Continue",
        style: TextStyle(color: CompanionAppTheme.lightText),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        deleteGame(service);
      },
      style: ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all<Color>(CompanionAppTheme.darkerText),
      ),
    );

    AlertDialog alert = AlertDialog(
      title: Text(
        "Are you sure ?",
        style: TextStyle(color: CompanionAppTheme.dark_grey),
      ),
      content: Text(
        "Do you want to delete this game? This action is irreversible.",
        style: TextStyle(color: CompanionAppTheme.dark_grey),
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

  Future<void> deleteGame(UserService service) async {
    service.deleteDTAData(widget.dtaListData!);
  }

  String getImagePath(String character) {
    return "assets/dt_companion/${CharacterExtension.fromDisplayName(character)?.nameWithoutEnum}.png";
  }

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);

    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.animation!,
          child: new Transform(
            transform: new Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 16, bottom: 18),
              child: Container(
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
                        topRight: Radius.circular(68.0)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: CompanionAppTheme.grey.withOpacity(0.2),
                          offset: Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Padding(
                      padding: EdgeInsets.only(
                          top: 16, left: 16, right: 16, bottom: 4),
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.only(left: 8, top: 0, bottom: 16),
                            child: Row(
                              children: [
                                Text(
                                  widget.dtaListData?.teamName ?? '',
                                  style: TextStyle(
                                    fontFamily: CompanionAppTheme.fontName,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: CompanionAppTheme.lightText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          for (var player in widget.dtaListData?.players ?? [])
                            Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 54,
                                    height: 54,
                                    child: Stack(
                                      children: [
                                        ClipOval(
                                          child: Container(
                                            width: 54,
                                            height: 54,
                                            decoration: BoxDecoration(
                                              color:
                                                  CompanionAppTheme.dark_grey,
                                              borderRadius:
                                                  BorderRadius.circular(27),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: ClipOval(
                                            child: Image.asset(
                                              getImagePath(
                                                  player.character ?? ''),
                                              width: 42,
                                              height: 42,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Text(
                                    player.name ?? '',
                                    style: TextStyle(
                                      fontFamily: CompanionAppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                      color: CompanionAppTheme.lightText,
                                    ),
                                  ),
                                  Spacer()
                                ],
                              ),
                            ),
                          Divider(
                            color: CompanionAppTheme.lightText,
                            thickness: 1,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, bottom: 8),
                                child: Text(
                                  DateFormat('dd/MM/yyyy').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          widget.dtaListData?.date ?? 0)),
                                  style: TextStyle(
                                    fontFamily: CompanionAppTheme.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    letterSpacing: -0.1,
                                    color: CompanionAppTheme.lightText
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ),
                              Spacer(),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      right: 16, bottom: 8),
                                  child: InkWell(
                                    onTap: () =>
                                        {showAlertDialog(context, userService)},
                                    child: Icon(
                                      Icons.delete_forever,
                                      color: CompanionAppTheme.lightText,
                                      size: 26,
                                    ),
                                  )),
                              Spacer(),
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 16, bottom: 8),
                                child: Icon(
                                  widget.dtaListData?.inprogress ?? true
                                      ? Icons.timer
                                      : Icons.timer_off,
                                  color: widget.dtaListData?.inprogress ?? true
                                      ? CompanionAppTheme.victoryGreen
                                      : CompanionAppTheme.defeatRed,
                                  size: 26,
                                ),
                              ),
                            ],
                          )
                        ],
                      ))),
            ),
          ),
        );
      },
    );
  }
}
