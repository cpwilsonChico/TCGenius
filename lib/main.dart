import 'package:flutter/material.dart';
import 'nav.dart';
import 'decks.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TCGenius',
      initialRoute: "/",
      routes: {
        "/": (context) => HomePage(),
        "/decks": (context) => DeckPage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class HomePage extends StatelessWidget {

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text("TCGenius"),
      ),
      body: Center(
        child: Text("Placeholder")
      )
    );
  }
}
