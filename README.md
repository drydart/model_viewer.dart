3D Model Viewer for Flutter
===========================

[![Project license](https://img.shields.io/badge/license-Public%20Domain-blue.svg)](https://unlicense.org)
[![Pub package](https://img.shields.io/pub/v/model_viewer.svg)](https://pub.dev/packages/model_viewer)
[![Dartdoc reference](https://img.shields.io/badge/dartdoc-reference-blue.svg)](https://pub.dev/documentation/model_viewer/latest/)
[![Travis CI build status](https://img.shields.io/travis/drydart/model_viewer.dart/master.svg)](https://travis-ci.org/drydart/model_viewer.dart)

This is a Flutter widget for rendering interactive 3D models in the
[glTF](https://www.khronos.org/gltf/) and
[GLB](https://wiki.fileformat.com/3d/glb/) formats.

Prerequisites
-------------

- [Dart](https://dart.dev) 2.8.1+

- [Flutter](https://flutter.dev) 1.17.0+

Installation
------------

    dependencies:
      model_viewer: ^0.1.0

Examples
--------

### Importing the library

    import 'package:model_viewer/model_viewer.dart';

### Creating a ModelViewer widget

    class MyApp extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
        return MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: Text("Model Viewer")),
            body: ModelViewer(
              src: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
              alt: "A 3D model of an astronaut",
              ar: true,
              autoRotate: true,
              cameraControls: true,
            ),
          ),
        );
      }
    }
