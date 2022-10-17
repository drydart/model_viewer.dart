/* This is free and unencumbered software released into the public domain. */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'html_builder.dart';

import 'shim/dart_ui_fake.dart' if (dart.library.html) 'dart:ui' as ui;
import 'shim/dart_html_fake.dart' if (dart.library.html) 'dart:html';

import 'model_viewer_plus.dart';

class ModelViewerState extends State<ModelViewer> {
  bool _isLoading = true;
  final String _uniqueViewType = UniqueKey().toString();

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
      ..allowElement('script',
          attributes: [
            'src',
            'type',
            'defer',
            'async',
            'crossorigin',
            'integrity',
            'nomodule',
            'nonce',
            'referrerpolicy'
          ],
          uriPolicy: _AllowUriPolicy())
      ..allowCustomElement('model-viewer',
          attributes: [
            'style',

            // Loading Attributes
            'src',
            'alt',
            'poster',
            'seamless-poster',
            'loading',
            'reveal',
            'with-credentials',

            // Augmented Reality Attributes
            'ar',
            'ar-modes',
            'ar-scale',
            'ar-placement',
            'ios-src',
            'xr-environment',

            // Staing & Cameras Attributes
            'camera-controls',
            'enable-pan',
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
            'autoplay',

            // Scene Graph Attributes
            'variant-name',
            'orientation',
            'scale',
          ],
          uriPolicy: _AllowUriPolicy());

    final html = _buildHTML(htmlTemplate);

    // print(html); // DEBUG

    ui.platformViewRegistry.registerViewFactory(
        'model-viewer-html-$_uniqueViewType',
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
        : HtmlElementView(viewType: 'model-viewer-html-$_uniqueViewType');
  }

  String _buildHTML(final String htmlTemplate) {
    if (widget.src.startsWith('file://')) {
      // Local file URL can't be used in Flutter web.
      debugPrint("file:// URL scheme can't be used in Flutter web.");
      throw ArgumentError("file:// URL scheme can't be used in Flutter web.");
    }

    return HTMLBuilder.build(
        htmlTemplate: htmlTemplate.replaceFirst(
            '<script type="module" src="model-viewer.min.js" defer></script>',
            ''),
        // Attributes
        src: widget.src,
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
}

class _AllowUriPolicy implements UriPolicy {
  @override
  bool allowsUri(String uri) {
    return true;
  }
}
