import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'nav.dart';
import 'cards.dart';
import 'deckview.dart';
import 'storage.dart';

class DeckPage extends StatefulWidget {
  State<DeckPage> createState() => DeckPageState();
}

class DeckPageState extends State<DeckPage> {
  Future<List<Deck>> deckFuture;
  SortOptions sortOption = SortOptions.NAME;

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
            onPressed: () => showSettingsDialog(context),
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
              sortDeck(decks);
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

  void sortDeck(List<Deck> list) {
    switch (sortOption) {
      case SortOptions.NAME:
        list.sort(compareByName);
        break;
      case SortOptions.FORMAT:
        list.sort(compareByFormat);
        break;
      case SortOptions.PRICE:
        list.sort(compareByPrice);
        break;
      default:
        break;
    }
  }

  int compareByName(Deck a, Deck b) {
    return a.deckName.compareTo(b.deckName);
  }
  int compareByFormat(Deck a, Deck b) {
    return a.getFormat().compareTo(b.getFormat());
  }
  int compareByPrice(Deck a, Deck b) {
    double dif = a.getTotalPrice() - b.getTotalPrice();
    if (dif < 0) return -1;
    if (dif > 0) return 1;
    return 0;
  }

  // callback passed to DeckBuilder
  void refresh() async {
    deckFuture = getDecks();
    setState((){});
  }

  // callback passed to SortChooser
  void setSortOptions(SortOptions so) {
    sortOption = so;
    setState((){});
  }

  void showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      child: AlertDialog(
        title: Text("Sort by:"),
        content: SortChooser(setSortOptions, sortOption),
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

enum SortOptions {
  NAME,
  FORMAT,
  PRICE
}

class SortChooser extends StatefulWidget {
  final Function sortCallback;
  final SortOptions initialOption;
  SortChooser(this.sortCallback, this.initialOption);
  @override
  _SortChooserState createState() => _SortChooserState(sortCallback, initialOption);
}

class _SortChooserState extends State<SortChooser> {
  final Function sortCallback;    // callback from DeckPage
  _SortChooserState(this.sortCallback, SortOptions initial) {
    groupValue = initial;
  }

  SortOptions groupValue;
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Align(
                  alignment: Alignment.topLeft,
                  child: FlatButton(
                    padding: EdgeInsets.all(0),
                    child: Text("Name"),
                    splashColor: Colors.transparent,
                    onPressed: () {
                      groupValue = SortOptions.NAME;
                      sortCallback(groupValue);
                      setState((){});
                    }
                  ),
                ),
                leading: Radio(
                  value: SortOptions.NAME,
                  groupValue: groupValue,
                  onChanged: (SortOptions val) {
                    groupValue = val;
                    sortCallback(val);
                    setState((){});
                  },
                ),
              ),
              ListTile(
                title: Align(
                  alignment: Alignment.topLeft,
                  child: FlatButton(
                      padding: EdgeInsets.all(0),
                      child: Text("Format"),
                      splashColor: Colors.transparent,
                      onPressed: () {
                        groupValue = SortOptions.FORMAT;
                        sortCallback(groupValue);
                        setState((){});
                      }
                  ),
                ),
                leading: Radio(
                  value: SortOptions.FORMAT,
                  groupValue: groupValue,
                  onChanged: (SortOptions val) {
                    groupValue = val;
                    sortCallback(val);
                    setState((){});
                  }
                )
              ),
              ListTile(
                title: Align(
                  alignment: Alignment.topLeft,
                  child: FlatButton(
                      padding: EdgeInsets.all(0),
                      child: Text("Price"),
                      splashColor: Colors.transparent,
                      onPressed: () {
                        groupValue = SortOptions.PRICE;
                        sortCallback(groupValue);
                        setState((){});
                      }
                  ),
                ),
                leading: Radio(
                  value: SortOptions.PRICE,
                  groupValue: groupValue,
                  onChanged: (SortOptions val) {
                    groupValue = val;
                    sortCallback(val);
                    setState((){});
                  }
                )
              )
            ]
        )
    );
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
            builder: (context) => DeckBuilder(deck: Deck.copy(deck), isNew: false, refreshParent: refresh)
          ));
        },
        leading: Text("${deck.getDeckSize()}"),
        title: Text(deck.deckName),
        subtitle: Text(deck.getFormat()),
        trailing: Text("\$${deck.getTotalPrice().toStringAsFixed(2)}"),
      ),
    );
  }
}