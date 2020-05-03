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
  int _dollarCost;
  int _centCost;

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
      print("Error when creating MTGCard from map: ${e.toString()}");
    }
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
    deckName = "New Deck";
    _nameToIndex = new Map<String, int>();
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
