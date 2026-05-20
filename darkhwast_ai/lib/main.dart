import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/app_env.dart';
import 'core/constants/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/firebase_bootstrap.dart';
import 'core/services/firebase_seeder.dart';
import 'core/services/user_api_key_store.dart';
import 'core/providers/service_providers.dart';
import 'core/providers/shared_prefs_provider.dart';
import 'core/providers/ai_mode_provider.dart';
import 'core/providers/firebase_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final keyStore = UserApiKeyStore();
  final userKey = await keyStore.readGeminiKey();
  await AppEnv.load(userGeminiKey: userKey);
  debugPrint(
    'DarkhwastAI: model=${AppEnv.geminiModel}, liveAiReady=${AppEnv.liveAiReady}, '
    'hasGeminiKey=${AppEnv.hasGeminiKey}, forceMock=${AppEnv.forceMock}',
  );
  final firebaseReady = await FirebaseBootstrap.initialize();

  final container = ProviderContainer(
    overrides: [
      sharedPrefsProvider.overrideWithValue(prefs),
      firebaseReadyProvider.overrideWithValue(firebaseReady),
      userApiKeyStoreProvider.overrideWithValue(keyStore),
    ],
  );

  if (firebaseReady && FirebaseBootstrap.cloudNetworkEnabled) {
    try {
      final firestore = container.read(firestoreServiceProvider);
      await FirebaseSeeder.seedIfNeeded(firestore);
    } catch (e) {
      debugPrint('Firestore seeding failed: $e');
      await FirebaseBootstrap.setCloudNetwork(false);
    }
  } else if (firebaseReady) {
    debugPrint('Firestore seed skipped — device offline');
  }

  runApp(
    UncontrolledProviderScope(container: container, child: const DarkhwastAI()),
  );
}

class DarkhwastAI extends StatelessWidget {
  const DarkhwastAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DarkhwastAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
