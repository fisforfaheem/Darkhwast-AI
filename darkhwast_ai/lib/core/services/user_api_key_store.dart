import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Device-local Gemini key (never bundled in APK assets).
class UserApiKeyStore {
  UserApiKeyStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _geminiKey = 'user_gemini_api_key';

  final FlutterSecureStorage _storage;

  Future<String?> readGeminiKey() => _storage.read(key: _geminiKey);

  Future<void> writeGeminiKey(String key) async {
    final trimmed = key.trim();
    if (trimmed.isEmpty) {
      await clearGeminiKey();
      return;
    }
    await _storage.write(key: _geminiKey, value: trimmed);
  }

  Future<void> clearGeminiKey() => _storage.delete(key: _geminiKey);

  Future<bool> hasGeminiKey() async {
    final k = await readGeminiKey();
    return k != null && k.isNotEmpty;
  }
}
