/* This is free and unencumbered software released into the public domain. */

import 'dart:convert' show htmlEscape;

import 'package:flutter/material.dart';
import '../model_viewer_plus.dart';

abstract class HTMLBuilder {
  HTMLBuilder._();

  static String build({
    String htmlTemplate = '',
    // Attributes
    // Loading Attributes
    required final String src,
    final String? alt,
    final String? poster,
    final bool? seamlessPoster,
    final Loading? loading,
    final Reveal? reveal,
    final bool? withCredentials,
    // AR Attributes
    final bool? ar,
    final List<String>? arModes,
    final ArScale? arScale,
    final ArPlacement? arPlacement,
    final String? iosSrc,
    final bool? xrEnvironment,
    // Staging & Cameras Attributes
    final bool? cameraControls,
    final bool? enablePan,
    final TouchAction? touchAction,
    final bool? disableZoom,
    final int? orbitSensitivity,
    final bool? autoRotate,
    final int? autoRotateDelay,
    final String? rotationPerSecond,
    final InteractionPolicy? interactionPolicy,
    final InteractionPrompt? interactionPrompt,
    final InteractionPromptStyle? interactionPromptStyle,
    final num? interactionPromptThreshold,
    final String? cameraOrbit,
    final String? cameraTarget,
    final String? fieldOfView,
    final String? maxCameraOrbit,
    final String? minCameraOrbit,
    final String? maxFieldOfView,
    final String? minFieldOfView,
    final Bounds? bounds,
    final num? interpolationDecay,
    // Lighting & Env Attributes
    final String? skyboxImage,
    final String? environmentImage,
    final num? exposure,
    final num? shadowIntensity,
    final num? shadowSoftness,
    // Animation Attributes
    final String? animationName,
    final num? animationCrossfadeDuration,
    final bool? autoPlay,
    // Scene Graph Attributes
    final String? variantName,
    final String? orientation,
    final String? scale,

    // CSS Styles
    final Color backgroundColor = Colors.transparent,
    // Loading CSS
    final Color? posterColor,
    // Annotations CSS
    final num? minHotspotOpacity,
    final num? maxHotspotOpacity,

    // Others
    final String? innerModelViewerHtml,
    final String? relatedCss,
    final String? relatedJs,
    final String? id,
  }) {
    if (relatedCss != null) {
      htmlTemplate = htmlTemplate.replaceFirst('/* other-css */', relatedCss);
    }
    if (relatedJs != null) {
      htmlTemplate = htmlTemplate.replaceFirst('/* js */', relatedJs);
    }

    final html = StringBuffer(htmlTemplate);

    html.write('<model-viewer');

    // Attributes
    // Loading Attributes
    // src
    html.write(' src="${htmlEscape.convert(src)}"');
    // alt
    if (alt != null) {
      html.write(' alt="${htmlEscape.convert(alt)}"');
    }
    // poster
    if (poster != null) {
      html.write(' poster="${htmlEscape.convert(poster)}"');
    }
    // seamless-poster
    if (seamlessPoster ?? false) {
      html.write(' seamless-poster');
    }
    // loading
    if (loading != null) {
      switch (loading) {
        case Loading.auto:
          html.write(' loading="auto"');
          break;
        case Loading.lazy:
          html.write(' loading="lazy"');
          break;
        case Loading.eager:
          html.write(' loading="eager"');
          break;
      }
    }
    // reveal
    if (reveal != null) {
      switch (reveal) {
        case Reveal.auto:
          html.write(' reveal="auto"');
          break;
        case Reveal.interaction:
          html.write(' reveal="interaction"');
          break;
        case Reveal.manual:
          html.write(' reveal="manual"');
          break;
      }
    }
    // with-credentials
    if (withCredentials ?? false) {
      html.write(' with-credentials');
    }

    // Augmented Reality Attributes
    // ar
    if (ar ?? false) {
      html.write(' ar');
    }
    // ar-modes
    if (arModes != null) {
      html.write(' ar-modes="${htmlEscape.convert(arModes.join(' '))}"');
    }
    // ar-scale
    if (arScale != null) {
      switch (arScale) {
        case ArScale.auto:
          html.write(' ar-scale="auto"');
          break;
        case ArScale.fixed:
          html.write(' ar-scale="fixed"');
          break;
      }
    }
    // ar-placement
    if (arPlacement != null) {
      switch (arPlacement) {
        case ArPlacement.floor:
          html.write(' ar-placement="floor"');
          break;
        case ArPlacement.wall:
          html.write(' ar-placement="wall"');
          break;
      }
    }
    // ios-src
    if (iosSrc != null) {
      html.write(' ios-src="${htmlEscape.convert(iosSrc)}"');
    }
    // xr-environment
    if (xrEnvironment ?? false) {
      html.write(' xr-environment');
    }

    // Staging & Cameras Attributes
    // camera-controls
    if (cameraControls ?? false) {
      html.write(' camera-controls');
    }
    // enable-pan
    if (enablePan ?? false) {
      html.write(' enable-pan');
    }
    // touch-action
    if (touchAction != null) {
      switch (touchAction) {
        case TouchAction.none:
          html.write(' touch-action="none"');
          break;
        case TouchAction.panX:
          html.write(' touch-action="pan-x"');
          break;
        case TouchAction.panY:
          html.write(' touch-action="pan-y"');
          break;
      }
    }
    // disable-zoom
    if (disableZoom ?? false) {
      html.write(' disable-zoom');
    }
    // orbit-sensitivity
    if (orbitSensitivity != null) {
      html.write(' orbit-sensitivity="${orbitSensitivity}"');
    }
    // auto-rotate
    if (autoRotate ?? false) {
      html.write(' auto-rotate');
    }
    // auto-rotate-delay
    if (autoRotateDelay != null) {
      html.write(' auto-rotate-delay="$autoRotateDelay"');
    }
    // rotation-per-second
    if (rotationPerSecond != null) {
      html.write(
          ' rotation-per-second="${htmlEscape.convert(rotationPerSecond)}"');
    }
    // interaction-policy
    if (interactionPolicy != null) {
      switch (interactionPolicy) {
        case InteractionPolicy.allowWhenFocused:
          html.write(' interaction-policy="allow-when-focused"');
          break;
        case InteractionPolicy.alwaysAllow:
          html.write(' interaction-policy="always-allow"');
          break;
      }
    }
    // interaction-prompt
    if (interactionPrompt != null) {
      switch (interactionPrompt) {
        case InteractionPrompt.auto:
          html.write(' interaction-prompt="auto"');
          break;
        case InteractionPrompt.none:
          html.write(' interaction-prompt="none"');
          break;
        case InteractionPrompt.whenFocused:
          html.write(' interaction-prompt="when-focused"');
          break;
      }
    }
    // interaction-prompt-style
    if (interactionPromptStyle != null) {
      switch (interactionPromptStyle) {
        case InteractionPromptStyle.basic:
          html.write(' interaction-prompt-style="basic"');
          break;
        case InteractionPromptStyle.wiggle:
          html.write(' interaction-prompt-style="wiggle"');
          break;
      }
    }
    // interaction-prompt-threshold
    if (interactionPromptThreshold != null) {
      if (interactionPromptThreshold < 0) {
        throw RangeError('interaction-prompt-threshold must be >= 0');
      }
      html.write(' interaction-prompt-threshold="$interactionPromptThreshold"');
    }
    // camera-orbit
    if (cameraOrbit != null) {
      html.write(' camera-orbit="${htmlEscape.convert(cameraOrbit)}"');
    }
    // camera-target
    if (cameraTarget != null) {
      html.write(' camera-target="${htmlEscape.convert(cameraTarget)}"');
    }
    // field-of-view
    if (fieldOfView != null) {
      html.write(' field-of-view="${htmlEscape.convert(fieldOfView)}"');
    }
    // max-camera-orbit
    if (maxCameraOrbit != null) {
      html.write(' max-camera-orbit="${htmlEscape.convert(maxCameraOrbit)}"');
    }
    // min-camera-orbit
    if (minCameraOrbit != null) {
      html.write(' min-camera-orbit="${htmlEscape.convert(minCameraOrbit)}"');
    }
    // max-field-of-view
    if (maxFieldOfView != null) {
      html.write(' max-field-of-view="${htmlEscape.convert(maxFieldOfView)}"');
    }
    // min-field-of-view
    if (minFieldOfView != null) {
      html.write(' min-field-of-view="${htmlEscape.convert(minFieldOfView)}"');
    }
    // bounds
    if (bounds != null) {
      switch (bounds) {
        case Bounds.tight:
          html.write(' bounds="tight"');
          break;
        case Bounds.legacy:
          html.write(' bounds="legacy"');
          break;
      }
    }
    // interpolation-decay
    if (interpolationDecay != null) {
      if (interpolationDecay <= 0) {
        throw RangeError('interaction-decay must be greater than 0');
      }
      html.write(' interpolation-decay="$interpolationDecay"');
    }

    // Lighting & Env Attributes
    // skybox-image
    if (skyboxImage != null) {
      html.write(' skybox-image="${htmlEscape.convert(skyboxImage)}"');
    }
    // environment-image
    if (environmentImage != null) {
      html.write(
          ' environment-image="${htmlEscape.convert(environmentImage)}"');
    }
    // exposure
    if (exposure != null) {
      if (exposure < 0) {
        throw RangeError('exposure must be any positive value');
      }
      html.write(' exposure="$exposure"');
    }
    // shadow-intensity
    if (shadowIntensity != null) {
      if (shadowIntensity < 0 || shadowIntensity > 1) {
        throw RangeError('shadow-intensity must be between 0 and 1');
      }
      html.write(' shadow-intensity="$shadowIntensity}"');
    }
    // shadow-softness
    if (shadowSoftness != null) {
      if (shadowSoftness < 0 || shadowSoftness > 1) {
        throw RangeError('shadow-softness must be between 0 and 1');
      }
      html.write(' shadow-softness="$shadowSoftness}"');
    }

    // Animation Attributes
    // animation-name
    if (animationName != null) {
      html.write(' animation-name="${htmlEscape.convert(animationName)}"');
    }
    // animation-crossfade-duration
    if (animationCrossfadeDuration != null) {
      if (animationCrossfadeDuration < 0) {
        throw RangeError('shadow-softness must be any number >= 0');
      }
      html.write(' animation-crossfade-duration="$animationCrossfadeDuration"');
    }
    // autoplay
    if (autoPlay ?? false) {
      html.write(' autoplay');
    }

    // Scene Graph Attributes
    // variant-name
    if (variantName != null) {
      html.write(' variant-name="${htmlEscape.convert(variantName)}"');
    }
    // orientation
    if (orientation != null) {
      html.write(' orientation="${htmlEscape.convert(orientation)}"');
    }
    // scale
    if (scale != null) {
      html.write(' scale="${htmlEscape.convert(scale)}"');
    }

    // Styles
    html.write(' style="');
    // CSS Styles
    html.write(
        'background-color: rgba(${backgroundColor.red}, ${backgroundColor.green}, ${backgroundColor.blue}, ${backgroundColor.alpha}); ');
    // Loading CSS
    // --poster-color
    if (posterColor != null) {
      html.write(
          'poster-color: rgba(${posterColor.red}, ${posterColor.green}, ${posterColor.blue}, ${posterColor.alpha}); ');
    }

    // Annotations CSS
    // --min-hotspot-opacity
    if (minHotspotOpacity != null) {
      if (minHotspotOpacity > 1 || minHotspotOpacity < 0) {
        throw RangeError('--min-hotspot-opacity must be between 0 and 1');
      }
      html.write('min-hotspot-opacity: $minHotspotOpacity; ');
    }
    // --max-hotspot-opacity
    if (maxHotspotOpacity != null) {
      if (maxHotspotOpacity > 1 || maxHotspotOpacity < 0) {
        throw RangeError('--max-hotspot-opacity must be between 0 and 1');
      }
      html.write('max-hotspot-opacity: $maxHotspotOpacity; ');
    }
    html.write('"'); // close style

    if (id != null) {
      html.write(' id="${htmlEscape.convert(id)}"');
    }

    html.writeln('>'); // close the previous tag of omodel-viewer
    if (innerModelViewerHtml != null) {
      html.writeln(innerModelViewerHtml);
    }
    html.writeln('</model-viewer>');

    if (relatedJs != null) {
      html.writeln('<script>');
      html.write(relatedJs);
      html.writeln('</script>');
    }

    debugPrint("HTML generated for model_viewer_plus:");
    debugPrint(html.toString()); // DEBUG

    return html.toString();
  }
}
