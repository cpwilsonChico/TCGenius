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
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text("Sign in to TCGenius"),
      ),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RaisedButton(
              child: Text("Continue without signing in"),
              onPressed: () => _auth.signInAnon(),
            ),
            RaisedButton(
              child: Text("Sign in using Google"),
              onPressed: () => _auth.signInGoogle(),
            )
          ]
        )
      ),
    );
  }
}
