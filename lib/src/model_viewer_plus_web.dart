/* This is free and unencumbered software released into the public domain. */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'html_builder.dart';

import 'dart:ui' as ui;
import 'dart:html';

import 'model_viewer_plus.dart';

class ModelViewerState extends State<ModelViewer> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    generateModelViewerHtml();
  }

  /// To generate the HTML code for using the model viewer.
  void generateModelViewerHtml() async {
    final htmlTemplate = await rootBundle
        .loadString('packages/model_viewer_plus/assets/template.html');
    // allow to use elements
    final NodeValidator _validator = NodeValidatorBuilder.common()
      ..allowElement('meta',
          attributes: ['name', 'content'], uriPolicy: _AllowUriPolicy())
      ..allowElement('style')
      // ..allowElement('script',
      //     attributes: ['src', 'type', 'defer'], uriPolicy: _AllowUriPolicy())
      ..allowCustomElement('model-viewer',
          attributes: [
            'style',

            // Loading Attributes
            'src',
            'alt',
            'poster',
            'poster',
            'seamless-poster',
            'loading',
            'reveal',

            // Augmented Reality Attributes
            'ar',
            'ar-modes',
            'ar-scale',
            'ar-placement',
            'ios-src',
            'xr-environment',

            // Staing & Cameras Attributes
            'camera-controls',
            'touch-action',
            'disable-zoom',
            'orbit-sensitivity',
            'auto-rotate',
            'auto-rotate-delay',
            'rotation-per-second',
            'interaction-policy',
            'interaction-prompt',
            'interaction-prompt-style',
            'interaction-prompt-threshold',
            'camera-orbit',
            'camera-target',
            'field-of-view',
            'max-camera-orbit',
            'min-camera-orbit',
            'max-field-of-view',
            'min-field-of-view',
            'bounds',
            'interpolation-decay',

            // Lighting & Env Attributes
            'skybox-image',
            'environment-image',
            'exposure',
            'shadow-intensity',
            'shadow-softness ',

            // Animation Attributes
            'animation-name',
            'animation-crossfade-duration',
            'autoplay ',

            // Scene Graph Attributes
            'variant-name',
            'orientation',
            'scale',
          ],
          uriPolicy: _AllowUriPolicy());

    final html = _buildHTML(htmlTemplate);

    // print(html); // DEBUG

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
        : HtmlElementView(viewType: 'model-viewer-html');
  }

  String _buildHTML(final String htmlTemplate) {
    if (widget.src.startsWith('file://')) {
      // Local file URL can't be used in Flutter web.
      print("file:// URL scheme can't be used in Flutter web.");
    }

    return HTMLBuilder.build(
      htmlTemplate: htmlTemplate.replaceFirst(
          '<script type="module" src="model-viewer.min.js" defer></script>',
          ''),
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
