import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Data{
  Future<List> getData() async{
    http.Response responce = await http.get(
        Uri.encodeFull("https://api.scryfall.com/cards/named?fuzzy=Aluren"),
        headers: {
          "Accept": "application/json"
        }
    );
    var data = json.decode(responce.body);//['data'];
    String cardName = data['name'];
    String manaCost = data['mana_cost'];
    String oracleText = data['oracle_text'];
    String setName = data['set_name'];
    print(cardName);
    print(manaCost);
    print(oracleText);
    print(setName);
    /*
    for(var ad = 0; ad < data.length; ad++){
      print(data[ad]['name']);
    }*/
    return null;//data;
  }
}
