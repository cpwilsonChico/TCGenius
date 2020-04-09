import 'dart:convert';
import 'package:http/http.dart' as http;

class Scryer {

  static getFlavorText(String cardName) async {
    var client = new http.Client();
    var cardinfo = await client.get("https://api.scryfall.com/cards/search?q='$cardName'");
    var cardbody = cardinfo.body;
    var jsonInfo = jsonDecode(cardbody);
    print(cardinfo.body);
  }
}