import 'package:flutter/cupertino.dart';
import '../../AppLocalizations.dart';

extension TranslateWhoutArgs on String {
  String tr(BuildContext context) {
    return AppLocalizations.of(context)!.translate(this);
  }
}

extension TranslateWithArg on String {
  String trWithArg(BuildContext context,Map<String, dynamic> args) {
    return AppLocalizations.of(context)!.translateWithArgs(this,args);
  }
}