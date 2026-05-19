import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/case_entity.dart';
import '../models/collective_cluster.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> saveCase(CaseEntity caseData) async {
    await _db.collection('cases').doc(caseData.id).set(caseData.toJson());
    return caseData.id;
  }

  Stream<List<CaseEntity>> getCases() {
    return _db
        .collection('cases')
        .orderBy('filedDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CaseEntity.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<CollectiveCluster?> findCollectiveCluster(
      String authority, String violationType) async {
    final snapshot = await _db
        .collection('collectiveCases')
        .where('authority', isEqualTo: authority)
        .where('violationType', isEqualTo: violationType)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return CollectiveCluster.fromJson({
        ...doc.data(),
        'id': doc.id,
      });
    }
    return null;
  }

  Future<void> joinCollectiveCase(String clusterId, String caseId) async {
    await _db.collection('collectiveCases').doc(clusterId).set({
      'caseIds': FieldValue.arrayUnion([caseId]),
      'count': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  Future<void> scheduleFollowUps(String caseId) async {
    final now = DateTime.now();
    final followUpCollection = _db.collection('followUps');

    final intervals = [7, 14, 30];
    for (int days in intervals) {
      await followUpCollection.add({
        'caseId': caseId,
        'scheduledDate': now.add(Duration(days: days)).toIso8601String(),
        'status': 'PENDING',
        'type': days == 30 ? 'ESCALATION' : 'REMINDER',
      });
    }
  }

  Future<Map<String, dynamic>?> getLawKnowledge(String docType) async {
    final snapshot = await _db.collection('knowledgeBase').doc(docType).get();
    return snapshot.data();
  }

  Future<void> seedKnowledgeBase() async {
    final batch = _db.batch();

    final laws = {
      "ELECTRICITY_BILL": {
        "authority": "NEPRA",
        "regulation": "Quarterly Tariff Adjustment Circular May 2025",
        "section": "4(b)",
        "rule": "FCA charges cannot exceed approved rate per consumption slab",
        "slabs": {
          "B1_0_100": {"maxFCA": 800},
          "B1_101_200": {"maxFCA": 1200},
          "B1_201_300": {"maxFCA": 1600},
          "B2_301_500": {"maxFCA": 2200},
          "B2_500plus": {"maxFCA": 3100}
        },
        "complaintAuthority": "NEPRA Consumer Affairs",
        "responseWindow": 14
      },
      "GAS_BILL": {
        "authority": "OGRA",
        "regulation": "OGRA Consumer Protection Regulations 2018",
        "section": "12(a)",
        "rule": "Meter reading must match actual reading within 5% variance",
        "complaintAuthority": "OGRA Complaint Cell",
        "responseWindow": 21
      },
      "BISP_LETTER": {
        "authority": "BISP",
        "regulation": "BISP Grievance Redressal Mechanism 2023",
        "section": "Section 6",
        "rule": "Every rejected applicant has right to appeal within 60 days",
        "complaintAuthority": "BISP Tehsil Office + Portal",
        "responseWindow": 30
      },
      "TAX_NOTICE": {
        "authority": "FBR",
        "regulation": "Income Tax Ordinance 2001",
        "section": "122",
        "rule": "Assessment notice must be responded to within 30 days",
        "complaintAuthority": "FBR Facilitation Center",
        "responseWindow": 7,
        "urgency": "HIGH"
      }
    };

    laws.forEach((key, value) {
      batch.set(_db.collection('knowledgeBase').doc(key), value);
    });

    await batch.commit();
  }

  Future<void> seedCollectiveCases() async {
    final cluster = {
      "id": "cluster_IESCO_FCA_ISB_May2026",
      "authority": "IESCO",
      "violationType": "FCA_Overcharge",
      "area": "Islamabad",
      "month": "May 2026",
      "count": 29,
      "status": "Open",
      "collectivePetitionDrafted": true
    };

    await _db
        .collection('collectiveCases')
        .doc(cluster['id'] as String)
        .set(cluster);
  }
}
