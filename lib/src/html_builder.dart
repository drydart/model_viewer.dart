/* This is free and unencumbered software released into the public domain. */

import 'package:flutter/material.dart';

abstract class HTMLBuilder {
  HTMLBuilder._();

  static String build(
      {@required final Color backgroundColor,
      @required final String src,
      final String alt,
      final bool ar,
      final List<String> arModes,
      final String arScale,
      final bool autoRotate,
      final int autoRotateDelay,
      final bool autoPlay,
      final bool cameraControls,
      final String iosSrc}) {
    final prelude = '''
      <meta name="viewport" content="width=device-width, initial-scale=1"/>
      <style>body, model-viewer { width: 100%; height: 100%; margin: 0; padding: 0; }</style>
    ''';

    final html = StringBuffer(prelude);
    html.write('<model-viewer');
    html.write(' style="background-color: rgb(${backgroundColor.red}, ${backgroundColor.green}, ${backgroundColor.blue});"');
    html.write(' src="$src"');
    if (alt != null) {
      html.write(' alt="$alt"'); // TODO: escape string
    }
    if (ar ?? false) {
      html.write(' ar');
    }
    if (arModes != null) {
      html.write(' ar-modes="${arModes.join(' ')}"'); // TODO: escape string
    }
    if (arScale != null) {
      html.write(' ar-scale="$arScale"'); // TODO: escape string
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
    if (cameraControls ?? false) {
      html.write(' camera-controls');
    }
    if (iosSrc != null) {
      html.write(' ios-src="$iosSrc"'); // TODO: escape string
    }
    html.writeln('></model-viewer>');
    return html.toString();
  }
}
