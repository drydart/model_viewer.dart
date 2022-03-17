/* This is free and unencumbered software released into the public domain. */

import 'dart:async' show Completer;
import 'dart:convert' show utf8;
import 'dart:io'
    show File, HttpRequest, HttpServer, HttpStatus, InternetAddress, Platform;
import 'dart:typed_data' show Uint8List;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:path/path.dart' as p;

import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:android_intent_plus/android_intent.dart' as android_content;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'html_builder.dart';

import 'model_viewer_plus.dart';

class ModelViewerState extends State<ModelViewer> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  HttpServer? _proxy;
  late String _proxyURL;

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
      return Center(
        child: CircularProgressIndicator(
          semanticsLabel: 'Loading Model Viewer...',
        ),
      );
    } else {
      return WebView(
        backgroundColor: Colors.transparent,
        initialUrl: null,
        javascriptMode: JavascriptMode.unrestricted,
        initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        },
        onWebViewCreated: (final WebViewController webViewController) async {
          _controller.complete(webViewController);
          print('>>>> ModelViewer initializing... <$_proxyURL>'); // DEBUG
          await webViewController.loadUrl(_proxyURL);
        },
        navigationDelegate: (final NavigationRequest navigation) async {
          print('>>>> ModelViewer wants to load: <${navigation.url}>'); // DEBUG
          if (!Platform.isAndroid) {
            if(Platform.isIOS && navigation.url == widget.iosSrc) {
              await launch(
                navigation.url,
                forceSafariVC: true,
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          }
          if (!navigation.url.startsWith("intent://")) {
            return NavigationDecision.navigate;
          }
          try {
            // Original, just keep as a backup
            // See: https://developers.google.com/ar/develop/java/scene-viewer
            // final intent = android_content.AndroidIntent(
            //   action: "android.intent.action.VIEW", // Intent.ACTION_VIEW
            //   data: "https://arvr.google.com/scene-viewer/1.0",
            //   arguments: <String, dynamic>{
            //     'file': widget.src,
            //     'mode': 'ar_preferred',
            //   },
            //   package: "com.google.ar.core",
            //   flags: <int>[
            //     Flag.FLAG_ACTIVITY_NEW_TASK
            //   ], // Intent.FLAG_ACTIVITY_NEW_TASK,
            // );

            // 2022-03-14 update
            final String fileURL;
            if (['http', 'https'].contains(Uri.parse(widget.src).scheme)) {
              fileURL = widget.src;
            } else {
              fileURL = p.joinAll([_proxyURL, 'model']);
            }
            final intent = android_content.AndroidIntent(
              action: "android.intent.action.VIEW", // Intent.ACTION_VIEW
              // See https://developers.google.com/ar/develop/scene-viewer#3d-or-ar
              // data should be something like "https://arvr.google.com/scene-viewer/1.0?file=https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Avocado/glTF/Avocado.gltf"
              data: Uri(
                  scheme: 'https',
                  host: 'arvr.google.com',
                  path: '/scene-viewer/1.0',
                  queryParameters: {
                    // 'title': '', // TODO: maybe set by the user
                    // TODO: further test, and make it 'ar_preferred'
                    'mode': 'ar_preferred',
                    'file': fileURL,
                  }).toString(),
              // package changed to com.google.android.googlequicksearchbox
              // to support the widest possible range of devices
              package: "com.google.android.googlequicksearchbox",
              arguments: <String, dynamic>{
                'browser_fallback_url':
                    'market://details?id=com.google.android.googlequicksearchbox'
              },
            );
            await intent.launch().onError((error, stackTrace) {
              print('>>>> ModelViewer Intent Error: $error'); // DEBUG
            });
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

    setState(() {
      _proxy;
      final host = _proxy!.address.address;
      final port = _proxy!.port;
      _proxyURL = "http://$host:$port/";
    });

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

