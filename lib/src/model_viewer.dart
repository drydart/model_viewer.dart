/* This is free and unencumbered software released into the public domain. */

import 'dart:async';
import 'dart:convert';
import 'dart:io'
    show HttpRequest, HttpServer, HttpStatus, InternetAddress, Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_android/android_content.dart' as android_content;
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
      this.iosSrc,
      this.proxy = true})
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

  final bool proxy;

  @override
  State<ModelViewer> createState() => _ModelViewerState();
}

class _ModelViewerState extends State<ModelViewer> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  HttpServer _proxy;

  @override
  void initState() {
    super.initState();
    if (widget.proxy) {
      _initProxy();
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_proxy != null) {
      _proxy.close(force: true);
      _proxy = null;
    }
  }

  @override
  Widget build(final BuildContext context) {
    return WebView(
      initialUrl: null,
      javascriptMode: JavascriptMode.unrestricted,
      initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
      onWebViewCreated: (final WebViewController webViewController) async {
        _controller.complete(webViewController);
        if (widget.proxy) {
          final host = _proxy.address.address;
          final port = _proxy.port;
          print(
              '>>>> ModelViewer initializing... (proxy at $host:$port)'); // DEBUG
          await webViewController.loadUrl('http://$host:$port/');
        } else {
          print('>>>> ModelViewer initializing...'); // DEBUG
          final bundle = DefaultAssetBundle.of(context);
          final themeData = Theme.of(context);
          final htmlTemplate = await bundle
              .loadString('packages/model_viewer/etc/assets/template.html');
          final html = _buildHTML(themeData, htmlTemplate);
          final contentBase64 = base64Encode(const Utf8Encoder().convert(html));
          await webViewController
              .loadUrl('data:text/html;base64,$contentBase64');
          final js = await bundle
              .loadString('packages/model_viewer/etc/assets/model-viewer.js');
          await webViewController.evaluateJavascript(js);
        }
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
          final intent = android_content.Intent(
            action: "android.intent.action.VIEW", // Intent.ACTION_VIEW
            data: Uri.parse("https://arvr.google.com/scene-viewer/1.0").replace(
              queryParameters: <String, dynamic>{
                'file': widget.src,
                'mode': 'ar_only',
              },
            ),
            package: "com.google.ar.core",
            flags: 0x10000000, // Intent.FLAG_ACTIVITY_NEW_TASK,
          );
          await intent.startActivity();
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

  String _buildHTML(final ThemeData themeData, final String htmlTemplate) {
    return HTMLBuilder.build(
      htmlTemplate: htmlTemplate,
      backgroundColor:
          widget.backgroundColor ?? themeData?.scaffoldBackgroundColor,
      src: widget.proxy ? '/model' : widget.src,
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
    final url = widget.src;
    _proxy = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _proxy.listen((final HttpRequest request) async {
      print("${request.method} ${request.uri}"); // DEBUG
      final response = request.response;

      switch (request.uri.path) {
        case '/':
          print(request.headers); // DEBUG
          final htmlTemplate = await rootBundle
              .loadString('packages/model_viewer/etc/assets/template.html');
          final html = _buildHTML(null, htmlTemplate) +
              "<script src=\"/model-viewer.js\"></script>";
          print(html);
          response
            ..statusCode = HttpStatus.ok
            ..headers.add("Content-Type", "text/html")
            ..write(html);
          await response.close();
          break;

        case '/model-viewer.js':
          print(request.headers); // DEBUG
          final code = await rootBundle
              .loadString('packages/model_viewer/etc/assets/model-viewer.js');
          response
            ..statusCode = HttpStatus.ok
            ..headers
                .add("Content-Type", "application/javascript;charset=UTF-8")
            ..write(code);
          await response.close();
          break;

        case '/model':
          print(request.headers); // DEBUG
          await response.redirect(Uri.parse(url)); // TODO: proxy the resource
          break;

        case '/favicon.ico':
        default:
          response
            ..statusCode = HttpStatus.notFound
            ..headers.add("Content-Type", "text/plain")
            ..write("Resource '${request.uri}' not found");
          await response.close();
          break;
      }
    });
  }
}
