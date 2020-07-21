# 3D Model Viewer for Flutter

[![Project license](https://img.shields.io/badge/license-Public%20Domain-blue.svg)](https://unlicense.org)
![Dart compatibility](https://img.shields.io/badge/dart-2.8%20%7C%202.9-blue)
[![Pub package](https://img.shields.io/pub/v/model_viewer.svg)](https://pub.dev/packages/model_viewer)
[![Dartdoc reference](https://img.shields.io/badge/dartdoc-reference-blue.svg)](https://pub.dev/documentation/model_viewer/latest/)

This is a Flutter widget for rendering interactive 3D models in the
[glTF](https://www.khronos.org/gltf/) and
[GLB](https://wiki.fileformat.com/3d/glb/) formats.

## Prerequisites

- [Dart](https://dart.dev) 2.8+ and
  [Flutter](https://flutter.dev) 1.17+

## Installation

```yaml
dependencies:
  model_viewer: ^0.4.0
```

## Examples

### Importing the library

```dart
import 'package:model_viewer/model_viewer.dart';
```

### Creating a ModelViewer widget

```dart
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
```

## Screenshot

<img alt="Screenshot of astronaut model" src="https://raw.githubusercontent.com/drydart/model_viewer.dart/master/example/flutter_01.png" width="480"/>
