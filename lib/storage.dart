import 'package:cloud_firestore/cloud_firestore.dart';
import 'cards.dart';

// singleton
class FirebaseDB {
  static final FirebaseDB _instance = FirebaseDB._internal();
  factory FirebaseDB() {
    return _instance;
  }
  FirebaseDB._internal();

  static FirebaseDB get instance {
    return _instance;
  }

  static String _uid;
  void setUID(String uid) {
    _uid = uid;
  }

  Future<List<Deck>> getDecks() async {
    print("getting decks");
    if (_uid == null) return List<Deck>(); // return empty deck
    CollectionReference colref = Firestore.instance.collection("decks");
    Map<String, dynamic> data = (await colref.document(_uid).get()).data;
    if (data == null) return List<Deck>();

    List<Deck> deckList = new List<Deck>();
    for (var deckInfo in data["decks"]) {
      List<MTGCard> cardList = new List<MTGCard>();

      for (var cardInfo in deckInfo["cards"]) {
        MTGCard curCard = MTGCard.fromMap(cardInfo);
        cardList.add(curCard);
      }
      deckList.add(Deck(deckInfo["name"], cardList, format: deckInfo["format"]));
    }
    return deckList;
  }

}