import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_env.dart';

class DemoModeNotifier extends StateNotifier<bool> {
  static const _key = 'demo_mode_enabled';
  final SharedPreferences prefs;

  /// Default: Demo OFF when live Gemini is configured; ON otherwise (judge fallback).
  DemoModeNotifier(this.prefs)
      : super(prefs.getBool(_key) ?? !AppEnv.liveAiReady);

  Future<void> toggle() async {
    state = !state;
    await prefs.setBool(_key, state);
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

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(); // Should be overridden in main.dart
});

final demoModeProvider = StateNotifierProvider<DemoModeNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return DemoModeNotifier(prefs);
});

final demoScenarioProvider =
    StateNotifierProvider<DemoScenarioNotifier, String>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return DemoScenarioNotifier(prefs);
});
