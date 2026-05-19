import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/case_entity.dart';
import '../models/collective_cluster.dart';
import '../services/firebase_bootstrap.dart';
import '../services/local_case_repository.dart';
import '../services/firestore_service.dart';
import 'demo_provider.dart';
import 'firebase_providers.dart';
import 'service_providers.dart';

final localCaseRepositoryProvider = Provider<LocalCaseRepository>((ref) {
  return LocalCaseRepository(ref.watch(sharedPrefsProvider));
});

class CaseListNotifier extends StateNotifier<List<CaseEntity>> {
  final LocalCaseRepository _local;
  final FirestoreService _firestore;
  final bool _firebaseReady;
  StreamSubscription<List<CaseEntity>>? _firestoreSub;
  bool _cloudSyncActive = false;

  CaseListNotifier(this._local, this._firestore, this._firebaseReady)
      : super([]) {
    _cloudSyncActive = _firebaseReady && FirebaseBootstrap.cloudNetworkEnabled;
    if (_cloudSyncActive) {
      _subscribeFirestore();
    }
    _loadLocal();
  }

  void _subscribeFirestore() {
    _firestoreSub?.cancel();
    _firestoreSub = _firestore.getCases().listen(
      (cases) {
        if (cases.isNotEmpty) {
          state = cases;
        } else {
          _loadLocal();
        }
      },
      onError: (e) {
        debugPrint('Firestore cases stream error: $e');
        _stopCloudSync();
        _loadLocal();
      },
      cancelOnError: true,
    );
  }

  Future<void> _stopCloudSync() async {
    _cloudSyncActive = false;
    _firestoreSub?.cancel();
    _firestoreSub = null;
    await FirebaseBootstrap.setCloudNetwork(false);
  }

  Future<void> _loadLocal() async {
    final local = await _local.getCases();
    if (local.isNotEmpty) {
      state = local;
    } else if (!_cloudSyncActive) {
      state = local;
    }
  }

  Future<void> loadCases() async {
    if (_firebaseReady) {
      try {
        await FirebaseBootstrap.setCloudNetwork(true);
        _cloudSyncActive = true;
        final snap = await _firestore
            .getCases()
            .first
            .timeout(const Duration(seconds: 8));
        if (snap.isNotEmpty) {
          state = snap;
          if (_firestoreSub == null) _subscribeFirestore();
          return;
        }
      } catch (e) {
        debugPrint('Firestore loadCases failed: $e');
        await _stopCloudSync();
      }
    }
    await _loadLocal();
  }

  Future<void> addCase(
    CaseEntity caseData, {
    CollectiveCluster? cluster,
    bool joinedCollective = false,
  }) async {
    await _local.saveCase(caseData);
    state = [
      caseData,
      ...state.where((c) => c.id != caseData.id),
    ];

    if (_firebaseReady && _cloudSyncActive) {
      try {
        await _firestore.saveCase(caseData);
        await _firestore.scheduleFollowUps(caseData.id);
        if (joinedCollective) {
          final clusterId = cluster?.id ?? 'cluster_IESCO_FCA_ISB_May2026';
          await _firestore.joinCollectiveCase(clusterId, caseData.id);
        }
      } catch (e) {
        debugPrint('Firestore saveCase failed (local copy kept): $e');
        await _stopCloudSync();
      }
    }

    await _loadLocal();
  }

  @override
  void dispose() {
    _firestoreSub?.cancel();
    super.dispose();
  }
}

final caseListProvider =
    StateNotifierProvider<CaseListNotifier, List<CaseEntity>>((ref) {
  return CaseListNotifier(
    ref.watch(localCaseRepositoryProvider),
    ref.watch(firestoreServiceProvider),
    ref.watch(firebaseReadyProvider),
  );
});

/// Whether the user chose collective action on the HAQ dashboard.
final joinCollectiveProvider = StateProvider<bool>((ref) => false);
