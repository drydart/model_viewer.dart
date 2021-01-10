import 'package:flutter/material.dart';

typedef ChangeColorTypeDef = Future<String> Function(String);

/// The [ModelViewerColorController] is used to control the color settings of the model viewer.
/// If the function [changeColor(colorString)] is called, then the base color of the model will be changed.
/// 
/// At the moment the [ModelViewerColorController] can only change the base color of the model.
/// The base color is auto detected by the biggest size object of the model.
class ModelViewerColorController {
  /// change the color by a given colorString
  ChangeColorTypeDef changeColor;
  // ToDo: Add a function to get possibble color areas
  // ToDo: set colors for detected areas

  void dispose() {
    changeColor = null;
  }
}
