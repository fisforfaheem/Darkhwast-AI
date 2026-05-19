import 'package:flutter/foundation.dart';
import '../models/collective_cluster.dart';
import 'firestore_service.dart';
import 'seed_data.dart';

/// Law KB + collective clusters: bundled locally, cloud when Firebase auth works.
class LawKnowledgeService {
  final FirestoreService _firestore;
  final bool _cloudEnabled;

  LawKnowledgeService({
    required FirestoreService firestore,
    required bool cloudEnabled,
  })  : _firestore = firestore,
        _cloudEnabled = cloudEnabled;

  Future<Map<String, dynamic>?> getLawKnowledge(String docType) async {
    if (_cloudEnabled) {
      try {
        final remote = await _firestore.getLawKnowledge(docType);
        if (remote != null && remote.isNotEmpty) return remote;
      } catch (e) {
        debugPrint('LawKnowledgeService: cloud KB failed ($docType): $e');
      }
    }
    return SeedData.knowledgeFor(docType);
  }

  Future<CollectiveCluster?> findCollectiveCluster(
    String authority,
    String violationType,
  ) async {
    if (_cloudEnabled) {
      try {
        final remote = await _firestore.findCollectiveCluster(
          authority,
          violationType,
        );
        if (remote != null) return remote;
      } catch (e) {
        debugPrint('LawKnowledgeService: collective query failed: $e');
      }
    }
    return SeedData.collectiveFor(authority, violationType);
  }
}
