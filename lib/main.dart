import 'package:flutter/material.dart';
import 'nav.dart';
import 'decks.dart';
import 'package:tcgenius/scry.dart';
import 'cardSearch.dart';
//import 'dart:async';
//import 'dart:convert';
//import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TCGenius',
      initialRoute: "/",
      routes: {
        "/": (context) => HomePage("TCGenius"),
        "/decks": (context) => DeckPage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
