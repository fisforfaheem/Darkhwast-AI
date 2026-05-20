import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_mode_provider.dart';
import 'shared_prefs_provider.dart';

class DemoModeNotifier extends StateNotifier<bool> {
  static const _key = 'demo_mode_enabled';
  final SharedPreferences prefs;

  /// Synced with [AiMode]: curated demo ON by default after setup.
  DemoModeNotifier(this.prefs) : super(prefs.getBool(_key) ?? true);

  static bool fromPrefs(SharedPreferences prefs) {
    final mode = prefs.getString('ai_mode');
    if (mode == AiMode.userGeminiKey.name) return false;
    return prefs.getBool(_key) ?? true;
  }

  Future<void> toggle() async {
    state = !state;
    await prefs.setBool(_key, state);
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await prefs.setBool(_key, enabled);
  }
}

/// Mock JSON file prefix: `electricity_bill` or `tax_notice`.
class DemoScenarioNotifier extends StateNotifier<String> {
  static const _key = 'demo_scenario';
  final SharedPreferences prefs;

  DemoScenarioNotifier(this.prefs)
      : super(prefs.getString(_key) ?? 'electricity_bill');

  Future<void> setScenario(String scenario) async {
    state = scenario;
    await prefs.setString(_key, scenario);
  }
}

final demoModeProvider = StateNotifierProvider<DemoModeNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return DemoModeNotifier(prefs);
});

final demoScenarioProvider =
    StateNotifierProvider<DemoScenarioNotifier, String>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return DemoScenarioNotifier(prefs);
});
