import 'package:flutter/material.dart';
import 'nav.dart';
import 'deckPage.dart';
import 'package:tcgenius/scry.dart';
import 'package:provider/provider.dart';
import 'cardSearch.dart';
import 'authPage.dart';
import 'auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'dart:async';
//import 'dart:convert';
//import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<FirebaseUser>.value(
      value: Authenticator().userStream,
      child: MaterialApp(
        title: 'TCGenius',
        initialRoute: "/",
        routes: {
          "/": (context) => AuthPage(),
          //"/": (context) => HomePage("TCGenius"),
          "/decks": (context) => DeckPage(),
        },
        theme: ThemeData.dark(),
        //theme: ThemeData(
         // primarySwatch: Colors.blue,
        //),
      ),
    );
  }
}

class HomePage extends StatelessWidget {

  final String title;
  final Data data = new Data();

  HomePage(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text("TCGenius"),
      ),
      body: Center(
        child: CardSearch(),
      )
    );
  }
}
