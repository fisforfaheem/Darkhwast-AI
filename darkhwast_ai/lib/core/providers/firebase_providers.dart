import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_bootstrap.dart';

/// Set via [ProviderContainer] override in `main.dart` after bootstrap.
final firebaseReadyProvider =
    Provider<bool>((ref) => FirebaseBootstrap.isReady);

final firebaseConfiguredProvider =
    Provider<bool>((ref) => FirebaseBootstrap.isConfigured);
