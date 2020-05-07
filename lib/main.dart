import 'package:flutter/material.dart';
import 'nav.dart';
import 'deckPage.dart';
import 'package:tcgenius/scry.dart';
import 'package:provider/provider.dart';
import 'cardSearch.dart';
import 'authPage.dart';
import 'auth.dart';
import 'cameraProvider.dart';
import 'cameraPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:camera/camera.dart';
//import 'dart:async';
//import 'dart:convert';
//import 'package:http/http.dart' as http;

void main() async {
  // setup camera
  WidgetsFlutterBinding.ensureInitialized();
  final List<CameraDescription> cameras = await availableCameras();
  final CameraDescription firstCam = cameras.first;

  runApp(
    InheritedCameraProvider(
      child: MyApp(),
      camera: firstCam,
    )
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<FirebaseUser>.value(
      value: Authenticator().userStream,
      child: MaterialApp(
        title: 'TCGenius',
        initialRoute: "/",
        routes: {
          "/": (context) => AuthPage(),
          "/home": (context) => HomePage("TCGenius"),
          //"/camera": (context) => CameraPage(InheritedCameraProvider.of(context).camera),
          //"/": (context) => HomePage("TCGenius"),
          "/decks": (context) => DeckPage(),
        },
        theme: ThemeData.dark(),
        //theme: ThemeData(
         // primarySwatch: Colors.blue,
        //),
      ),
    );
  }
}

class HomePage extends StatelessWidget {

  final String title;
  final Data data = new Data();

  HomePage(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text("TCGenius"),
      ),
      body: Center(
        child: CardSearch(),
      )
    );
  }
}
