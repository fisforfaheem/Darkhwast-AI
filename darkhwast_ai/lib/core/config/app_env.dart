import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime secrets and flags from `.env` (local) or `--dart-define` (CI).
class AppEnv {
  AppEnv._();

  static bool _loaded = false;

  static String geminiApiKey = '';

  /// Gemini API model id — see https://ai.google.dev/gemini-api/docs/models
  static String geminiModel = _defaultGeminiModel;

  /// When true, GeminiService uses asset mocks (even if a key exists).
  static bool forceMock = false;

  /// Default model; override with GEMINI_MODEL in .env if needed.
  static const String _defaultGeminiModel = 'gemini-3.1-pro-preview';

  /// Latest agentic preview (Feb 2026) — set GEMINI_MODEL to this for cutting-edge.
  static const String latestAgenticModel = 'gemini-3.1-pro-preview';

  static Future<void> load() async {
    if (_loaded) return;

    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Missing .env is fine — use dart-define or demo mode.
    }

    geminiApiKey = _resolve('GEMINI_API_KEY');
    final model = _resolve('GEMINI_MODEL');
    geminiModel = model.isNotEmpty ? model : _defaultGeminiModel;
    final mockFlag = _resolve('USE_MOCK').toLowerCase();
    forceMock = mockFlag == 'true' || mockFlag == '1';

    _loaded = true;
  }

  static String _resolve(String key) {
    final fromDefine = String.fromEnvironment(key);
    if (fromDefine.isNotEmpty) return fromDefine;
    final raw = dotenv.env[key]?.trim() ?? '';
    if (raw.length >= 2 &&
        ((raw.startsWith('"') && raw.endsWith('"')) ||
            (raw.startsWith("'") && raw.endsWith("'")))) {
      return raw.substring(1, raw.length - 1).trim();
    }
    return raw;
  }

  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;

  /// Real Gemini calls when demo mode is off and this is true.
  static bool get liveAiReady => hasGeminiKey && !forceMock;
}
