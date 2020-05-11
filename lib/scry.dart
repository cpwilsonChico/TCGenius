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
      Map<String, dynamic> cardInfo = {};
      cardInfo["name"] = map['name'];
      cardInfo["mana_cost"] = map['mana_cost'];
      cardInfo["oracle_text"] = map['oracle_text'];
      cardInfo["set_name"] = map['set_name'];
      cardInfo["type_line"] = map['type_line'];
      cardInfo["image_uris"] = map["image_uris"]["normal"];
      cardInfo["rarity"] = map['rarity'];
      Map<String, dynamic> priceMap = map['prices'];
      String priceString = priceMap["usd"];
      if (priceString == null) priceString = "30000";
      priceString = priceString.replaceAll(",", "");
      print("price String: $priceString");
      cardInfo["price"] = double.tryParse(priceString);
      cards.add(MTGCard.fromMap(cardInfo));
    }

    print("API FINISH");
    print("# CARDS RETURNED: ${cards.length}");
    return cards;
  }

  Future<MTGCard> getCardFuzzy(String name) async {
    name = name.replaceAll(" ", "+");
    String url = "https://api.scryfall.com/cards/named?fuzzy=$name";

    http.Response responce;
    try {
      responce = await http.get(
          Uri.encodeFull(url),
          headers: {
            "Accept": "application/json"
          }
      );
    } catch (e) {
      print("http error: ${e.toString()}");
      return null;
    }

    var data;
    Map<String, dynamic> cardInfo = {};
    try {
      data = json.decode(responce.body);
      if (data.containsKey("status")) {
        return null;
      }
      Map<String, dynamic> images = data["image_uris"];
      cardInfo["name"] = data['name'];
      cardInfo["mana_cost"] = data['mana_cost'];
      cardInfo["oracle_text"] = data['oracle_text'];
      cardInfo["set_name"] = data['set_name'];
      cardInfo["type_line"] = data['type_line'];
      cardInfo["image_uris"] = images["normal"];
      cardInfo["rarity"] = data["rarity"];
      Map<String, dynamic> priceMap = data['prices'];
      String priceString = priceMap["usd"];
      if (priceString == null) priceString = "30000";
      priceString = priceString.replaceAll(",", "");
      cardInfo["price"] = double.tryParse(priceString);
    } catch (e) {
      print("json error: ${e.toString()}");
      return null;
    }
    return MTGCard.fromMap(cardInfo);
  }
}
