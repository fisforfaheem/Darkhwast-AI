import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android camera capture with explicit URI read/write grants (Android 18+).
class NativeCameraCapture {
  NativeCameraCapture._();

  static const _channel = MethodChannel('com.example.darkhwast_ai/camera');

  static Future<String?> capture() async {
    try {
      final path = await _channel.invokeMethod<String>('capture');
      if (path == null || path.isEmpty) return null;
      return path;
    } on PlatformException catch (e) {
      debugPrint('NativeCameraCapture: ${e.code} ${e.message}');
      return null;
    }
  }
}
