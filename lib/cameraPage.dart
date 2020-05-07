import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'dart:io';

class CameraPage extends StatefulWidget {
  final CameraDescription camera;
  CameraPage(this.camera);
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final path = join(
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );
            await _controller.takePicture(path);
            await handleOCR(context, path);
          } catch (e) {
            print(e);
          }
        }
      )
    );
  }

  Future<void> handleOCR(BuildContext context, String path) async {
    File img = File(path);
    FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(img);
    TextRecognizer tr = FirebaseVision.instance.textRecognizer();
    VisionText vt = await tr.processImage(visionImage);
    List<List<String>> ocrData = List<List<String>>();

    int i = 0;
    for (TextBlock block in vt.blocks) {
      ocrData.add(new List<String>());
      int j = 0;
      for (TextLine line in block.lines) {
        //print("($i,$j) ${line.text}");
        j++;
        ocrData[i].add(line.text);
      }
      i++;
    }
    // assuming title is always at 0, 0
    Navigator.pop(context, ocrData[0][0]);
  }
}
