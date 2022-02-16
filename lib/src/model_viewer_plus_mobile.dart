/* This is free and unencumbered software released into the public domain. */

import 'dart:async' show Completer;
import 'dart:convert' show utf8;
import 'dart:io'
    show File, HttpRequest, HttpServer, HttpStatus, InternetAddress, Platform;
import 'dart:typed_data' show Uint8List;

import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:android_intent_plus/android_intent.dart' as android_content;
import 'package:webview_flutter/webview_flutter.dart';

import 'html_builder.dart';

import 'model_viewer_plus.dart';

class ModelViewerState extends State<ModelViewer> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  HttpServer? _proxy;

  @override
  void initState() {
    super.initState();
    _initProxy();
  }

  @override
  void dispose() {
    super.dispose();
    if (_proxy != null) {
      _proxy!.close(force: true);
      _proxy = null;
    }
  }

  @override
  void didUpdateWidget(final ModelViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // TODO
  }

  @override
  Widget build(final BuildContext context) {
    if (_proxy == null) {
      return WebView(
        initialUrl: null,
        javascriptMode: JavascriptMode.unrestricted,
        initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
        onWebViewCreated: (final WebViewController webViewController) async {
          _controller.complete(webViewController);
          final host = _proxy!.address.address;
          final port = _proxy!.port;
          final url = "http://$host:$port/";
          print('>>>> ModelViewer initializing... <$url>'); // DEBUG
          await webViewController.loadUrl(url);
        },
        navigationDelegate: (final NavigationRequest navigation) async {
          //print('>>>> ModelViewer wants to load: <${navigation.url}>'); // DEBUG
          if (!Platform.isAndroid) {
            return NavigationDecision.navigate;
          }
          if (!navigation.url.startsWith("intent://")) {
            return NavigationDecision.navigate;
          }
          try {
            // See: https://developers.google.com/ar/develop/java/scene-viewer
            final intent = android_content.AndroidIntent(
              action: "android.intent.action.VIEW", // Intent.ACTION_VIEW
              data: "https://arvr.google.com/scene-viewer/1.0",
              arguments: <String, dynamic>{
                'file': widget.src,
                'mode': 'ar_only',
              },
              package: "com.google.ar.core",
              flags: <int>[
                Flag.FLAG_ACTIVITY_NEW_TASK
              ], // Intent.FLAG_ACTIVITY_NEW_TASK,
            );
            await intent.launch();
          } catch (error) {
            print('>>>> ModelViewer failed to launch AR: $error'); // DEBUG
          }
          return NavigationDecision.prevent;
        },
        onPageStarted: (final String url) {
          //print('>>>> ModelViewer began loading: <$url>'); // DEBUG
        },
        onPageFinished: (final String url) {
          //print('>>>> ModelViewer finished loading: <$url>'); // DEBUG
        },
        onWebResourceError: (final WebResourceError error) {
          print(
              '>>>> ModelViewer failed to load: ${error.description} (${error.errorType} ${error.errorCode})'); // DEBUG
        },
      );
    } else {
      return Center(
          child: CircularProgressIndicator(
        semanticsLabel: 'Loading Model Viewer...',
      ));
    }
  }

  String _buildHTML(final String htmlTemplate) {
    return HTMLBuilder.build(
      htmlTemplate: htmlTemplate,
      backgroundColor: widget.backgroundColor,
      src: '/model',
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

  Future<void> _initProxy() async {
    final url = Uri.parse(widget.src);
    _proxy = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _proxy!.listen((final HttpRequest request) async {
      //print("${request.method} ${request.uri}"); // DEBUG
      //print(request.headers); // DEBUG
      final response = request.response;

      switch (request.uri.path) {
        case '/':
        case '/index.html':
          final htmlTemplate = await rootBundle
              .loadString('packages/model_viewer_plus/assets/template.html');
          final html = utf8.encode(_buildHTML(htmlTemplate));
          response
            ..statusCode = HttpStatus.ok
            ..headers.add("Content-Type", "text/html;charset=UTF-8")
            ..headers.add("Content-Length", html.length.toString())
            ..add(html);
          await response.close();
          break;

        case '/model-viewer.min.js':
          final code = await _readAsset(
              'packages/model_viewer_plus/assets/model-viewer.min.js');
          response
            ..statusCode = HttpStatus.ok
            ..headers
                .add("Content-Type", "application/javascript;charset=UTF-8")
            ..headers.add("Content-Length", code.lengthInBytes.toString())
            ..add(code);
          await response.close();
          break;

        case '/model':
          if (url.isAbsolute && !url.isScheme("file")) {
            await response.redirect(url); // TODO: proxy the resource
          } else {
            final data = await (url.isScheme("file")
                ? _readFile(url.path)
                : _readAsset(url.path));
            response
              ..statusCode = HttpStatus.ok
              ..headers.add("Content-Type", "application/octet-stream")
              ..headers.add("Content-Length", data.lengthInBytes.toString())
              ..headers.add("Access-Control-Allow-Origin", "*")
              ..add(data);
            await response.close();
          }
          break;

        case '/favicon.ico':
        default:
          final text = utf8.encode("Resource '${request.uri}' not found");
          response
            ..statusCode = HttpStatus.notFound
            ..headers.add("Content-Type", "text/plain;charset=UTF-8")
            ..headers.add("Content-Length", text.length.toString())
            ..add(text);
          await response.close();
          break;
      }
    });
  }

  Future<Uint8List> _readAsset(final String key) async {
    final data = await rootBundle.load(key);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<Uint8List> _readFile(final String path) async {
    return await File(path).readAsBytes();
  }
}
