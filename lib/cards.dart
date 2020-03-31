// holds data associated with a Magic the Gathering card
class MTGCard {
  String _imgPath;  // local directory or firebase uri
  String _name;     // title of card
  String _type;
  String _textBox;  // card flavor text / abilities
  String _set;      // which set this card comes from
  MTGManaType _manaCost;

  int getManaTotal() {
    return _manaCost.getSum();
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
