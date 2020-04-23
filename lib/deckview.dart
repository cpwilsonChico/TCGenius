import 'package:flutter/material.dart';
import 'cards.dart';
import 'nav.dart';

class DeckView extends StatefulWidget {
  final Deck deck;
  DeckView(this.deck);

  State<DeckView> createState() => DeckViewState(deck);
}

class DeckViewState extends State<DeckView> {
  Deck deck;
  DeckViewState(this.deck);

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text("TCGenius"),
      ),
      body: Text("${deck.deckName}"),
    );
  }
}