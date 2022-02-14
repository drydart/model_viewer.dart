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
