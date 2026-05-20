import 'dart:ui';

/// Shared viewfinder layout for scanner preview, overlay, and capture crop.
class ScannerViewfinderGeometry {
  ScannerViewfinderGeometry._();

  static const double frameWidthFraction = 0.80;
  static const double frameHeightFraction = 0.60;
  static const double topBarHeight = 56;
  static double bottomControlsHeightFor(Size screenSize) =>
      (screenSize.height * 0.26).clamp(168.0, 230.0);

  /// Document frame centered between top bar and bottom controls.
  static Rect viewfinderRect(
    Size screenSize, {
    double topInset = 0,
    double bottomInset = 0,
  }) {
    final top = topInset + topBarHeight;
    final bottomReserved = bottomControlsHeightFor(screenSize) + bottomInset;

    final availableHeight = (screenSize.height - top - bottomReserved)
        .clamp(100.0, screenSize.height);

    final frameW = screenSize.width * frameWidthFraction;
    final frameH = (screenSize.height * frameHeightFraction)
        .clamp(100.0, availableHeight * 0.9);

    final centerY = top + availableHeight / 2;

    return Rect.fromCenter(
      center: Offset(screenSize.width / 2, centerY),
      width: frameW,
      height: frameH,
    );
  }

  /// Viewfinder as fractions of the full screen (for image crop mapping).
  static Rect normalizedRect(Size screenSize, Rect viewfinder) {
    return Rect.fromLTWH(
      (viewfinder.left / screenSize.width).clamp(0.0, 1.0),
      (viewfinder.top / screenSize.height).clamp(0.0, 1.0),
      (viewfinder.width / screenSize.width).clamp(0.05, 1.0),
      (viewfinder.height / screenSize.height).clamp(0.05, 1.0),
    );
  }
}
