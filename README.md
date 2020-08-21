# 3D Model Viewer for Flutter

[![Project license](https://img.shields.io/badge/license-Public%20Domain-blue.svg)](https://unlicense.org)
[![Dart compatibility](https://img.shields.io/badge/dart-2.8%2B-blue)](https://pub.dev/packages/model_viewer)
[![Pub package](https://img.shields.io/pub/v/model_viewer.svg)](https://pub.dev/packages/model_viewer)
[![Dartdoc reference](https://img.shields.io/badge/dartdoc-reference-blue.svg)](https://pub.dev/documentation/model_viewer/latest/)

This is a [Flutter](https://flutter.dev) widget for rendering interactive
3D models in the [glTF](https://www.khronos.org/gltf/) and
[GLB](https://wiki.fileformat.com/3d/glb/) formats.

The widget embeds Google's [`<model-viewer>`](https://modelviewer.dev)
web component in a [WebView](https://pub.dev/packages/webview_flutter).

## Screenshot

<img alt="Screenshot of astronaut model" src="https://raw.githubusercontent.com/drydart/model_viewer.dart/master/example/flutter_01.png" width="480"/>

## Prerequisites

- [Dart](https://dart.dev) 2.8+ and [Flutter](https://flutter.dev) 1.17+

## Compatibility

Android and iOS, with [a recent system browser version](https://modelviewer.dev/#section-browser-support).

## Installation

### `pubspec.yaml`

```yaml
dependencies:
  model_viewer: ^0.8.1
```

### `AndroidManifest.xml` (Android 9+ only)

To use this widget on Android 9+ devices, your app must be permitted to make
an HTTP connection to `http://localhost:XXXXX`. Android 9 (API level 28)
changed the default for [`android:usesCleartextTraffic`] from `true` to
`false`, so you will need to configure your app's
`android/app/src/main/AndroidManifest.xml` as follows:

```diff
--- a/example/android/app/src/main/AndroidManifest.xml
+++ b/example/android/app/src/main/AndroidManifest.xml
@@ -8,7 +8,8 @@
     <application
         android:name="io.flutter.app.FlutterApplication"
         android:label="model_viewer_example"
-        android:icon="@mipmap/ic_launcher">
+        android:icon="@mipmap/ic_launcher"
+        android:usesCleartextTraffic="true">
         <activity
             android:name=".MainActivity"
             android:launchMode="singleTop"
```

This does not affect Android 8 and earlier. See [#7] for more information.

### `Info.plist` (iOS only)

To use this widget on iOS, you need to opt-in to the embedded views preview
by adding a boolean property to your app's `ios/Runner/Info.plist` file, with
the key `io.flutter.embedded_views_preview` and the value `YES`:

```xml
<key>io.flutter.embedded_views_preview</key>
<true/>
```

## Features

- Renders glTF and GLB models. (Also, [USDZ] models on iOS 12+.)

- Supports animated models, with a configurable auto-play setting.

- Optionally supports launching the model into an [AR] viewer.

- Optionally auto-rotates the model, with a configurable delay.

- Supports a configurable background color for the widget.

[USDZ]: https://graphics.pixar.com/usd/docs/Usdz-File-Format-Specification.html
[AR]:   https://en.wikipedia.org/wiki/Augmented_reality

## Examples

### Importing the library

```dart
import 'package:model_viewer/model_viewer.dart';
```

### Creating a `ModelViewer` widget

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

### Loading a bundled Flutter asset

```dart
class MyApp extends StatelessWidget {
// ...
          src: 'assets/MyModel.glb',
// ...
}
```

### Loading a model from the file system

```dart
class MyApp extends StatelessWidget {
// ...
          src: 'file:///path/to/MyModel.glb',
// ...
}
```

### Loading a model from the web

```dart
class MyApp extends StatelessWidget {
// ...
          src: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
// ...
}
```

Note that due to browsers' [CORS] security restrictions, the model file
*must* be served with a `Access-Control-Allow-Origin: *` HTTP header.

## Frequently Asked Questions

### Q: Why do I get the error `net::ERR_CLEARTEXT_NOT_PERMITTED`?

You didn't configure your `AndroidManifest.xml` as per the installation
instructions earlier in this document. See also [#7].

### Q: Why does the example app just show a blank screen?

**A:** Most likely, the platform browser version on your device or emulator is
too old and does not support the features that Model Viewer needs. For example,
the stock Chrome version on the Android 10 emulator is too old and will display
a blank screen; it must be upgraded from the Play Store in order to use this
package. See [google/model-viewer#1109].

### Q: Why doesn't my 3D model load and/or render?

**A:** There are several reasons why your model URL could fail to load and
render:

1. It might not be possible to load the model URL due to [CORS] security
   restrictions. The server hosting the model file *must* send appropriate
   CORS response headers for Model Viewer to be able to load the file.
   See [google/model-viewer#1015].

2. It might not be possible to parse the provided glTF or GLB file.
   Some tools can produce invalid files when exporting glTF. Always
   run your model files through the [glTF Validator] to check for this.

3. The platform browser might not support the features that Model Viewer
   needs. See [google/model-viewer#1109].

[#7]:                       https://github.com/drydart/model_viewer.dart/issues/7
[CORS]:                     https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS
[glTF Validator]:           https://github.khronos.org/glTF-Validator/
[google/model-viewer#1015]: https://github.com/google/model-viewer/issues/1015
[google/model-viewer#1109]: https://github.com/google/model-viewer/issues/1109
[`android:usesCleartextTraffic`]: https://developer.android.com/guide/topics/manifest/application-element#usesCleartextTraffic
