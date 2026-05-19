import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/app_env.dart';
import 'core/constants/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/firebase_bootstrap.dart';
import 'core/services/firebase_seeder.dart';
import 'core/providers/service_providers.dart';
import 'core/providers/demo_provider.dart';
import 'core/providers/firebase_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppEnv.load();
  debugPrint(
    'DarkhwastAI: model=${AppEnv.geminiModel}, liveAiReady=${AppEnv.liveAiReady}, '
    'hasGeminiKey=${AppEnv.hasGeminiKey}, forceMock=${AppEnv.forceMock}',
  );

  final prefs = await SharedPreferences.getInstance();
  final firebaseReady = await FirebaseBootstrap.initialize();

  final container = ProviderContainer(
    overrides: [
      sharedPrefsProvider.overrideWithValue(prefs),
      firebaseReadyProvider.overrideWithValue(firebaseReady),
    ],
  );

  if (firebaseReady) {
    try {
      final firestore = container.read(firestoreServiceProvider);
      await FirebaseSeeder.seedIfNeeded(firestore);
    } catch (e) {
      debugPrint('Firestore seeding failed: $e');
      await FirebaseBootstrap.setCloudNetwork(false);
    }
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const DarkhwastAI(),
    ),
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
