/* This is free and unencumbered software released into the public domain. */

library model_viewer;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ModelViewer extends StatefulWidget {
  ModelViewer({Key key, this.src, this.alt, this.autoRotate, this.cameraControls}) : super(key: key);

  final String src;
  final String alt;
  final bool autoRotate;
  final bool cameraControls;

  @override
  State<ModelViewer> createState() => _ModelViewerState();
}

class _ModelViewerState extends State<ModelViewer> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  Widget build(final BuildContext context) {
    return WebView(
      initialUrl: 'about:blank',
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (final WebViewController webViewController) async {
        _controller.complete(webViewController);
        final String html = _buildHTML();
        final String contentBase64 = base64Encode(const Utf8Encoder().convert(html));
        await webViewController.loadUrl('data:text/html;base64,$contentBase64');
      },
      onPageStarted: (final String url) {
        print('>>>>>>>>>>>>>>>>>>> Page started loading: $url'); // DEBUG
      },
      onPageFinished: (final String url) {
        print('>>>>>>>>>>>>>>>>>>> Page finished loading: $url'); // DEBUG
      },
    );
  }

  String _buildHTML() {
    return '''
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <style>body { width: 100%; height: 100%; background-color: black; } model-viewer { width: 100%; height: 100%; }</style>
      <script type="module" src="https://unpkg.com/@google/model-viewer/dist/model-viewer.js"></script>
      <script nomodule src="https://unpkg.com/@google/model-viewer/dist/model-viewer-legacy.js"></script>
      <model-viewer src="${this.widget.src}" alt="${this.widget.alt}" auto-rotate camera-controls></model-viewer>
    ''';
  }
}
