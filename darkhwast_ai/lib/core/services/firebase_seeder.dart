import 'package:shared_preferences/shared_preferences.dart';
import '../services/firestore_service.dart';

class FirebaseSeeder {
  static const String _seedKey = 'firebase_seeded_v1';

  static Future<void> seedIfNeeded(FirestoreService firestore) async {
    final prefs = await SharedPreferences.getInstance();
    final isSeeded = prefs.getBool(_seedKey) ?? false;

    if (!isSeeded) {
      await firestore.seedKnowledgeBase();
      await firestore.seedCollectiveCases();
      await prefs.setBool(_seedKey, true);
    }
  }
}
