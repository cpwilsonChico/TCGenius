import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'nav.dart';
import 'cards.dart';
import 'deckview.dart';
import 'storage.dart';

class DeckPage extends StatefulWidget {

  State<DeckPage> createState() => DeckPageState();
}

class DeckPageState extends State<DeckPage> {
  Future<List<Deck>> deckFuture;

  @override
  initState() {
    super.initState();
    deckFuture = getDecks();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text("Decks"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                    DeckBuilder(deck: Deck.empty(), isNew: true, refreshParent: refresh,))),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => print("settings tap"),
          )
        ]
      ),
      body: Container(
        child: FutureBuilder(
          future: deckFuture,
          builder: (BuildContext ctxt, AsyncSnapshot<List<Deck>> snapshot) {
            if (snapshot.hasData) {
              List<Deck> decks = snapshot.data;
              if (decks == null ? true : decks.length == 0) {
                return Center(
                  child: Container(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                        "You don't have any decks yet.\nClick the plus icon to create one!",
                        textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return Center(
                child: ListView.builder(
                    itemCount: decks.length,
                    itemBuilder: (BuildContext contxt, int index) {
                      return DeckTile(decks[index], refresh);
                    }
                )
              );
            } else {
              return Center(
                child: SizedBox(
                  child: CircularProgressIndicator(),
                  height: 60,
                  width: 60,
                )
              );
            }
          },
        )
      )
    );
  }

  Future<List<Deck>> getDecks() async {
    return await FirebaseDB.instance.getDecks();
  }

  // callback passed to DeckBuilder
  void refresh() async {
    deckFuture = getDecks();
    setState((){});
  }
}

class DeckTile extends StatelessWidget {
  final Deck deck;
  final Function refresh;   // callback passed from DeckPage to DeckBuilder

  DeckTile(this.deck, this.refresh);

  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => DeckBuilder(deck: deck, isNew: false, refreshParent: refresh)
          ));
        },
        title: Text(deck.deckName),
        subtitle: Text("${deck.getDeckSize()}"),
      ),
    );
  }
}