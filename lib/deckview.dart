import 'package:flutter/material.dart';
import 'cards.dart';
import 'nav.dart';
import 'scry.dart';
import 'storage.dart';
import 'cameraPage.dart';
import 'package:camera/camera.dart';
import 'cameraProvider.dart';

// widget for viewing / editing a deck
class DeckBuilder extends StatefulWidget {
  final Deck deck;
  final bool isNew;
  final Function refreshParent;    // callback to refresh view of deck list
  final CameraDescription camera;
  DeckBuilder({this.deck, this.isNew, this.refreshParent, this.camera});
  State<DeckBuilder> createState() => DeckBuilderState(deck: deck, isNew: isNew, refreshParent: refreshParent);
}

class DeckBuilderState extends State<DeckBuilder> {
  DeckBuilderState({this.deck, this.isNew=false, this.refreshParent}) {
    dirty = isNew;
  }

  Deck deck;
  int newCardQty;
  String newCardName;
  bool isNew;
  bool dirty;
  final Function refreshParent;   // callback to refresh view of deck list

  @override
  void initState() {
    super.initState();
    if (deck == null) deck = new Deck.empty();
  }

  Widget build(BuildContext context) {
    String titleText = isNew ? "New Deck" : deck.deckName;

    return WillPopScope(
      onWillPop: () async { return await confirmDiscard(context);},
      child: Scaffold(
          //drawer: NavDrawer(),
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
              title: Text("$titleText"),
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      showCancelDialog(context);
                    }
                ),
                SaveIcon(saveDeck),
              ]
          ),
          body: ListView(
            //mainAxisSize: MainAxisSize.min,
              shrinkWrap: true,
              children: <Widget>[
                DeckInfoWidget(setDeckName, isNew, deckName: deck.deckName, deckPrice: "\$" + deck.getTotalPrice().toStringAsFixed(2)),
                FormatSelector(setFormat, deck),
                CardInput(setNewQty, setName, addCard, scanCard),
                DeckView(deck, deleteCard, triggerState),
              ]
          )
      ),
    );
  }

  Future<bool> confirmDiscard(BuildContext context) async {
    // if there are no changes, dont prompt
    if (!dirty) {
      return true;
    }
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
              title: Text("Changes not saved"),
              content: Text("Are you sure you want to discard your changes?"),
              actions: <Widget>[
                FlatButton(
                  child: Text("GO BACK"),
                  onPressed: () => Navigator.pop(context, false),
                ),
                FlatButton(
                  child: Text("DISCARD", style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.pop(context, true);
                  }
                )
              ]
          );
        }
    );
  }

  void saveDeck(BuildContext context) async {
    if (deck.deckName == null ? true : deck.deckName.length < 1) {
      showDeckErrorDialog("Please give this deck a name.");
      return;
    }
    if (deck.getDeckSize() < 1) {
      showDeckErrorDialog("This deck is empty. Add some cards!");
      return;
    }

    String resultMsg = await FirebaseDB.instance.saveDeck(deck);

    if (resultMsg == null) {
      showDeckErrorDialog("Failed to save deck.");
    } else if (resultMsg != "") {
      showDeckErrorDialog(resultMsg);
    } else {
      refreshParent();
      SnackBar snack = SnackBar(
        content: Text("Deck saved!", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
        duration: Duration(seconds: 2),
      );
      Scaffold.of(context).showSnackBar(snack);
      dirty = false;
    }
  }

  void showDeckErrorDialog(String msg) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text("Deck Error"),
              content: Text("$msg"),
              actions: <Widget>[
                FlatButton(
                  child: Text("OK"),
                  onPressed: () => Navigator.pop(context),
                ),
              ]
          );
        }
    );
  }


  void showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Clear Deck"),
          content: Text("Are you sure you want to remove all cards from this deck?"),
          actions: <Widget>[
            FlatButton(
              child: Text("No"),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              child: Text("Yes"),
              onPressed: () {
                deck.clear();
                setState((){});
                Navigator.pop(context);
              }
            )
          ]
        );
      }
    );
  }

  // callback, passed to FormatSelector
  void setFormat(String str) {
    deck.setFormat(str);
    dirty = true;
    setState((){});
  }

  // callback, passed to CardInput
  void setNewQty(int qty) {
    newCardQty = qty;
    if (newCardQty == null) newCardQty = 1;
    if (newCardQty < 1) newCardQty = 1;
    if (newCardQty > 9) newCardQty = 9;
    dirty = true;
    setState((){});
  }

  // callback, passed to CardInput
  void setName(String newName) {
    newCardName = newName;
    dirty = true;
    setState((){});
  }

  // callback, passed to DeckInfoWidget
  void setDeckName(String newName) {
    deck.deckName = newName;
    dirty = true;
    setState((){});
  }

  // callback, passed to CardInput
  Future<void> scanCard(BuildContext context) async {
    newCardName = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraPage(
        InheritedCameraProvider.of(context).camera,
      ))
    );
    if (newCardName != null) {
      addCard();
    }
  }

  // callback, passed to CardInput
  Future<void> addCard() async {
    if (newCardName == null) return;
    Data api = Data();
    MTGCard card = await api.getCardFuzzy(newCardName);
    if (card == null) {
      showFailureDialog();
      return;
    }
    if (newCardQty == null) newCardQty = 1;
    card.qty = newCardQty;
    deck.addCard(card);
    dirty = true;
    setState((){});
  }

  // callback, passed down to CardWidgets
  void deleteCard(MTGCard card) async {
    bool shouldDelete = await showDeleteDialog(card.getName());
    if (shouldDelete == null ? true : !shouldDelete) return;
    deck.removeCard(card);
    dirty = true;
    setState((){});
  }

  // callback, passed down to CardWidgets
  void triggerState() {
    dirty = true;
    setState((){});
  }

  Future<bool> showDeleteDialog(String cardName) async {
    return await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text("Delete card '$cardName'?"),
              actions: <Widget>[
                FlatButton(
                  child: Text("CANCEL"),
                  onPressed: () => Navigator.pop(context, false),
                ),
                FlatButton(
                  child: Text("OK"),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ]
          );
        }
    );
  }

  void showFailureDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text("Failed to add card '$newCardName'"),
              actions: <Widget>[
                FlatButton(
                  child: Text("OK"),
                  onPressed: () => Navigator.pop(context),
                ),
              ]
          );
        }
    );
  }
}

// helper class so that Scaffold.of() can be used (error if embedded into DeckBuilder)
class SaveIcon extends StatelessWidget {
  final Function saveDeck;    // callback from DeckBuilder
  SaveIcon(this.saveDeck);

  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.save),
      onPressed: () =>
          saveDeck(context),
    );
  }
}

class FormatSelector extends StatelessWidget {
  final Function setFormat;
  final Deck deck;
  FormatSelector(this.setFormat, this.deck);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.0),
      padding: EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 2.0),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border.all(width: 1),
        borderRadius: BorderRadius.circular(12.0),
        color: Color.fromARGB(255, 30, 30, 30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text("Format:"),
          DropdownButton<String>(
            value: deck.getFormat(),
            elevation: 16,
            underline: SizedBox(height: 0),
            icon: Icon(Icons.arrow_downward),
            items: Deck.getAllFormats().map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String val) {
              setFormat(val);
            },
          ),
        ]
      ),
    );
  }
}


// shows the deck, split into categories
class DeckView extends StatelessWidget {
  final Deck deck;
  final Function deleteCard;    // callback, passed down to CardCategory by DeckBuilderState
  final Function triggerState;  // callback, passed down to CardCategory by DeckBuilderState
  DeckView(this.deck, this.deleteCard, this.triggerState);

  Widget build(BuildContext context) {
    Map<String, List<MTGCard>> map = deck.getAllCardsBySuperType();
    List<List<MTGCard>> lists = new List<List<MTGCard>>();
    map.forEach((k,v) => lists.add(map[k]));

    List<CardCategory> cardCats = new List<CardCategory>();
    for (List<MTGCard> list in lists) {
      cardCats.add(CardCategory(list, deleteCard, triggerState));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: cardCats,
    );
  }
}

class CardInput extends StatelessWidget {
  final Function setQty;  // callback for qty input
  final Function setName; // callback for name input
  final Function addCard; // callback for adding new card to deck
  final Function scanCard;// callback for scanning a card with camera

  CardInput(this.setQty, this.setName, this.addCard, this.scanCard);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.0),
      padding: EdgeInsets.all(10.0),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border.all(width: 1),
        borderRadius: BorderRadius.circular(12.0),
        color: Color.fromARGB(255, 30, 30, 30),
      ),
      //height: 250,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[

          // quantity input field
          SizedBox(
            width: 60,
            child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                  labelText: "Qty",
                ),
                initialValue: "1",
                onChanged: (String newVal) {
                  int qty = int.tryParse(newVal);
                  setQty(qty);
                }
            ),
          ),

          // card name input field
          SizedBox(
            width: 150,
            child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                  labelText: "Card Name",
                ),
                onChanged: (String newVal) {
                  setName(newVal);
                }
            ),
          ),

          // "Plus" icon to add a new card
          Material(
            color: Color.fromARGB(255, 30, 30, 30),
            child: Center(
              child: Ink(
                  decoration: ShapeDecoration(
                    shape: CircleBorder(),
                    color: Colors.lightBlue,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: addCard,
                  )
              ),
            ),
          ),

          // "Camera" icon to scan a real MTG card
          Material(
            color: Color.fromARGB(255, 30, 30, 30),
            child: Center(
              child: Ink(
                decoration: ShapeDecoration(
                  shape: CircleBorder(),
                  color: Colors.lightBlue,
                ),
                child: IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: () => scanCard(context),
                )
              )
            )
          )

        ]
      )
    );
  }
}


class CardWidget extends StatelessWidget {
  final MTGCard card;
  final Function deleteCard;    // callback to delete card
  final Function triggerState;  // callback to trigger state update of deck builder
  CardWidget(this.card, this.deleteCard, this.triggerState);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(card.getName()),
      leading: Text("${card.getQty()}"),
      children: <Widget>[
        Text(card.getOracleText()),
        ButtonBar(
          children: <Widget>[
            FlatButton(
              child: Text("DELETE", style: TextStyle(color: Colors.red)),
              onPressed: () => deleteCard(card),
            ),
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                card.subtractOne();
                triggerState();
              }
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                card.addOne();
                triggerState();
              }
            ),
          ]
        )
      ]
    );
  }
}

class CardCategory extends StatelessWidget {
  final List<MTGCard> list;
  final Function deleteCard;    // callback, passed down from DeckView to CardWidget
  final Function triggerState;  // callback, passed down from DeckView to CardWidget
  CardCategory(this.list, this.deleteCard, this.triggerState);

  @override
  Widget build(BuildContext context) {
    if (list == null ? true : list.length == 0) {
      return SizedBox(height: 0);
    }
    int numCards = 0;
    for (int i = 0; i < list.length; i++) {
      numCards += list[i].getQty();
    }

    List<CardWidget> cardList = new List<CardWidget>();
    for (MTGCard card in list) {
      cardList.add(CardWidget(card, deleteCard, triggerState));
    }

    return Container(
      padding: EdgeInsets.fromLTRB(6, 0, 0, 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              "$numCards   ${list[0].getSuperType()}",
              style: TextStyle(fontSize: 18),
            ),
          ),
          Flexible(
            //fit: FlexFit.loose,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: cardList,
            )
          ),
        ]
      )
    );
  }
}

// displays deck name and price
// allows changing deck name if this deck is new
class DeckInfoWidget extends StatelessWidget {
  final Function setDeckName;    // callback to set deck name from text input
  final bool isNew;
  final String deckName;
  final String deckPrice;
  DeckInfoWidget(this.setDeckName, this.isNew, {this.deckName, this.deckPrice});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(4, 4, 4, 0),
      padding: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        border: Border.all(width: 1),
        borderRadius: BorderRadius.circular(12.0),
        color: Color.fromARGB(255, 30, 30, 30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: Visibility(
              visible: isNew,
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                  labelText: "Deck Name",
                ),
                maxLength: 32,
                onChanged: (String newVal) {
                  setDeckName(newVal);
                },
              ),
              replacement: Text(
                deckName == null ? "" : deckName,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),

          Text(deckPrice),
        ]
      )
    );
  }
}


