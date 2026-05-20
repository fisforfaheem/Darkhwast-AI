import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/document_entity.dart';
import '../models/rights_analysis.dart';
import '../models/complaint_draft.dart';
import '../models/user_intent.dart';

class GeminiException implements Exception {
  final String message;
  GeminiException(this.message);
  @override
  String toString() => "GeminiException: $message";
}

class GeminiService {
  final String? apiKey;
  final String model;
  final bool useMock;

  GeminiService({this.apiKey, required this.model, this.useMock = false});

  static Future<bool> validateApiKey(String key) async {
    try {
      final modelInstance = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: key.trim(),
      );
      final response = await modelInstance
          .generateContent([Content.text('test')])
          .timeout(const Duration(seconds: 5));
      return response.text != null;
    } catch (e) {
      return false;
    }
  }

  GenerativeModel? get _model => apiKey != null && apiKey!.isNotEmpty
      ? GenerativeModel(model: model, apiKey: apiKey!)
      : null;

  Future<DocumentEntity> analyzeDocument(String text) async {
    if (useMock) {
      return _mockDocument();
    }
    if (_model == null) {
      throw GeminiException(
        'GEMINI_API_KEY missing. Add it to darkhwast_ai/.env or enable Demo Mode.',
      );
    }

    try {
      final prompt =
          '''
      You are a document analysis agent for Pakistani government documents.
      You can analyze ANY kind of Pakistani document including but not limited to:
      electricity bills, gas bills, water bills, property tax notices, 
      BISP letters, FBR tax notices, NADRA documents, pension notices,
      police challans, school fee slips, municipal notices, court notices,
      government forms, legal notices, and any other official document.
      
      Analyze this document text and return ONLY valid JSON with this exact structure:
      {
        "documentType": "ELECTRICITY_BILL | GAS_BILL | BISP_LETTER | TAX_NOTICE | COURT_NOTICE | WATER_BILL | PROPERTY_TAX | PENSION_NOTICE | NADRA_DOCUMENT | POLICE_CHALLAN | SCHOOL_FEE | MUNICIPAL_NOTICE | GOVERNMENT_FORM | LEGAL_NOTICE | OTHER | UNKNOWN",
        "authority": "string (e.g. IESCO, SNGPL, BISP, FBR, NADRA, WASA, etc.)",
        "consumerRef": "string or null",
        "amounts": [{"label": "string", "amount": number, "currency": "PKR"}],
        "dates": [{"label": "string", "date": "YYYY-MM-DD or null"}],
        "deadlines": [{"label": "string", "date": "YYYY-MM-DD", "daysRemaining": number, "isHidden": boolean}],
        "keyFacts": ["string array of 3-5 critical extracted facts"],
        "rawAmountsBilled": {"total": number, "breakdown": {}}
      }
      Document text: $text
      ''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      final jsonStr = _extractJson(response.text ?? '{}');
      return DocumentEntity.fromJson(jsonDecode(jsonStr));
    } catch (e) {
      throw GeminiException("Document analysis failed: ${e.toString()}");
    }
  }

  Future<RightsAnalysis> analyzeRights(
    DocumentEntity doc,
    Map<String, dynamic> law,
  ) async {
    if (useMock) {
      return _mockRights();
    }
    if (_model == null) {
      throw GeminiException(
        'GEMINI_API_KEY missing. Add it to darkhwast_ai/.env or enable Demo Mode.',
      );
    }

    try {
      final prompt =
          '''
      You are Pakistan's citizen rights legal AI. You know NEPRA, OGRA, BISP, FBR, NADRA,
      WASA, municipal, provincial and federal regulations precisely.
      Given this document analysis: ${jsonEncode(doc.toJson())}
      And this law knowledge entry: ${jsonEncode(law)}
      Return ONLY valid JSON:
      {
        "violationDetected": boolean,
        "violationType": "string",
        "legalBasis": "exact regulation name + section",
        "maxAllowed": number,
        "actualCharged": number,
        "amountOwed": number,
        "haqScore": number (0-100),
        "haqReasoning": "1-2 sentences explaining the score in simple Urdu-friendly language",
        "precedents": "string describing similar resolved cases",
        "confidenceLevel": "HIGH | MEDIUM | LOW"
      }
      ''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      final jsonStr = _extractJson(response.text ?? '{}');
      return RightsAnalysis.fromJson(jsonDecode(jsonStr));
    } catch (e) {
      throw GeminiException("Rights analysis failed: ${e.toString()}");
    }
  }

  /// Intent-aware action drafting.
  /// Generates different document types based on user intent.
  Future<ActionDraft> draftAction(
    RightsAnalysis analysis,
    DocumentEntity doc,
    UserIntentSelection intentSelection,
  ) async {
    if (useMock) {
      return _mockDraft();
    }
    if (_model == null) {
      throw GeminiException(
        'GEMINI_API_KEY missing. Add it to darkhwast_ai/.env or enable Demo Mode.',
      );
    }

    try {
      final prompt = _buildActionPrompt(analysis, doc, intentSelection);
      final response = await _model!.generateContent([Content.text(prompt)]);
      final jsonStr = _extractJson(response.text ?? '{}');
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      json['actionType'] = intentSelection.intent.name;
      json['actionSummary'] = json['actionSummary'] ?? 'Action draft generated';
      return ActionDraft.fromJson(json);
    } catch (e) {
      throw GeminiException("Action drafting failed: ${e.toString()}");
    }
  }

  /// Backward-compatible complaint-only draft.
  Future<ActionDraft> draftComplaint(
    RightsAnalysis analysis,
    DocumentEntity doc,
  ) async {
    return draftAction(analysis, doc, UserIntentSelection.auto());
  }

  String _buildActionPrompt(
    RightsAnalysis analysis,
    DocumentEntity doc,
    UserIntentSelection intentSelection,
  ) {
    final intent = intentSelection.intent;
    final customText = intentSelection.customText ?? '';

    final commonContext =
        '''
    Document: ${doc.type.displayName}
    Authority: ${doc.authority}
    Violation: ${analysis.violationType}
    Amount: Rs. ${analysis.amountOwed}
    Legal Basis: ${analysis.legalBasis}
    Consumer Reference: ${doc.consumerRef ?? 'N/A'}
    ''';

    String actionInstruction;
    switch (intent) {
      case UserIntent.explainDocument:
        actionInstruction = '''
        Explain what this document says in simple, plain language that a common Pakistani citizen can understand.
        Include: what is being charged, why, what dates matter, and what the citizen should know.
        The "urduDraft" should be the explanation in Urdu script (Perso-Arabic), NOT Roman Urdu.
        The "englishDraft" should be the explanation in English.
        The "subject" should summarize the document type and key finding.
        Set "documentExplanation" to a concise 2-3 line plain-language summary.
        ''';
        break;
      case UserIntent.findIssues:
        actionInstruction = '''
        Write a detailed issue report listing all problems, errors, overcharges, or violations found in the document.
        Include specific amounts, legal references, and what the citizen can do about each issue.
        Format it as a formal issue report letter.
        ''';
        break;
      case UserIntent.writeAppeal:
        actionInstruction = '''
        Write a formal appeal letter challenging the decision or charges in this document.
        Cite relevant Pakistani law sections, mention the specific violation, and request a review/reversal.
        Make it respectful but firm, with clear legal standing.
        ''';
        break;
      case UserIntent.requestReduction:
        actionInstruction = '''
        Write a formal application requesting reduction in the charges/fees/penalties in this document.
        Cite economic hardship, legal provisions for reduction, and the specific amount of reduction requested.
        Make it a formal application to the relevant authority.
        ''';
        break;
      case UserIntent.requestCorrection:
        actionInstruction = '''
        Write a formal correction request to fix errors in this document.
        Specify exactly what data is incorrect, what the correct information should be, 
        and cite any consumer protection rules about accurate billing/records.
        ''';
        break;
      case UserIntent.customAction:
        actionInstruction =
            '''
        The citizen wants the following action: "$customText"
        Based on the document analysis, draft the appropriate formal letter/application 
        that fulfills what the citizen is asking for.
        ''';
        break;
      case UserIntent.fileComplaint:
      case UserIntent.autoDetect:
        actionInstruction = '''
        Write a formal complaint letter to the relevant authority about this violation.
        Cite the specific law section, state the exact amount claimed, and request resolution.
        Make it professional.
        ''';
        break;
    }

    return '''
    You are a Pakistani citizen rights document drafting agent.
    
    $commonContext
    
    ACTION REQUIRED: ${intent.displayName}
    $actionInstruction
    
    Return ONLY valid JSON:
    {
      "urduDraft": "Full draft in formal Urdu script (Perso-Arabic / Nastaliq-compatible). NEVER use Roman Urdu or Latin transliteration.",
      "englishDraft": "Full draft in formal English",
      "subject": "Subject line in English",
      "submissionAuthority": "Authority name",
      "submissionPortal": "Portal name (mock URL)",
      "estimatedResponseDays": number,
      "actionSummary": "One-line summary of what was drafted",
      "documentExplanation": "Plain-language explanation (for explain mode, null otherwise)"
    }

    Do NOT use placeholder brackets in the output — use actual values.
    For urduDraft: write ONLY in Urdu script (e.g. "بخدمت جناب،" / "محترم جناب،"). 
    NEVER use Roman Urdu transliteration (e.g. "Bakhidmat Janab" / "Main aap ki tawajjo").
    ''';
  }

  Future<DocumentEntity> _mockDocument() async {
    final response = await rootBundle.loadString(
      'assets/mock_responses/electricity_bill_response.json',
    );
    final data = jsonDecode(response);
    return DocumentEntity.fromJson(data['docIntel']);
  }

  Future<RightsAnalysis> _mockRights() async {
    final response = await rootBundle.loadString(
      'assets/mock_responses/electricity_bill_response.json',
    );
    final data = jsonDecode(response);
    return RightsAnalysis.fromJson(data['rightsAnalysis']);
  }

  Future<ActionDraft> _mockDraft() async {
    final response = await rootBundle.loadString(
      'assets/mock_responses/electricity_bill_response.json',
    );
    final data = jsonDecode(response);
    return ActionDraft.fromJson(data['complaintDraft']);
  }

  String _extractJson(String text) {
    if (text.contains('```json')) {
      return text.split('```json')[1].split('```')[0].trim();
    } else if (text.contains('```')) {
      return text.split('```')[1].split('```')[0].trim();
    }
    return text.trim();
  }
}
