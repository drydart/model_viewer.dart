# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1] - 2022-02-17

### Added

- `/assets/model-viewer.min.js` (v1.10.1, which is actually identical to v1.10.0)

### Changed

- `/etc/assets` -> `/assets`
- `example/flutter_02.png`: Updated the Screenshot.
- `README.md`: README Update.
- `lib/src/model_viewer_plus_web.dart`: Due to the change of `model-viewer.js` -> `model-viewer.min.js`
- `lib/src/model_viewer_plus_mobile.dart`: Due to the change of `model-viewer.js` -> `model-viewer.min.js`, added CircularProgressIndicator while mobile platform loading

### Removed

- `/etc/assets/model-viewer.js`: To slim the package size.

## [1.1.0] - 2022-02-15

### Added

- Web Support
  - `lib/src/model_viewer_plus_stub.dart`
  - `lib/src/model_viewer_plus_mobile.dart`
  - `lib/src/model_viewer_plus_web.dart`

### Changed

- `lib/model_viewer_plus.dart`
- `lib/src/model_viewer_plus.dart`
