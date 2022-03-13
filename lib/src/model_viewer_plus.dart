import 'package:flutter/material.dart';

import 'model_viewer_plus_stub.dart'
    if (dart.library.io) 'model_viewer_plus_mobile.dart'
    if (dart.library.js) 'model_viewer_plus_web.dart';

/// Flutter widget for rendering interactive 3D models.
class ModelViewer extends StatefulWidget {
  ModelViewer(
      {Key? key,
      this.backgroundColor = Colors.transparent,
      required this.src,
      this.alt,
      this.ar,
      this.arModes,
      this.arScale,
      this.autoRotate,
      this.autoRotateDelay,
      this.autoPlay,
      this.cameraControls,
      this.iosSrc})
      : super(key: key);

  /// The background color for the model viewer.
  ///
  /// [Colors.transparent] by default.
  final Color backgroundColor;

  /// The URL or path to the 3D model. This parameter is required.
  /// Only glTF/GLB models are supported.
  ///
  /// The parameter value must conform to the following:
  ///
  /// - `http://` and `https://` for HTTP(S) URLs
  ///   (for example, `https://modelviewer.dev/shared-assets/models/Astronaut.glb`)
  ///
  /// - `file://` for local files
  ///
  /// - a relative pathname for Flutter app assets
  ///   (for example, `assets/MyModel.glb`)
  final String src;

  /// Configures the model with custom text that will be used to describe the
  /// model to viewers who use a screen reader or otherwise depend on additional
  /// semantic context to understand what they are viewing.
  final String? alt;

  /// Enable the ability to launch AR experiences on supported devices.
  final bool? ar;

  /// A prioritized list of the types of AR experiences to enable, if available.
  final List<String>? arModes;

  /// Controls the scaling behavior in AR mode in Scene Viewer. Set to "fixed"
  /// to disable scaling of the model, which sets it to always be at 100% scale.
  /// Defaults to "auto" which allows the model to be resized.
  final String? arScale;

  /// Enables the auto-rotation of the model.
  final bool? autoRotate;

  /// Sets the delay before auto-rotation begins. The format of the value is a
  /// number in milliseconds. The default is 3000.
  final int? autoRotateDelay;

  /// If this is true and a model has animations, an animation will
  /// automatically begin to play when this attribute is set (or when the
  /// property is set to true). The default is false.
  final bool? autoPlay;

  /// Enables controls via mouse/touch when in flat view.
  final bool? cameraControls;

  /// The URL to a USDZ model which will be used on supported iOS 12+ devices
  /// via AR Quick Look.
  final String? iosSrc;

  @override
  State<ModelViewer> createState() => ModelViewerState();
}
