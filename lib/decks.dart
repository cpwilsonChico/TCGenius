import 'package:flutter/material.dart';
import 'nav.dart';

class DeckPage extends StatelessWidget {

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text("TCGenius"),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Text("Placeholder"),
            Text("Placeholder"),
            Text("Placeholder"),
          ]
        )
      )
    );
  }

}