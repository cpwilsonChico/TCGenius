// holds data associated with a Magic the Gathering card
class MTGCard {
  String _imgPath;  // local directory or firebase uri
  String _name;     // title of card
  String _type;
  String _textBox;  // card flavor text / abilities
  String _set;      // which set this card comes from
  String _manaString;
  MTGManaType _manaCost;

  int getManaTotal() {
    return _manaCost.getSum();
  }

  MTGCard.fromMap(Map<String, String> info) {
    _name = info["name"];
    _textBox = info["oracle_text"];
    _set = info["set_name"];
    _manaString = info["mana_cost"];
    _type = info["type_line"];
    _set = info["set_name"];
  }

  String getName() {
    return _name;
  }

  String getOracleText(){
    return _textBox;
  }

  String getType(){
    return _type;
  }

  String getSet(){
    return _set;
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
