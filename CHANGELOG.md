# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.8.0] - 2020-08-20

### Changed

- Required [flutter_android](https://pub.dev/packages/flutter_android)
  0.8.0+.

### Added

- Support for a `localhost` HTTP server and proxy

## [0.7.0] - 2020-08-18

### Changed

- Required [flutter_android](https://pub.dev/packages/flutter_android)
  for launching the Scene Viewer. ([#4])

- Upgraded to model-viewer.js
  [1.1.0](https://github.com/google/model-viewer/releases/tag/v1.1.0).

### Fixed

- Launching the Scene Viewer on Android now works. (Fixes [#4])

- Improved error logging in case of loading errors.

## [0.6.0] - 2020-08-18

### Fixed

- Escaped HTML attributes on the `<model-viewer>` web component.

## [0.5.0] - 2020-07-22

### Added

- Frequently asked questions and answers in the README.

[0.8.0]: https://github.com/drydart/model_viewer.dart/compare/0.7.0...0.8.0
[0.7.0]: https://github.com/drydart/model_viewer.dart/compare/0.6.0...0.7.0
[0.6.0]: https://github.com/drydart/model_viewer.dart/compare/0.5.0...0.6.0
[0.5.0]: https://github.com/drydart/model_viewer.dart/compare/0.4.0...0.5.0

[#4]:    https://github.com/drydart/model_viewer.dart/issues/4
