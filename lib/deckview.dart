import 'package:flutter/material.dart';
import 'cards.dart';
import 'nav.dart';

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
}

class DeckView extends StatelessWidget {
  final Deck deck;
  DeckView(this.deck);

  Widget build(BuildContext context) {
    return Container(
      child: Text("${deck.deckName}"),
    );
  }
}

class DeckBuilderPage extends StatefulWidget {
  State<DeckBuilderPage> createState() => DeckBuilderState();
}

class DeckBuilderState extends State<DeckBuilderPage> {
  Deck deck;

  @override
  void initState() {
    super.initState();
    deck = new Deck.empty();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text("Deck Builder"),
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