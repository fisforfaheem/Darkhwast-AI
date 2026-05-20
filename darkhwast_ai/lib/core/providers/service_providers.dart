import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_env.dart';
import '../services/gemini_service.dart';
import '../services/firestore_service.dart';
import '../services/law_knowledge_service.dart';
import '../services/ocr_service.dart';
import '../services/voice_service.dart';
import 'ai_mode_provider.dart';
import 'firebase_providers.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  ref.watch(aiModeProvider);
  return GeminiService(
    apiKey: AppEnv.geminiApiKey,
    model: AppEnv.geminiModel,
    useMock: AppEnv.forceMock || !AppEnv.hasGeminiKey,
  );
});

final ocrServiceProvider = Provider<OCRService>((ref) {
  return OCRService();
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final voiceServiceProvider = Provider<VoiceService>((ref) {
  return VoiceService();
});

final lawKnowledgeServiceProvider = Provider<LawKnowledgeService>((ref) {
  return LawKnowledgeService(
    firestore: ref.watch(firestoreServiceProvider),
    cloudEnabled: ref.watch(firebaseCloudSyncProvider),
  );
});

final liveAiReadyProvider = Provider<bool>((ref) => AppEnv.liveAiReady);
