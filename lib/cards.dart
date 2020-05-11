import 'dart:convert';
import 'package:flutter/material.dart';

enum Rarity {COMMON, UNCOMMON, RARE, MYTHIC, TIMESHIFTED}

// holds data associated with a Magic the Gathering card
class MTGCard {
  String _imgPath;  // local directory or firebase uri
  String _name;     // title of card
  String _supertype;
  String _subtype;
  String _textBox;  // card flavor text / abilities
  String _set;      // which set this card comes from
  String _manaString;
  String _image_uris;
  Rarity _rarity;
  double _price;


  int qty = 1;
  MTGManaType _manaCost;
  int _dollarCost;
  int _centCost;

  int getManaTotal() {
    return _manaCost.getSum();
  }

  MTGCard.fromMap(var info) {
    print(info);
    try {
      _name = info["name"];
      _textBox = info["oracle_text"];
      _set = info["set_name"];
      _manaString = info["mana_cost"];
      _supertype = info["type_line"];
      // firebase contains these, Scryfall does not
      if (info.containsKey("qty")) {
        qty = info["qty"];
      }
      if (info.containsKey("image_uris")) {
        _image_uris = info["image_uris"];
      }
      if (info.containsKey("rarity")) {
        decideRarity(info["rarity"]);
      }
      if (info.containsKey("price")) {
        _price = info["price"];
      }
    } catch (e) {
      print("Error when creating MTGCard from map: ${e.toString()}");
    }
  }

  MTGCard.copy(MTGCard other) {
    _name = other.getName();
    _textBox = other._textBox;
    _set = other.getSet();
    _manaString = other._manaString;
    _supertype = other._supertype;
    qty = other.qty;
    _price = other.getPrice();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': _name,
      'oracle_text': _textBox,
      'set_name': _set,
      'mana_cost': _manaString,
      'type_line': _supertype,
      //'subtype': _subtype,
      'qty': qty,
      'price': _price,
    };
  }

  void decideRarity(String text) {
    switch (text) {
      case "common":
        _rarity = Rarity.COMMON;
        break;
      case "uncommon":
        _rarity = Rarity.UNCOMMON;
        break;
      case "rare":
        _rarity = Rarity.RARE;
        break;
      case "mythic":
        _rarity = Rarity.MYTHIC;
        break;
      case "timeshifted":
        _rarity = Rarity.TIMESHIFTED;
        break;
      default:
        _rarity = Rarity.COMMON;
    }
  }

  Color getRarityColor() {
    switch (_rarity) {
      case Rarity.COMMON:
        return Colors.black;
      case Rarity.UNCOMMON:
        return Color.fromARGB(0xFF, 0xC0, 0xC0, 0xC0);
      case Rarity.RARE:
        return Color.fromARGB(0xFF, 0xD4, 0xAF, 0x37);
      case Rarity.MYTHIC:
        return Colors.red;
      case Rarity.TIMESHIFTED:
        return Colors.blue;
      default:
        return Colors.black;
    }
  }

  double getPrice() {
    return _price;
  }

  int getQty() {
    return qty;
  }

  String getName() {
    return _name;
  }
  String getSuperType() {
    return _supertype;
  }

  String getOracleText(){
    return _textBox;
  }

  String getSet(){
    return _set;
  }

  String getImage(){
    return _image_uris;
  }
  String getManaString() {
    return _manaString;
  }

  void addOne() => qty++;
  void subtractOne() {
    if (qty > 1) qty--;
  }

}

class MTGManaType {
  int colorless;
  int black;
  int white;
  int red;
  int blue;
  int green;
  int generic;

  MTGManaType({this.colorless=0, this.white=0, this.blue=0,
    this.red=0, this.green=0, this.black=0, this.generic=0,
  });

  int getSum() {
    return colorless + black + white + red + green + blue + green + generic;
  }
}

class Deck {
  List<MTGCard> _cards;
  int deckSizeLimit = 999;
  String deckName;
  String format = "";
  Map<String, int> _nameToIndex;


  Deck(this.deckName, this._cards, {this.deckSizeLimit, this.format}) {
    _nameToIndex = new Map<String, int>();
  }
  Deck.empty({this.deckSizeLimit, this.format}) {
    _cards = new List<MTGCard>();
    _nameToIndex = new Map<String, int>();
  }

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> cardsToMap = List<Map<String,dynamic>>();
    for (MTGCard card in _cards) {
      cardsToMap.add(card.toMap());
    }
    return {
      'name': deckName,
      'format': format,
      'cards': cardsToMap,
    };
  }

  Deck.fromMap(Map<String, dynamic> map) {
    deckName = map['name'];
    format = map['format'];
    List<MTGCard> cards = new List<MTGCard>();
    List<dynamic> cardMaps = map['cards'];
    for (dynamic cardMap in cardMaps) {
      cards.add(MTGCard.fromMap(cardMap));
    }
    _cards = cards;

    _nameToIndex = new Map<String, int>();
    for (int i = 0; i < _cards.length; i++) {
      _nameToIndex[_cards[i].getName()] = i;
    }
  }

  Deck.copy(Deck other) {
    deckSizeLimit = other.deckSizeLimit;
    deckName = other.deckName;
    format = other.format;
    _cards = new List<MTGCard>();
    _nameToIndex = new Map<String, int>();
    for (int i = 0; i < other.list.length; i++) {
      _cards.add(MTGCard.copy(other.list[i]));
      _nameToIndex[other.list[i].getName()] = i;
    }
  }


  List<MTGCard> get list {
    return _cards;
  }

  int getDeckSize() {
    if (_cards == null) return 0;
    int sum = 0;
    for (MTGCard card in _cards) {
      sum += card.qty;
    }
    return sum;
  }

  // inserts card at front, updates index map
  bool addCard(MTGCard newCard) {
    if (getDeckSize() == deckSizeLimit) return false;

    String name = newCard.getName();
    if (_nameToIndex.containsKey(name)) {
      int index = _nameToIndex[name];
      _cards[index].qty += newCard.qty;
    } else {
      _cards.insert(0, newCard);
      for (String id in _nameToIndex.keys) {
        _nameToIndex[id]++;
      }
      _nameToIndex[name] = 0;
    }
    return true;
  }

  // removes card from list, updates index map
  bool removeCard(MTGCard remCard) {
    String name = remCard.getName();
    if (!_nameToIndex.containsKey(name)) {
      return false;
    }
    int index = _nameToIndex[name];
    for (String id in _nameToIndex.keys) {
      if (_nameToIndex[id] > index) {
        _nameToIndex[id]--;
      }
    }
    _nameToIndex.remove(name);
    _cards.removeAt(index);
    return true;
  }

  void clear() {
    _cards.clear();
    _nameToIndex.clear();
  }

  double getTotalPrice() {
    double sum = 0;
    for (MTGCard card in _cards) {
      print("price: ${card.getPrice()}");
      print("qty: ${card.getQty()}");
      sum += card.getPrice() * card.getQty();
    }
    return sum;
  }

  Map<String, List<MTGCard>> getAllCardsBySuperType() {
    Map<String, List<MTGCard>> map = new Map<String, List<MTGCard>>();
    for (int i = 0; i < _cards.length; i++) {
      String stype = _cards[i].getSuperType();
      if (!map.containsKey(stype)) {
        map[stype] = new List<MTGCard>();
      }
      map[stype].add(_cards[i]);
    }

    return map;
  }
}
