import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/document_entity.dart';
import '../models/rights_analysis.dart';
import '../models/complaint_draft.dart';
import '../models/collective_cluster.dart';
import '../models/user_intent.dart';

class DemoAgentMessages {
  const DemoAgentMessages({
    this.docIntel,
    this.urgency,
    this.rights,
    this.drafter,
    this.pattern,
  });

  final String? docIntel;
  final String? urgency;
  final String? rights;
  final String? drafter;
  final String? pattern;
}

class MockResponseService {
  static Future<Map<String, dynamic>> _loadJson(String fileName) async {
    final String response =
        await rootBundle.loadString('assets/mock_responses/$fileName');
    return json.decode(response) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> _loadScenario(String scenario) async {
    return _loadJson('${scenario}_response.json');
  }

  static Future<DocumentEntity> getMockDocument(String scenario) async {
    final data = await _loadScenario(scenario);
    final docData = data['docIntel'] as Map<String, dynamic>? ?? data;
    return DocumentEntity.fromJson(docData);
  }

  static Future<RightsAnalysis> getMockRights(String scenario) async {
    final data = await _loadScenario(scenario);
    final rightsData = data['rightsAnalysis'] as Map<String, dynamic>? ??
        {
          'violationDetected': true,
          'violationType': 'FCA Overcharge',
          'legalBasis': 'NEPRA QTA Circular May 2025',
          'maxAllowed': 2200,
          'actualCharged': 3800,
          'amountOwed': 1600,
          'haqScore': 81,
          'haqReasoning': 'Aap se illegal extra charges liye gaye hain.',
          'confidenceLevel': 'HIGH',
        };
    return RightsAnalysis.fromJson(rightsData);
  }

  static Future<ActionDraft> getMockDraft(
    String scenario, {
    UserIntent? intent,
  }) async {
    final data = await _loadScenario(scenario);
    final intentKey = intent?.name ?? 'fileComplaint';
    final byIntent = data['draftsByIntent'] as Map<String, dynamic>?;
    Map<String, dynamic>? draftData;
    if (byIntent != null && byIntent[intentKey] != null) {
      draftData = Map<String, dynamic>.from(byIntent[intentKey] as Map);
    }
    draftData ??= data['complaintDraft'] as Map<String, dynamic>? ??
        data['actionDraft'] as Map<String, dynamic>?;
    draftData ??= {
      'urduDraft': 'یہ ایک فرضی شکایت خط ہے۔',
      'englishDraft': 'This is a mock complaint letter...',
      'subject': 'Complaint',
      'submissionAuthority': 'Authority',
      'submissionPortal': 'portal.gov.pk',
      'estimatedResponseDays': 14,
    };
    if (intent != null) {
      draftData['actionType'] = intent.name;
    }
    return ActionDraft.fromJson(draftData);
  }

  static Future<CollectiveCluster?> getMockCluster(String scenario) async {
    final data = await _loadScenario(scenario);
    final cluster = data['collectiveCluster'] as Map<String, dynamic>?;
    if (cluster == null) return null;
    return CollectiveCluster.fromJson(cluster);
  }

  static Future<DemoAgentMessages> getAgentMessages(String scenario) async {
    final data = await _loadScenario(scenario);
    final messages = data['agentMessages'] as Map<String, dynamic>?;
    if (messages == null) return const DemoAgentMessages();
    return DemoAgentMessages(
      docIntel: messages['docIntel'] as String?,
      urgency: messages['urgency'] as String?,
      rights: messages['rights'] as String?,
      drafter: messages['drafter'] as String?,
      pattern: messages['pattern'] as String?,
    );
  }

  /// Per-agent pacing for curated demo (milliseconds).
  static List<int> getAgentDelaysMs(String scenario) {
    switch (scenario) {
      case 'tax_notice':
        return [1100, 900, 2200, 1900, 700];
      case 'bisp_letter':
        return [1000, 800, 2000, 1800, 500];
      default:
        return [1200, 800, 2400, 2000, 600];
    }
  }
}
