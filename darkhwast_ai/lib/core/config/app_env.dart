import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime secrets: user secure storage > dart-define > dev .env (debug only).
class AppEnv {
  AppEnv._();

  static bool _loaded = false;

  static String geminiApiKey = '';

  static String geminiModel = _defaultGeminiModel;

  static bool forceMock = false;

  static const String _defaultGeminiModel = 'gemini-1.5-flash';

  static const String latestAgenticModel = 'gemini-1.5-flash';

  /// Call after [load]; updates key when user changes AI mode.
  static Future<void> applyUserGeminiKey(String? key) async {
    if (key != null && key.trim().isNotEmpty) {
      geminiApiKey = key.trim();
      return;
    }
    geminiApiKey = _resolve('GEMINI_API_KEY');
  }

  static Future<void> load({String? userGeminiKey}) async {
    if (_loaded && userGeminiKey == null) return;

    if (kDebugMode) {
      await _ensureDotEnvLoaded();
    }

    if (userGeminiKey != null && userGeminiKey.trim().isNotEmpty) {
      geminiApiKey = userGeminiKey.trim();
    } else {
      geminiApiKey = _resolve('GEMINI_API_KEY');
    }

    final model = _resolve('GEMINI_MODEL');
    geminiModel = model.isNotEmpty ? model : _defaultGeminiModel;
    final mockFlag = _resolve('USE_MOCK').toLowerCase();
    forceMock = mockFlag == 'true' || mockFlag == '1';

    _loaded = true;
  }

  /// Loads `.env` for local debug: project file (desktop) or asset (mobile).
  static Future<void> _ensureDotEnvLoaded() async {
    if (dotenv.isInitialized) return;

    try {
      final envFile = File('.env');
      if (await envFile.exists()) {
        final contents = await envFile.readAsString();
        dotenv.loadFromString(envString: contents, isOptional: true);
        return;
      }
    } catch (_) {}

    try {
      await dotenv.load(fileName: '.env', isOptional: true);
      if (dotenv.isInitialized) return;
    } catch (_) {}

    dotenv.loadFromString(isOptional: true);
  }

  static String _resolve(String key) {
    final fromDefine = String.fromEnvironment(key);
    if (fromDefine.isNotEmpty) return fromDefine;
    if (!kDebugMode || !dotenv.isInitialized) return '';
    final raw = dotenv.env[key]?.trim() ?? '';
    if (raw.length >= 2 &&
        ((raw.startsWith('"') && raw.endsWith('"')) ||
            (raw.startsWith("'") && raw.endsWith("'")))) {
      return raw.substring(1, raw.length - 1).trim();
    }
    return raw;
  }

  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;

  static bool get liveAiReady => hasGeminiKey && !forceMock;
}
