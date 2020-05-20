/* This is free and unencumbered software released into the public domain. */

import 'package:flutter/material.dart';
import 'package:model_viewer/model_viewer.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Model Viewer"),
        ),
        body: ModelViewer(
          backgroundColor: Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
          src: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
          alt: 'A 3D model of an astronaut',
          ar: true,
          autoRotate: true,
          cameraControls: true,
        ),
      ),
    );
  }
}
