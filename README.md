# 3D Model Viewer for Flutter

[![Project license](https://img.shields.io/badge/license-Public%20Domain-blue.svg)](https://unlicense.org)
![Dart compatibility](https://img.shields.io/badge/dart-2.8%20%7C%202.9-blue)
[![Pub package](https://img.shields.io/pub/v/model_viewer.svg)](https://pub.dev/packages/model_viewer)
[![Dartdoc reference](https://img.shields.io/badge/dartdoc-reference-blue.svg)](https://pub.dev/documentation/model_viewer/latest/)

This is a Flutter widget for rendering interactive 3D models in the
[glTF](https://www.khronos.org/gltf/) and
[GLB](https://wiki.fileformat.com/3d/glb/) formats.

The widget embeds Google's [`<model-viewer>`](https://modelviewer.dev)
web component in a [WebView](https://pub.dev/packages/webview_flutter).

## Prerequisites

- [Dart](https://dart.dev) 2.8+ and
  [Flutter](https://flutter.dev) 1.17+

- Android or iOS with
  [a recent browser version](https://modelviewer.dev/#section-browser-support)

## Installation

```yaml
dependencies:
  model_viewer: ^0.5.0
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

## Frequently Asked Questions

### Q: Why does the example app just show a blank screen?

**A:** Most likely, the platform browser version on your device or emulator is
too old and does not support the features that Model Viewer needs. For example,
the stock Chrome version on the Android 10 emulator is too old and will display
a blank screen; it must be upgraded from the Play Store in order to use this
package. See [google/model-viewer#1109][].

### Q: Why doesn't my 3D model load and/or render?

**A:** There are several reasons why your model URL could fail to load and
render:

1. It might not be possible to load the model URL due to [CORS][] security
   restrictions. The server hosting the model file *must* send appropriate
   CORS response headers for Model Viewer to be able to load the file.
   See [google/model-viewer#1015][].

2. It might not be possible to parse the provided glTF or GLB file.
   Some tools can produce invalid files when exporting glTF. Always
   run your model files through the [glTF Validator][] to check for this.

3. The platform browser might not support the features that Model Viewer
   needs. See [google/model-viewer#1109][].

[CORS]:                     https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
[glTF Validator]:           https://github.khronos.org/glTF-Validator/
[google/model-viewer#1015]: https://github.com/google/model-viewer/issues/1015
[google/model-viewer#1109]: https://github.com/google/model-viewer/issues/1109

### Q: How do I load a local asset instead of loading a URL?

**A:** This is not supported as yet. Due to CORS security restrictions, the
model file *cannot* be loaded from a `file://` URL. That means local assets
must be served from a `http://localhost:$PORT` web server. There are plans to
implement a built-in proxy that will enable this in a future version of this
package. (Do get in touch if your company would like to sponsor this work.)
