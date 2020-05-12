import 'package:flutter/material.dart';
import 'cards.dart';
import 'scry.dart';

class CardSearch extends StatefulWidget {

  @override
  State<CardSearch> createState() => SearchState();
}

class SearchState extends State<CardSearch> {

  Data data = new Data();
  String searchTerm;
  Future<List<MTGCard>> futureCards;

  @override
  void initState() {
    super.initState();
    futureCards = initialFuture();
    //futureCards = data.getCardsByName("Cat");
  }

  Future<List<MTGCard>> initialFuture() async {
    return new List<MTGCard>();
  }

  void searchCallback(String name, String superType, String subType) {
    print("SEARCH CALLBACK");
    futureCards = data.getCardsByName(name, cardSuperType: superType, cardSubType: subType);
    setState((){});
  }

  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget> [
        CardSearchBar(searchCallback),
        CardListDisplay(futureCards),
      ]
    );
  }
}

// displays list of searched cards
class CardListDisplay extends StatelessWidget {
  final Future<List<MTGCard>> futureCards;
  CardListDisplay(this.futureCards);

  Widget build(BuildContext context) {
    return FutureBuilder<List<MTGCard>>(
        future: futureCards,
        builder: (BuildContext cont, AsyncSnapshot<List<MTGCard>> snapshot) {
          if (snapshot.hasData) {
            var cards = snapshot.data;

            return Flexible(
              child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: cards.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return CardListItem(cards[index]);
                    }
                )
            );

          } else {
            return SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            );
          }
        }
    );
  }
}

// each card in the list maps to one of these
class CardListItem extends StatelessWidget {
  final MTGCard card;
  CardListItem(this.card);

  Widget build(BuildContext context) {
//    return Container(
//      height: 50,
//      padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
//      child: Text(card.getName()),
//    );
    return Card(
        color: Color.fromARGB(0xFF, 0x54, 0x54, 0x54),
        child: ExpansionTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(card.getName(), style: TextStyle(color: card.getRarityColor())),
              Text(card.getManaString()),
            ]
          ),
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  ButtonBar(
                    children: <Widget>[
                      FlatButton(
                        onPressed: (){
                          showDialog(
                            context: context,
                            builder: (BuildContext context){
                              return AlertDialog(
                                content: Container(
                                  //margin: EdgeInsets.all(0),
                                  //padding: EdgeInsets.all(0),
                                  child: Column(
                                    //mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(
                                        width: 230,
                                        height: 350,
                                        child: Image.network(card.getImage()) ?? Text("Image Not Available"),
                                      ),
                                      Center(
                                          child: Text("\$${card.getPrice().toStringAsFixed(2)}"),
                                      )
                                      //Image.network(card.getImage()) ?? Text("Image Not Available"),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[FlatButton(
                                  child: Text("OK"),
                                  onPressed: () => Navigator.pop(context),
                                )]
                              );
                            },
                          );
                        },
                        child: Text(
                          "Details",
                          style: TextStyle(color: Colors.lightBlue),
                        ),
                      )

                    ],
                  ),
                  Text(
                      card.getSuperType() ?? 'Something went wrong try again later'
                  ),
                  SizedBox(height:12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment:  MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                          card.getSet() ?? 'Something went wrong try again later',
                          style: TextStyle(color: Colors.orange),
                      ),
                    ],
                  ),
                  SizedBox(height:12),
                  Text(
                      card.getOracleText() ?? 'Something went wrong try again later'
                  ),

                ],
                //card.getOracleText() ?? 'Something went wrong try again later'
              )
            ),
          ]
        )
    );
  }
}

// search bar at bottom of page for user input
class CardSearchBar extends StatefulWidget {
  final Function callback;
  CardSearchBar(this.callback);
  State<CardSearchBar> createState() => CardSearchBarState(callback);
}

class CardSearchBarState extends State<CardSearchBar> {
  String currentName = "";
  String superType = "";
  String subType = "";
  Function callback;

  CardSearchBarState(this.callback);

  void setSuper(String newSuper) {
    superType = newSuper;
    setState((){});
  }
  void setSub(String newSub) {
    subType = newSub;
    setState((){});
  }

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      //margin: EdgeInsets.all(8.0),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget> [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 80,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: TextField(
                      decoration: InputDecoration(
                        labelText: "Card Name",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (String value) {
                        currentName = value;
                        setState((){});
                      }
                  ),
                ),

                FlatButton(
                    child: Icon(Icons.search),
                    onPressed: () {
                      callback(currentName, superType, subType);
                    }
                ),
              ]
            ),

            CardTypeBar("Card Supertype", setSuper),
            CardTypeBar("Card Subtype", setSub),

          ]
      )
    );
  }
}

class CardTypeBar extends StatefulWidget {
  final String displayText;
  final Function callback;
  CardTypeBar(this.displayText, this.callback);
  State<CardTypeBar> createState() => CardTypeBarState(displayText, callback);
}

class CardTypeBarState extends State<CardTypeBar> {
  String currentInput = "";
  String displayText = "";
  Function setParentState;

  CardTypeBarState(this.displayText, this.setParentState);

  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: MediaQuery.of(context).size.width * 0.6,
      child: TextField(
          decoration: InputDecoration(
            labelText: "$displayText",
            border: OutlineInputBorder(),
          ),
          onChanged: (String value) {
            setParentState(value);
          }
      ),
    );
  }

}