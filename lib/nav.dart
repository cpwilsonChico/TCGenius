import 'package:flutter/material.dart';
import 'colors.dart';

class NavShelf extends StatelessWidget {
  final String name;
  final Icon icon;
  final String path;

  NavShelf(this.name, this.icon, this.path);

  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      leading: icon,
      onTap: () => Navigator.pushNamed(context, path),
    );
  }
}

class NavDrawer extends StatelessWidget {
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(0),
        children: <Widget>[
          DrawerHeader(
            child: Center(
              child: Text(
                  'TCGenius',
                  style: TextStyle(fontSize: 26, color: Colors.white),
              )
            ),
            decoration: BoxDecoration(
              color: TCG_BLUE,
            )
          ),
          NavShelf("Home", Icon(Icons.home), "/"),
          NavShelf("Decks", Icon(Icons.cloud), "/decks"),
          /*ListTile(
            title: Text("Decks"),
            leading: Icon(Icons.cloud),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DeckPage())
            )
          )*/
        ]
      )
    );
  }
}