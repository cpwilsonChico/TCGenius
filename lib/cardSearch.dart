import 'package:flutter/material.dart';
import 'cards.dart';
import 'scry.dart';

class CardSearch extends StatefulWidget {

  @override
  State<CardSearch> createState() => SearchState();
}

class SearchState extends State<CardSearch> {

  Data data = new Data();
  Future<List<MTGCard>> futureCards;

  @override
  void initState() {
    super.initState();
    futureCards = data.getCardsByName("Cat");
  }

  Widget build(BuildContext context) {
    return FutureBuilder<List<MTGCard>>(
      future: futureCards,
      builder: (BuildContext cont, AsyncSnapshot<List<MTGCard>> snapshot) {
        if (snapshot.hasData) {
          var cards = snapshot.data;

          return ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              return Text(cards[index].getName());
            }
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