import 'package:dt_companion/dt_companion/companion_app_theme.dart';
import 'package:dt_companion/dt_companion/service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

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

  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);

    return ValueListenableBuilder(
        valueListenable: userCredential,
        builder: (context, value, child) {
          return (userCredential.value == '' || userCredential.value == null)
              ? SizedBox(
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
                              onPressed: () async {
                                userCredential.value = await signInWithGoogle();
                              },
                            ),
                            IconButton(
                              iconSize: 22,
                              icon: SizedBox(
                                width: 22,
                                height: 22,
                                child: FittedBox(
                                  child: Image.asset(
                                    'assets/dt_companion/logo-apple.png',
                                  ),
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                              onPressed: () async {
                                userCredential.value = await signInWithApple();
                              },
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
                                        foregroundColor:
                                            CompanionAppTheme.darkerText,
                                        backgroundColor:
                                            CompanionAppTheme.lightText,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        elevation: 15.0,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 16),
                                        textStyle: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                CompanionAppTheme.darkerText)),
                                    child: const Text('Import'),
                                    onPressed: () async {
                                      await userService
                                          .restoreDataFromFirestore();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text('Data backed up.')),
                                      );
                                    },
                                  ),
                                  SizedBox(
                                    width: 32,
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor:
                                            CompanionAppTheme.darkerText,
                                        backgroundColor:
                                            CompanionAppTheme.lightText,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        elevation: 15.0,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 16),
                                        textStyle: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                CompanionAppTheme.darkerText)),
                                    child: const Text('Export'),
                                    onPressed: () async {
                                      await userService.backupDataToFirestore();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text('Data saved.')),
                                      );
                                    },
                                  ),
                                ],
                              ))),
                    ],
                  ),
                );
        });
  }
}
