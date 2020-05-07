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
    if (_uid == null) return List<Deck>(); // return empty deck
    CollectionReference colref = Firestore.instance.collection("users").document(_uid).collection("decks");
    List<DocumentSnapshot> docs = (await colref.getDocuments()).documents;
    List<Deck> decks = new List<Deck>();
    for (DocumentSnapshot doc in docs) {
      decks.add(Deck.fromMap(doc.data));
    }
    return decks;
  }

  // return error message if an error occurred, or "" if successful
  Future<String> saveDeck(Deck deck) async {
    if (_uid == null) return "Authorization failed. Failed to save deck.";
    DocumentReference docref = Firestore.instance.collection("users").document(_uid).collection("decks").document(deck.deckName);
    await docref.setData(deck.toMap());
    return "";
  }
}