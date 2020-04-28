import 'package:flutter/material.dart';
import 'cards.dart';
import 'nav.dart';

/*
// widget for viewing a single deck
class DeckViewPage extends StatefulWidget {
  final Deck deck;
  DeckViewPage(this.deck);
  State<DeckViewPage> createState() => DeckPageState(deck);
}

class DeckPageState extends State<DeckViewPage> {
  Deck deck;
  DeckPageState(this.deck);

  Widget build(BuildContext context) {
    return Text("hi");
  }
}*/

/*
// widget for viewing a single deck
class DeckView extends StatelessWidget {
  final Deck deck;
  DeckView(this.deck);

  Widget build(BuildContext context) {
    return Container(
      child: Text("${deck.deckName}"),
    );
  }
}*/

// widget for viewing / editing a deck
class DeckView extends StatefulWidget {
  final Deck deck;
  DeckView({this.deck});
  State<DeckView> createState() => DeckViewState(deck: deck);
}

class DeckViewState extends State<DeckView> {
  DeckViewState({this.deck});
  Deck deck;

  @override
  void initState() {
    super.initState();
    if (deck == null) deck = new Deck.empty();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text("${deck.deckName}"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () {
              showCancelDialog(context);
            }
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              // TODO implement
              print("Saved.");
            }
          )
        ]
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[

        ]
      )
    );
  }

  void showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Clear Deck"),
          content: Text("Are you sure you want to remove all cards from this deck?"),
          actions: <Widget>[
            FlatButton(
              child: Text("No"),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              child: Text("Yes"),
              onPressed: () {
                deck.clear();
                setState((){});
                Navigator.pop(context);
              }
            )
          ]
        );
      }
    );
  }
}