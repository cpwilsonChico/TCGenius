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
    //futureCards = data.getCardsByName("Cat");
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
        CardListDisplay(futureCards),
        CardSearchBar(searchCallback),
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
        child: ListTile(
            title: Text(card.getName()
            ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[

                Text(
                  card.getType() ?? 'Something went wrong try again later'
                ),
                //Text(' '),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment:  MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      card.getSet() ?? 'Something went wrong try again later'
                    ),
                  ],
                ),
                Text(
                    card.getOracleText() ?? 'Something went wrong try again later'
                ),

              ],
              //card.getOracleText() ?? 'Something went wrong try again later'
          )
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