import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

/// Whether Firebase initialized with real project credentials (not mock stub).
class FirebaseBootstrap {
  static bool isReady = false;
  static bool cloudNetworkEnabled = false;
  static User? currentUser;

  /// Human-readable reason when cloud is unavailable (shown in About/debug).
  static String? lastError;

  static bool get isConfigured =>
      DefaultFirebaseOptions.currentPlatform.apiKey != 'mock-api-key';

  /// Quick DNS probe — avoids enabling Firestore when offline (log spam / hangs).
  static Future<bool> hasReachableCloud() async {
    try {
      final result = await InternetAddress.lookup(
        'firestore.googleapis.com',
      ).timeout(const Duration(seconds: 4));
      return result.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> initialize() async {
    lastError = null;

    if (!isConfigured) {
      lastError = 'Firebase not configured — run flutterfire configure';
      debugPrint('Firebase: $lastError');
      isReady = false;
      return false;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await setCloudNetwork(false);

      try {
        final credential = await FirebaseAuth.instance.signInAnonymously();
        currentUser = credential.user;
        isReady = true;
        lastError = null;
        debugPrint('Firebase: connected as anonymous user ${currentUser?.uid}');

        final online = await tryEnableCloudNetwork();
        if (!online) {
          debugPrint(
            'Firebase: offline mode — no DNS for firestore.googleapis.com',
          );
        }
        return true;
      } on FirebaseAuthException catch (e) {
        lastError =
            e.code == 'configuration-not-found' ||
                (e.message?.contains('CONFIGURATION_NOT_FOUND') ?? false)
            ? 'Enable Anonymous sign-in in Firebase Console → Authentication'
            : '${e.code}: ${e.message}';
        debugPrint('Firebase Auth failed: $lastError');
        isReady = false;
        await setCloudNetwork(false);
        return false;
      }
    } catch (e, stack) {
      lastError = e.toString();
      debugPrint('Firebase bootstrap failed: $e\n$stack');
      isReady = false;
      await setCloudNetwork(false);
      return false;
    }
  }

  /// Enables Firestore network only when the device can reach Google cloud.
  static Future<bool> tryEnableCloudNetwork() async {
    if (!isConfigured || !isReady) return false;
    if (cloudNetworkEnabled) return true;

    if (!await hasReachableCloud()) {
      lastError = 'No internet — app works offline with local data';
      await setCloudNetwork(false);
      return false;
    }

    await setCloudNetwork(true);
    return cloudNetworkEnabled;
  }

  /// Stops Firestore watch streams from retrying when offline (DNS / no network).
  static Future<void> setCloudNetwork(bool enabled) async {
    if (!isConfigured) return;
    try {
      if (enabled) {
        await FirebaseFirestore.instance.enableNetwork();
        cloudNetworkEnabled = true;
      } else {
        await FirebaseFirestore.instance.disableNetwork();
        cloudNetworkEnabled = false;
        debugPrint('Firestore: network disabled — using local storage');
      }
    } catch (e) {
      cloudNetworkEnabled = false;
      debugPrint('Firestore network toggle failed: $e');
    }
  }
}
