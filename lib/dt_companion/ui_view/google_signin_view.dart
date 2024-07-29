import 'package:dt_companion/dt_companion/companion_app_theme.dart';
import 'package:dt_companion/dt_companion/service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class GoogleSignInView extends StatefulWidget {
  const GoogleSignInView({Key? key}) : super(key: key);

  @override
  State<GoogleSignInView> createState() => _GoogleSignInViewState();
}

class _GoogleSignInViewState extends State<GoogleSignInView> {
  ValueNotifier userCredential = ValueNotifier('');

  Future<dynamic> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on Exception catch (e) {
      // TODO
      print('exception->$e');
    }
  }

  Future<bool> signOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);

    return ValueListenableBuilder(
        valueListenable: userCredential,
        builder: (context, value, child) {
          return (userCredential.value == '' || userCredential.value == null)
              ? GestureDetector(
                  onTap: () async =>
                      {userCredential.value = await signInWithGoogle()},
                  child: SizedBox(
                    child: Center(
                      child: Card(
                          color: CompanionAppTheme.lightText,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 16,
                              ),
                              IconButton(
                                iconSize: 22,
                                icon: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: FittedBox(
                                    child: Image.asset(
                                      'assets/dt_companion/symbole-google.png',
                                    ),
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                                onPressed: () async {},
                              ),
                              SizedBox(
                                width: 32,
                              ),
                              Text(
                                'Import / Export your data',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: CompanionAppTheme.fontName,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  letterSpacing: 0.0,
                                  color: CompanionAppTheme.darkerText,
                                ),
                              ),
                            ],
                          )),
                    ),
                  ),
                )
              : Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(width: 1.5, color: Colors.black54)),
                        child: Image.network(
                            userCredential.value.user!.photoURL.toString()),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        userCredential.value.user!.email.toString(),
                        style: TextStyle(
                          fontFamily: CompanionAppTheme.fontName,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 0.0,
                          color: CompanionAppTheme.lightText,
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      Container(
                          child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor: CompanionAppTheme.darkerText,
                                        backgroundColor: CompanionAppTheme.lightText,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        elevation: 15.0,
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                                        textStyle: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: CompanionAppTheme.darkerText)),
                                    child: const Text('Import'),
                                    onPressed: () async {
                                      await userService.restoreDataFromFirestore();
                                    },
                                  ),
                                  SizedBox(width: 32,),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor: CompanionAppTheme.darkerText,
                                        backgroundColor: CompanionAppTheme.lightText,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        elevation: 15.0,
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                                        textStyle: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: CompanionAppTheme.darkerText)),
                                    child: const Text('Export'),
                                    onPressed: () async {
                                      await userService.backupDataToFirestore();
                                    },
                                  ),
                                ],
                              )
                          )
                      ),
                    ],
                  ),
                );
        });
  }
}
