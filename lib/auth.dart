import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'storage.dart';

class Authenticator {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FirebaseUser> signInAnon() async {
    try {
      AuthResult res = await _auth.signInAnonymously();
      FirebaseUser user = res.user;
      FirebaseDB.instance.setUID(user.uid);
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // credit: https://github.com/sbis04/sign_in_flutter/blob/master/lib/sign_in.dart
  Future<FirebaseUser> signInGoogle() async {
    print("google sign in started");
    GoogleSignInAccount gsia = await GoogleSignIn().signIn();
    GoogleSignInAuthentication gsiauth = await gsia.authentication;
    AuthCredential cred = GoogleAuthProvider.getCredential(
      accessToken: gsiauth.accessToken,
      idToken: gsiauth.idToken,
    );
    AuthResult authres = await _auth.signInWithCredential(cred);
    print(authres.user.uid);
    print(authres.user.email);
    FirebaseDB.instance.setUID(authres.user.uid);
    return authres.user;
  }


  Future<String> getUID() async {
    return (await _auth.currentUser()).uid;
  }

  Stream<FirebaseUser> get userStream {
    return _auth.onAuthStateChanged;
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }


}