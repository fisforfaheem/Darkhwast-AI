import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

typedef VoiceResultCallback = void Function(String text, bool isFinal);

/// Speech-to-text with locale selection and clear error reporting.
class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _initialized = false;
  String? _lastError;
  String? _localeId;

  bool get isAvailable => _initialized;
  String? get lastError => _lastError;
  bool get isListening => _speech.isListening;

  Future<bool> init() async {
    _lastError = null;
    try {
      _initialized = await _speech.initialize(
        onStatus: (status) => debugPrint('Speech status: $status'),
        onError: (error) {
          _lastError = error.errorMsg;
          debugPrint('Speech error: ${error.errorMsg}');
        },
      );
      if (!_initialized) {
        _lastError = 'Speech recognition is not available on this device.';
      } else {
        _localeId = await _pickLocale();
      }
      return _initialized;
    } catch (e) {
      _lastError = e.toString();
      _initialized = false;
      return false;
    }
  }

  Future<String?> _pickLocale() async {
    final locales = await _speech.locales();
    const preferred = ['en_US', 'en_GB', 'en_PK', 'ur_PK', 'hi_IN'];
    for (final id in preferred) {
      if (locales.any((l) => l.localeId == id)) return id;
    }
    return locales.isNotEmpty ? locales.first.localeId : null;
  }

  Future<bool> startListening({required VoiceResultCallback onResult}) async {
    if (!_initialized) {
      _lastError ??= 'Speech not initialized. Call init() first.';
      return false;
    }

    _lastError = null;

    final started = await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      localeId: _localeId,
      listenFor: const Duration(seconds: 45),
      pauseFor: const Duration(seconds: 4),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
        listenMode: stt.ListenMode.confirmation,
      ),
    );

    if (!started) {
      _lastError = 'Could not start microphone. Check app permissions.';
    }
    return started;
  }

  Future<String?> stopListening() async {
    await _speech.stop();
    return _speech.lastRecognizedWords;
  }

  Future<void> cancel() async {
    await _speech.cancel();
  }
}
