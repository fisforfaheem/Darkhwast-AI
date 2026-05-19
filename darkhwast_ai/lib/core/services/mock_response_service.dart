import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/document_entity.dart';
import '../models/rights_analysis.dart';
import '../models/complaint_draft.dart';

class MockResponseService {
  static Future<Map<String, dynamic>> _loadJson(String fileName) async {
    final String response =
        await rootBundle.loadString('assets/mock_responses/$fileName');
    return json.decode(response) as Map<String, dynamic>;
  }

  static Future<DocumentEntity> getMockDocument(String scenario) async {
    final data = await _loadJson('${scenario}_response.json');
    final docData = data['docIntel'] as Map<String, dynamic>? ?? data;
    return DocumentEntity.fromJson(docData);
  }

  static Future<RightsAnalysis> getMockRights(String scenario) async {
    final data = await _loadJson('${scenario}_response.json');
    final rightsData = data['rightsAnalysis'] as Map<String, dynamic>? ??
        {
          "violationDetected": true,
          "violationType": "FCA Overcharge",
          "legalBasis": "NEPRA QTA Circular May 2025",
          "maxAllowed": 2200,
          "actualCharged": 3800,
          "amountOwed": 1600,
          "haqScore": 81,
          "haqReasoning": "Aap se illegal extra charges liye gaye hain.",
          "confidenceLevel": "HIGH"
        };
    return RightsAnalysis.fromJson(rightsData);
  }

  static Future<ActionDraft> getMockDraft(String scenario) async {
    final data = await _loadJson('${scenario}_response.json');
    final draftData =
        data['complaintDraft'] ?? data['actionDraft'] as Map<String, dynamic>? ??
            {
              "urduDraft": "یہ ایک فرضی شکایت خط ہے۔۔۔",
              "englishDraft": "This is a mock complaint letter...",
              "subject": "FCA Overcharge Complaint",
              "submissionAuthority": "NEPRA",
              "submissionPortal": "complaints.nepra.org.pk",
              "estimatedResponseDays": 14
            };
    return ActionDraft.fromJson(Map<String, dynamic>.from(draftData));
  }
}
