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
  int qty = 1;
  MTGManaType _manaCost;

  int getManaTotal() {
    return _manaCost.getSum();
  }

  MTGCard.fromMap(var info) {
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
      if (info.containsKey["image_uris"]) {
        _image_uris = info["image_uris"];
      }
    } catch (e) {
      print(e.toString());
    }
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


  Deck(this.deckName, this._cards, {this.deckSizeLimit, this.format});
  Deck.empty({this.deckSizeLimit, this.format}) {
    _cards = new List<MTGCard>();
    deckName = "New Deck";
  }

  int getDeckSize() {
    if (_cards == null) return 0;
    return _cards.length;
  }

  bool addCard(MTGCard newCard) {
    if (getDeckSize() == deckSizeLimit) return false;
    _cards.add(newCard);
    return true;
  }

  bool removeCard(MTGCard remCard) {
    return _cards.remove(remCard);
  }

  void clear() {
    _cards.clear();
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
