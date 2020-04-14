import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cards.dart';

class Data{
  Future<List<MTGCard>> getCardsByName(String cardName) async{
    http.Response responce = await http.get(
        Uri.encodeFull("https://api.scryfall.com/cards/search?order=name&q=$cardName"),
        headers: {
          "Accept": "application/json"
        }
    );

    // loop through all data returned by REST, build list of MTGCard objects
    var data = json.decode(responce.body)['data'];
    List<MTGCard> cards = [];
    for (var map in data) {
      Map<String, String> cardInfo = {};
      cardInfo["name"] = map['name'];
      cardInfo["mana_cost"] = map['mana_cost'];
      cardInfo["oracle_text"] = map['oracle_text'];
      cardInfo["set_name"] = map['set_name'];
      cards.add(MTGCard.fromMap(cardInfo));
    }

    return cards;
  }
}
