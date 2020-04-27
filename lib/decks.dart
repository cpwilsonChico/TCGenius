import 'package:flutter/material.dart';
import 'nav.dart';
import 'cards.dart';
import 'deckview.dart';

class DeckPage extends StatefulWidget {

  State<DeckPage> createState() => DeckPageState();
}

class DeckPageState extends State<DeckPage> {
  Future<List<Deck>> deckFuture;

  @override
  initState() {
    super.initState();
    deckFuture = prototypeGetDecks();
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
                context, MaterialPageRoute(builder: (context) => DeckBuilderPage())),
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
              return Center(
                child: ListView.builder(
                    itemCount: decks.length,
                    itemBuilder: (BuildContext contxt, int index) {
                      return DeckItem(decks[index]);
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

  Future<List<Deck>> prototypeGetDecks() async {
    await new Future.delayed(Duration(seconds: 2));
    return <Deck>[
      new Deck("Alpha", null),
      new Deck("Bravo", null),
      new Deck("Charlie", null),
    ];
  }
}

class DeckItem extends StatelessWidget {
  final Deck deck;

  DeckItem(this.deck);

  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => DeckView(deck)
          ));
        },
        title: Text(deck.deckName),
        subtitle: Text("${deck.getDeckSize()}"),
      ),
    );
  }
}