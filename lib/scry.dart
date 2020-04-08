import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Data{
  Future<List> getData() async{
    http.Response responce = await http.get(
        Uri.encodeFull("https://api.scryfall.com/cards/search?order=cmc&q=c:red+pow=3"),
        headers: {
          "Accept": "application/json"
        }
    );
    List data = json.decode(responce.body)['data'];
    for(var ad = 0; ad < data.length; ad++){
      print(data[ad]['name']);
    }
    return data;
  }
}
