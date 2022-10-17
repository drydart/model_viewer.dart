/* This is free and unencumbered software released into the public domain. */

import 'dart:async' show Completer;
import 'dart:convert' show utf8;
import 'dart:io'
    show File, HttpRequest, HttpServer, HttpStatus, InternetAddress, Platform;
import 'dart:typed_data' show Uint8List;

import 'package:android_intent_plus/android_intent.dart' as android_content;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:model_viewer_plus/src/utils/constants.dart';
import 'package:path/path.dart' as p;
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
        backgroundColor: Colors.black,
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
            if (Platform.isIOS && navigation.url == widget.iosSrc) {
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
            final String fileURL;
            if (['http', 'https'].contains(Uri.parse(widget.src).scheme)) {
              fileURL = widget.src;
            } else {
              fileURL = p.joinAll([_proxyURL, 'model']);
            }
            final intent = android_content.AndroidIntent(
              action: "android.intent.action.VIEW", // Intent.ACTION_VIEW
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
        onPageStarted: (final String url) {},
        onWebResourceError: widget.onWebResourceError,
        javascriptChannels: {
          JavascriptChannel(
            name: kProgressKey,
            onMessageReceived: (JavascriptMessage progress) {
              widget.onProgress!(double.parse(progress.message));
            },
          ),
          JavascriptChannel(
            name: kErrorKey,
            onMessageReceived: (JavascriptMessage message) {
              if (message.message.isNotEmpty) {
                widget.onError!(message.message);
              }
            },
          ),
          JavascriptChannel(
            name: kLoadKey,
            onMessageReceived: (JavascriptMessage message) {
              if (message.message == "Loaded") {
                widget.onLoad!(true);
                return;
              }
              widget.onLoad!(false);
            },
          ),
        },
      );
    }
  }

  String _buildHTML(final String htmlTemplate) {
    return HTMLBuilder.build(
        htmlTemplate: htmlTemplate,
        src: '/model',
        alt: widget.alt,
        poster: widget.poster,
        seamlessPoster: widget.seamlessPoster,
        loading: widget.loading,
        reveal: widget.reveal,
        withCredentials: widget.withCredentials,
        // AR Attributes
        ar: widget.ar,
        arModes: widget.arModes,
        arScale: widget.arScale,
        arPlacement: widget.arPlacement,
        iosSrc: widget.iosSrc,
        xrEnvironment: widget.xrEnvironment,
        // Staing & Cameras Attributes
        cameraControls: widget.cameraControls,
        enablePan: widget.enablePan,
        touchAction: widget.touchAction,
        disableZoom: widget.disableZoom,
        orbitSensitivity: widget.orbitSensitivity,
        autoRotate: widget.autoRotate,
        autoRotateDelay: widget.autoRotateDelay,
        rotationPerSecond: widget.rotationPerSecond,
        interactionPolicy: widget.interactionPolicy,
        interactionPrompt: widget.interactionPrompt,
        interactionPromptStyle: widget.interactionPromptStyle,
        interactionPromptThreshold: widget.interactionPromptThreshold,
        cameraOrbit: widget.cameraOrbit,
        cameraTarget: widget.cameraTarget,
        fieldOfView: widget.fieldOfView,
        maxCameraOrbit: widget.maxCameraOrbit,
        minCameraOrbit: widget.minCameraOrbit,
        maxFieldOfView: widget.maxFieldOfView,
        minFieldOfView: widget.minFieldOfView,
        bounds: widget.bounds,
        interpolationDecay: widget.interpolationDecay,
        // Lighting & Env Attributes
        skyboxImage: widget.skyboxImage,
        environmentImage: widget.environmentImage,
        exposure: widget.exposure,
        shadowIntensity: widget.shadowIntensity,
        shadowSoftness: widget.shadowSoftness,
        // Animation Attributes
        animationName: widget.animationName,
        animationCrossfadeDuration: widget.animationCrossfadeDuration,
        autoPlay: widget.autoPlay,
        // Scene Graph Attributes
        variantName: widget.variantName,
        orientation: widget.orientation,
        scale: widget.scale,

        // CSS Styles
        backgroundColor: widget.backgroundColor,
        // Loading CSS
        posterColor: widget.posterColor,
        // Annotations CSS
        minHotspotOpacity: widget.minHotspotOpacity,
        maxHotspotOpacity: widget.maxHotspotOpacity,

        // Others
        innerModelViewerHtml: widget.innerModelViewerHtml,
        relatedCss: widget.relatedCss,
        relatedJs: widget.relatedJs,
        id: widget.id,

        // For Getting the progress/isLoaded or Error of 3D model
        onError: widget.onError,
        onLoad: widget.onLoad,
        onProgress: widget.onProgress);
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
          final text = utf8.encode("Resource '${request.uri}' not found");
          response
            ..statusCode = HttpStatus.notFound
            ..headers.add("Content-Type", "text/plain;charset=UTF-8")
            ..headers.add("Content-Length", text.length.toString())
            ..add(text);
          await response.close();
          break;

        default:
          if (request.uri.isAbsolute) {
            debugPrint("Redirect: ${request.uri}");
            await response.redirect(request.uri);
          } else if (request.uri.hasAbsolutePath) {
            // Some gltf models need other resources from the origin
            var pathSegments = [...url.pathSegments];
            pathSegments.removeLast();
            var tryDestination = p.joinAll([
              url.origin,
              ...pathSegments,
              request.uri.path.replaceFirst('/', '')
            ]);
            debugPrint("Try: ${tryDestination}");
            await response.redirect(Uri.parse(tryDestination));
          } else {
            debugPrint('404 with ${request.uri}');
            final text = utf8.encode("Resource '${request.uri}' not found");
            response
              ..statusCode = HttpStatus.notFound
              ..headers.add("Content-Type", "text/plain;charset=UTF-8")
              ..headers.add("Content-Length", text.length.toString())
              ..add(text);
            await response.close();
            break;
          }
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
