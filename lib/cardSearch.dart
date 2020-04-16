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

  void searchCallback(String term) {
    print("SEARCH CALLBACK");
    futureCards = data.getCardsByName(term);
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
    return Container(
      padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: Text(card.getName()),
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
  String currentInput = "";
  Function callback;

  CardSearchBarState(this.callback);

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      //margin: EdgeInsets.all(8.0),
      child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget> [
            SizedBox(
              height: 80,
              width: MediaQuery.of(context).size.width * 0.6,
              child: TextField(
                  decoration: InputDecoration(
                    labelText: "Card Name",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String value) {
                    currentInput = value;
                    setState((){});
                  }
              ),
            ),


            FlatButton(
                child: Icon(Icons.search),
                onPressed: () {
                  callback(currentInput);
                }
            ),

          ]
      )
    );
  }
}