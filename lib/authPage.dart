import 'package:flutter/material.dart';
import 'auth.dart';
import 'nav.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final Authenticator _auth = Authenticator();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer: NavDrawer(),
      appBar: AppBar(
        title: Text("Sign in to TCGenius"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RaisedButton(
              child: Text("Continue without signing in"),
              onPressed: () async {
                await _auth.signInAnon();
                if (_auth.getUID() != null) {
                  Navigator.pushNamed(context, "/home");
                } else {
                  showFailureDialog(context);
                }
              }
            ),
            SizedBox(height: 20),
            RaisedButton(
              child: Text("Sign in using Google"),
              onPressed: () async {
                await _auth.signInGoogle();
                if (_auth.getUID() != null) {
                  Navigator.pushNamed(context, "/home");
                } else {
                  showFailureDialog(context);
                }
              }
            )
          ]
        )
      ),
    );
  }

  void showFailureDialog(BuildContext context) {
    showDialog(
      context: context,
      child: AlertDialog(
        title: Text("Failed to sign in."),
        actions: <Widget>[
          FlatButton(
            child: Text("OK"),
            onPressed: () => Navigator.pop(context),
          )
        ]
      )
    );
  }
}
