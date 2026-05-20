import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Ensures 3-channel RGB (fixes grayscale decode from some camera JPEGs).
img.Image ensureRgb(img.Image image) {
  if (image.numChannels >= 3) return image;
  return image.convert(numChannels: 3);
}

/// Decodes bytes, applies EXIF orientation, and re-encodes as color JPEG.
Future<Uint8List> normalizeImageBytes(Uint8List bytes) async {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;
  final oriented = img.bakeOrientation(decoded);
  final rgb = ensureRgb(oriented);
  return Uint8List.fromList(img.encodeJpg(rgb, quality: 92));
}

/// Writes a color-corrected copy of [source] to a temp file.
Future<File> normalizeImageFile(File source) async {
  final bytes = await source.readAsBytes();
  final normalized = await normalizeImageBytes(bytes);
  final dir = await getTemporaryDirectory();
  final out = File(
    '${dir.path}/scan_${DateTime.now().millisecondsSinceEpoch}.jpg',
  );
  await out.writeAsBytes(normalized);
  return out;
}

/// Crops a captured image using normalized [0,1] coordinates.
Future<File> cropImageWithNormalizedRect(File source, Rect normalized) async {
  final bytes = await source.readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw StateError('Image decode failed');
  }

  final image = ensureRgb(img.bakeOrientation(decoded));

  final x = (normalized.left * image.width).round().clamp(0, image.width - 1);
  final y = (normalized.top * image.height).round().clamp(0, image.height - 1);
  final w = (normalized.width * image.width).round().clamp(1, image.width - x);
  final h = (normalized.height * image.height).round().clamp(
    1,
    image.height - y,
  );

  final cropped = img.copyCrop(image, x: x, y: y, width: w, height: h);

  final dir = await getTemporaryDirectory();
  final out = File(
    '${dir.path}/scan_${DateTime.now().millisecondsSinceEpoch}.jpg',
  );
  await out.writeAsBytes(img.encodeJpg(ensureRgb(cropped), quality: 92));
  return out;
}
