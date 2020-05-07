import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class InheritedCameraProvider extends InheritedWidget {
  final CameraDescription camera;
  InheritedCameraProvider({Widget child, this.camera}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedCameraProvider oldWidget) {
    return camera != oldWidget.camera;
  }

  static InheritedCameraProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedCameraProvider>();
}
