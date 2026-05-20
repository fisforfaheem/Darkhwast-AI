import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_env.dart';
import '../services/user_api_key_store.dart';
import 'shared_prefs_provider.dart';

enum AiMode { curatedDemo, userGeminiKey }

class AiModeNotifier extends StateNotifier<AiMode> {
  static const _modeKey = 'ai_mode';
  static const _setupCompleteKey = 'ai_setup_completed';

  AiModeNotifier(this._prefs, this._keyStore) : super(_loadMode(_prefs));

  final SharedPreferences _prefs;
  final UserApiKeyStore _keyStore;

  static AiMode _loadMode(SharedPreferences prefs) {
    final raw = prefs.getString(_modeKey);
    if (raw == AiMode.userGeminiKey.name) return AiMode.userGeminiKey;
    return AiMode.curatedDemo;
  }

  static bool isSetupComplete(SharedPreferences prefs) =>
      prefs.getBool(_setupCompleteKey) ?? false;

  Future<void> completeSetupCuratedDemo() async {
    state = AiMode.curatedDemo;
    await _prefs.setString(_modeKey, AiMode.curatedDemo.name);
    await _prefs.setBool(_setupCompleteKey, true);
    await _prefs.setBool('demo_mode_enabled', true);
    await _keyStore.clearGeminiKey();
    await AppEnv.applyUserGeminiKey(null);
  }

  Future<void> completeSetupWithUserKey(String apiKey) async {
    await _keyStore.writeGeminiKey(apiKey);
    state = AiMode.userGeminiKey;
    await _prefs.setString(_modeKey, AiMode.userGeminiKey.name);
    await _prefs.setBool(_setupCompleteKey, true);
    await _prefs.setBool('demo_mode_enabled', false);
    await AppEnv.applyUserGeminiKey(apiKey.trim());
  }

  Future<void> switchToCuratedDemo() async {
    state = AiMode.curatedDemo;
    await _prefs.setString(_modeKey, AiMode.curatedDemo.name);
    await _prefs.setBool('demo_mode_enabled', true);
    await _keyStore.clearGeminiKey();
    await AppEnv.applyUserGeminiKey(null);
  }

  Future<void> switchToUserKey(String apiKey) async {
    await _keyStore.writeGeminiKey(apiKey);
    state = AiMode.userGeminiKey;
    await _prefs.setString(_modeKey, AiMode.userGeminiKey.name);
    await _prefs.setBool('demo_mode_enabled', false);
    await AppEnv.applyUserGeminiKey(apiKey.trim());
  }

  Future<String?> readStoredKey() => _keyStore.readGeminiKey();
}

final userApiKeyStoreProvider = Provider<UserApiKeyStore>((ref) {
  return UserApiKeyStore();
});

final aiModeProvider = StateNotifierProvider<AiModeNotifier, AiMode>((ref) {
  return AiModeNotifier(
    ref.watch(sharedPrefsProvider),
    ref.watch(userApiKeyStoreProvider),
  );
});

final aiSetupCompleteProvider = Provider<bool>((ref) {
  return AiModeNotifier.isSetupComplete(ref.watch(sharedPrefsProvider));
});

final isCuratedDemoProvider = Provider<bool>((ref) {
  return ref.watch(aiModeProvider) == AiMode.curatedDemo;
});
