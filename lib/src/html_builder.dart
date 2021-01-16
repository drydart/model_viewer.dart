/* This is free and unencumbered software released into the public domain. */

import 'dart:convert' show htmlEscape;

import 'package:flutter/material.dart';

abstract class HTMLBuilder {
  HTMLBuilder._();

  static String build(
      {final String htmlTemplate = '',
      @required final String src,
      final Color backgroundColor = const Color(0xFFFFFF),
      final String alt,
      final bool ar,
      final List<String> arModes,
      final String arScale,
      final bool autoRotate,
      final int autoRotateDelay,
      final bool autoPlay,
      final bool cameraControls,
      final bool enableColorChange,
      final String iosSrc}) {
    final html = StringBuffer(htmlTemplate);
    html.write('<model-viewer');
    html.write(' src="${htmlEscape.convert(src)}"');
    html.write(
        ' style="background-color: rgb(${backgroundColor.red}, ${backgroundColor.green}, ${backgroundColor.blue});"');
    if (alt != null) {
      html.write(' alt="${htmlEscape.convert(alt)}"');
    }
    // TODO: animation-name
    // TODO: animation-crossfade-duration
    if (ar ?? false) {
      html.write(' ar');
    }
    if (arModes != null) {
      html.write(' ar-modes="${htmlEscape.convert(arModes.join(' '))}"');
    }
    if (arScale != null) {
      html.write(' ar-scale="${htmlEscape.convert(arScale)}"');
    }
    if (autoRotate ?? false) {
      html.write(' auto-rotate');
    }
    if (autoRotateDelay != null) {
      html.write(' auto-rotate-delay="$autoRotateDelay"');
    }
    if (autoPlay ?? false) {
      html.write(' autoplay');
    }
    // TODO: skybox-image
    if (cameraControls ?? false) {
      html.write(' camera-controls');
    }
    // TODO: camera-orbit
    // TODO: camera-target
    // TODO: environment-image
    // TODO: exposure
    // TODO: field-of-view
    // TODO: interaction-policy
    // TODO: interaction-prompt
    // TODO: interaction-prompt-style
    // TODO: interaction-prompt-threshold
    if (iosSrc != null) {
      html.write(' ios-src="${htmlEscape.convert(iosSrc)}"');
    }

    if (enableColorChange ?? false) {
      html.write(' id="color"');
    }

    // TODO: max-camera-orbit
    // TODO: max-field-of-view
    // TODO: min-camera-orbit
    // TODO: min-field-of-view
    // TODO: poster
    // TODO: loading
    // TODO: quick-look-browsers
    // TODO: reveal
    // TODO: shadow-intensity
    // TODO: shadow-softness
    html.writeln('></model-viewer>');

    if (enableColorChange ?? false) {
      html.write(_buildColorChangeJSFunction());
    }

    html.write(_buildModelVisibilityEventJSFunction());

    return html.toString();
  }

  static String _buildColorChangeJSFunction() {
    return '''
    <script type="text/javascript">
      function changeColor(colorString) {
        const modelViewerColor = document.querySelector("model-viewer#color");
        const color = colorString.split(',')
                .map(numberString => parseFloat(numberString));
        const [material] = modelViewerColor.model.materials;
        material.pbrMetallicRoughness.setBaseColorFactor(color);
      }
    </script>
    ''';
  }

  static String _buildModelVisibilityEventJSFunction() {
    return '''
    <script type="text/javascript">
        const modelViewerElement = document.querySelector("model-viewer");
        modelViewerElement.addEventListener('model-visibility', (event) => {
            messageIsVisibile.postMessage(event.detail.visible);
        });
    </script>
    ''';
  }
}
