import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cards.dart';

class Data{
  Future<List<MTGCard>> getCardsByName(String cardName, {String cardSuperType = "", String cardSubType = ""}) async{
    print("API");
    print("cardname: $cardName");
    String uri = "https://api.scryfall.com/cards/search?order=name&q=$cardName";
    cardSuperType = cardSuperType.toLowerCase();
    cardSubType = cardSubType.toLowerCase();
    if (cardSuperType != "") {
      uri += "+t=$cardSuperType";
    }
    if (cardSubType != "") {
      uri += "+t=$cardSubType";
    }
    print("URI: $uri");

    http.Response responce = await http.get(
        //Uri.encodeFull("https://api.scryfall.com/cards/search?order=name&q=$cardName"),
        Uri.encodeFull(uri),
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
      cardInfo["type_line"] = map['type_line'];
      cards.add(MTGCard.fromMap(cardInfo));
    }

    print("API FINISH");
    print("# CARDS RETURNED: ${cards.length}");
    return cards;
  }
}
