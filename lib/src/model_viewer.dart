/* This is free and unencumbered software released into the public domain. */

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'html_builder.dart';

/// Flutter widget for rendering interactive 3D models.
class ModelViewer extends StatefulWidget {
  ModelViewer(
      {Key key,
      this.backgroundColor,
      @required this.src,
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
  /// The theme's [ThemeData.scaffoldBackgroundColor] by default.
  final Color backgroundColor;

  /// The URL to the 3D model. This parameter is required. Only glTF/GLB models
  /// are supported.
  final String src;

  /// Configures the model with custom text that will be used to describe the
  /// model to viewers who use a screen reader or otherwise depend on additional
  /// semantic context to understand what they are viewing.
  final String alt;

  /// Enable the ability to launch AR experiences on supported devices.
  final bool ar;

  /// A prioritized list of the types of AR experiences to enable, if available.
  final List<String> arModes;

  /// Controls the scaling behavior in AR mode in Scene Viewer. Set to "fixed"
  /// to disable scaling of the model, which sets it to always be at 100% scale.
  /// Defaults to "auto" which allows the model to be resized.
  final String arScale;

  /// Enables the auto-rotation of the model.
  final bool autoRotate;

  /// Sets the delay before auto-rotation begins. The format of the value is a
  /// number in milliseconds. The default is 3000.
  final int autoRotateDelay;

  /// If this is true and a model has animations, an animation will
  /// automatically begin to play when this attribute is set (or when the
  /// property is set to true). The default is false.
  final bool autoPlay;

  /// Enables controls via mouse/touch when in flat view.
  final bool cameraControls;

  /// The URL to a USDZ model which will be used on supported iOS 12+ devices
  /// via AR Quick Look.
  final String iosSrc;

  @override
  State<ModelViewer> createState() => _ModelViewerState();
}

class _ModelViewerState extends State<ModelViewer> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(final BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return WebView(
      initialUrl: 'about:blank',
      javascriptMode: JavascriptMode.unrestricted,
      initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
      onWebViewCreated: (final WebViewController webViewController) async {
        _controller.complete(webViewController);
        final String html = _buildHTML(themeData);
        final String contentBase64 =
            base64Encode(const Utf8Encoder().convert(html));
        await webViewController.loadUrl('data:text/html;base64,$contentBase64');
      },
      onPageStarted: (final String url) {
        print('>>>>>>>>>>>>>>>>> ModelViewer began loading: $url'); // DEBUG
      },
      onPageFinished: (final String url) {
        print('>>>>>>>>>>>>>>>>> ModelViewer finished loading: $url'); // DEBUG
      },
      onWebResourceError: (final WebResourceError error) {
        print('>>>>>>>>>>>>>>>>> ModelViewer failed to load: $error'); // DEBUG
      },
    );
  }

  String _buildHTML(final ThemeData themeData) {
    return HTMLBuilder.build(
      backgroundColor:
          this.widget.backgroundColor ?? themeData.scaffoldBackgroundColor,
      src: this.widget.src,
      alt: this.widget.alt,
      ar: this.widget.ar,
      arModes: this.widget.arModes,
      arScale: this.widget.arScale,
      autoRotate: this.widget.autoRotate,
      autoRotateDelay: this.widget.autoRotateDelay,
      autoPlay: this.widget.autoPlay,
      cameraControls: this.widget.cameraControls,
      iosSrc: this.widget.iosSrc,
    );
  }
}
