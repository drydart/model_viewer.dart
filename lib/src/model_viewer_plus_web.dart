/* This is free and unencumbered software released into the public domain. */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'html_builder.dart';

import 'dart:ui' as ui;
import 'dart:html';

/// Flutter widget for rendering interactive 3D models.
class ModelViewer extends StatefulWidget {
  ModelViewer(
      {Key? key,
      this.backgroundColor = Colors.white,
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
  /// The theme's [ThemeData.scaffoldBackgroundColor] by default.
  final Color backgroundColor;

  /// The URL or path to the 3D model. This parameter is required.
  /// Only glTF/GLB models are supported.
  ///
  /// The parameter value must conform to the following:
  ///
  /// - `http://` and `https://` for HTTP(S) URLs
  ///   (for example, `https://modelviewer.dev/shared-assets/models/Astronaut.glb`)
  ///
  /// - `file://` for local files，but not avaliable for Web
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
  State<ModelViewer> createState() => _ModelViewerState();
}

class _ModelViewerState extends State<ModelViewer> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    generateModelViewerHtml();
  }

  /// To generate the HTML code for using the model viewer.
  void generateModelViewerHtml() async {
    final htmlTemplate = await rootBundle
        .loadString('packages/model_viewer_plus/etc/assets/template.html');
    // allow to use elements
    final NodeValidator _validator = NodeValidatorBuilder.common()
      ..allowElement('meta',
          attributes: ['name', 'content'], uriPolicy: _AllowUriPolicy())
      ..allowElement('style')
      ..allowElement('script',
          attributes: ['src', 'type', 'defer'], uriPolicy: _AllowUriPolicy())
      ..allowCustomElement('model-viewer',
          attributes: [
            'src',
            'style',
            'alt',
            'ar',
            'auto-rotate',
            'camera-controls'
          ],
          uriPolicy: _AllowUriPolicy());

    final html = _buildHTMLForWeb(htmlTemplate, useCdn: true);
    ui.platformViewRegistry.registerViewFactory(
        'model-viewer-html',
        (int viewId) => HtmlHtmlElement()
          ..style.border = 'none'
          ..style.height = '100%'
          ..style.width = '100%'
          ..setInnerHtml(html, validator: _validator));

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    // if (_proxy != null) {
    //   _proxy!.close(force: true);
    //   _proxy = null;
    // }
  }

  @override
  void didUpdateWidget(final ModelViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // TODO
  }

  @override
  Widget build(final BuildContext context) {
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(
            semanticsLabel: 'Loading Model Viewer...',
          ))
        : HtmlElementView(
            viewType: 'model-viewer-html',
            onPlatformViewCreated: (int a) async {
              print('onPlatformViewCreated: $a');
            },
          );
  }

  String _buildHTMLForWeb(final String htmlTemplate,
      {bool useCdn = true,
      String cdnUrl =
          'https://unpkg.com/@google/model-viewer/dist/model-viewer.min.js'}) {
    if (widget.src.startsWith('file://')) {
      // Local file URL can't be used in Flutter web.
      print("file: URL scheme can't be used in Flutter web.");
    }

    return HTMLBuilder.build(
      // For web, is it better to use the CDN's min.js ?
      htmlTemplate: htmlTemplate.replaceFirst(
          '<script src="model-viewer.js" defer>',
          useCdn
              ? '<script type="module" src="${cdnUrl}">'
              : '<script src="assets/packages/model_viewer_plus/etc/assets/model-viewer.js" defer>'),
      backgroundColor: widget.backgroundColor,
      src: widget.src,
      alt: widget.alt,
      ar: widget.ar,
      arModes: widget.arModes,
      arScale: widget.arScale,
      autoRotate: widget.autoRotate,
      autoRotateDelay: widget.autoRotateDelay,
      autoPlay: widget.autoPlay,
      cameraControls: widget.cameraControls,
      iosSrc: widget.iosSrc,
    );
  }
}

class _AllowUriPolicy implements UriPolicy {
  @override
  bool allowsUri(String uri) {
    return true;
  }
}
