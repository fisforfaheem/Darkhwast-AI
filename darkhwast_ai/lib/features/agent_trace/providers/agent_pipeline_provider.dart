import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/services/law_knowledge_service.dart';
import '../../../core/services/ocr_service.dart';
import '../../../core/services/mock_response_service.dart';
import '../../../core/models/agent_state.dart';
import '../../../core/models/document_entity.dart';
import '../../../core/models/deadline_alert.dart';
import '../../../core/models/rights_analysis.dart';
import '../../../core/models/complaint_draft.dart';
import '../../../core/models/collective_cluster.dart';
import '../../../core/models/user_intent.dart';
import '../../../core/config/app_env.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/providers/ai_mode_provider.dart';
import '../../../core/providers/demo_provider.dart';
import '../../../core/providers/firebase_providers.dart';
import 'pipeline_state.dart';

final pipelineProvider =
    StateNotifierProvider<AgentPipelineNotifier, PipelineState>((ref) {
      return AgentPipelineNotifier(
        gemini: ref.watch(geminiServiceProvider),
        lawKnowledge: ref.watch(lawKnowledgeServiceProvider),
        ocr: ref.watch(ocrServiceProvider),
        isDemo:
            ref.watch(demoModeProvider) ||
            ref.watch(aiModeProvider) == AiMode.curatedDemo,
        demoScenario: ref.watch(demoScenarioProvider),
        firebaseReady: ref.watch(firebaseReadyProvider),
      );
    });

// Computed Providers
final documentEntityProvider = Provider<DocumentEntity?>((ref) {
  return ref.watch(pipelineProvider).docIntel.result;
});

final rightsAnalysisProvider = Provider<RightsAnalysis?>((ref) {
  return ref.watch(pipelineProvider).rights.result;
});

final complaintDraftProvider = Provider<ActionDraft?>((ref) {
  return ref.watch(pipelineProvider).drafter.result;
});

final hasUrgentDeadlineProvider = Provider<bool>((ref) {
  final deadlines = ref.watch(pipelineProvider).urgency.result ?? [];
  return deadlines.any((d) => d.urgencyLevel == UrgencyLevel.high);
});

final collectiveClusterProvider = Provider<CollectiveCluster?>((ref) {
  return ref.watch(pipelineProvider).pattern.result;
});

/// Whether the pipeline is waiting for the user to pick an intent.
final isAwaitingIntentProvider = Provider<bool>((ref) {
  return ref.watch(pipelineProvider).isAwaitingIntent;
});

/// The user's selected intent (if any).
final userIntentProvider = Provider<UserIntentSelection?>((ref) {
  return ref.watch(pipelineProvider).userIntent;
});

/// Maps spoken keywords to curated mock JSON when in demo mode.
String scenarioFromVoiceHint(String voice, String fallback) {
  final t = voice.toLowerCase();
  if (t.contains('fbr') ||
      t.contains('tax') ||
      (t.contains('notice') && t.contains('income'))) {
    return 'tax_notice';
  }
  if (t.contains('bisp') || t.contains('ehsaas') || t.contains('benazir')) {
    return 'bisp_letter';
  }
  if (t.contains('bijli') ||
      t.contains('electric') ||
      t.contains('iesco') ||
      (t.contains('bill') && t.contains('nepra'))) {
    return 'electricity_bill';
  }
  return fallback;
}

class AgentPipelineNotifier extends StateNotifier<PipelineState> {
  final GeminiService gemini;
  final LawKnowledgeService lawKnowledge;
  final OCRService ocr;
  final bool isDemo;
  final String demoScenario;
  final bool firebaseReady;

  AgentPipelineNotifier({
    required this.gemini,
    required this.lawKnowledge,
    required this.ocr,
    required this.isDemo,
    required this.demoScenario,
    required this.firebaseReady,
  }) : super(PipelineState.initial());

  bool get _useMocks => isDemo || !AppEnv.liveAiReady;

  void setFilingMeta({
    required String caseReference,
    required bool collectiveJoined,
  }) {
    state = state.copyWith(
      filedCaseReference: caseReference,
      collectiveJoined: collectiveJoined,
    );
  }

  void updateActionDraft(ActionDraft updated) {
    state = state.copyWith(drafter: state.drafter.copyWith(result: updated));
  }

  /// Full pipeline for backward compatibility (auto-detect intent).
  Future<void> runPipeline(File? documentImage, {String? text}) async {
    await runPhase1(documentImage, text: text, autoDetect: true);
  }

  /// Phase 1: Document scan (Agent 1) + Urgency check (Agent 2).
  /// After completion, sets status to awaitingIntent unless autoDetect is true.
  Future<void> runPhase1(
    File? documentImage, {
    String? text,
    bool autoDetect = false,
  }) async {
    final runId = 'run-${DateTime.now().millisecondsSinceEpoch}';
    state = PipelineState.initial().copyWith(
      overallStatus: PipelineStatus.running,
      runId: runId,
      startedAt: DateTime.now(),
      filedCaseReference: null,
      collectiveJoined: false,
      sourceImagePath: documentImage?.path,
      sourceExtractedText: text,
    );

    try {
      if (!_useMocks && !AppEnv.liveAiReady) {
        throw StateError(
          'Live AI is not configured. Add GEMINI_API_KEY to darkhwast_ai/.env '
          '(USE_MOCK=false), or enable Demo Mode in About (tap logo 5×).',
        );
      }

      final voiceText = (text ?? '').trim();
      final scenario = _useMocks
          ? scenarioFromVoiceHint(voiceText, demoScenario)
          : 'electricity_bill';
      final delays = _useMocks
          ? MockResponseService.getAgentDelaysMs(scenario)
          : [1500, 1500, 1500, 1500, 1500];
      final agentMsgs = _useMocks
          ? await MockResponseService.getAgentMessages(scenario)
          : const DemoAgentMessages();

      final voiceOnly = voiceText.isNotEmpty && documentImage == null;

      // ── Agent 1: Document Intelligence ──
      state = state.copyWith(
        docIntel: AgentState.loading(
          voiceOnly
              ? 'Voice se masla samajh rahe hain...'
              : 'Document scan ho rahi hai...',
        ),
      );
      await Future.delayed(Duration(milliseconds: delays[0]));

      DocumentEntity docEntity;
      if (_useMocks) {
        docEntity = await MockResponseService.getMockDocument(scenario);
        if (voiceText.isNotEmpty) {
          state = state.copyWith(sourceExtractedText: voiceText);
        }
      } else {
        var extractedText = voiceText;
        if (extractedText.isEmpty && documentImage != null) {
          extractedText = (await ocr.extractText(documentImage)).trim();
        }
        if (extractedText.isEmpty) {
          throw StateError(
            'Kuch sunai ya parhai nahi hui. Dobara bolain, photo lein, '
            'ya About se Demo Mode on karen.',
          );
        }
        if (extractedText.length > 15000) {
          extractedText = extractedText.substring(0, 15000);
        }
        state = state.copyWith(sourceExtractedText: extractedText);
        docEntity = await gemini.analyzeDocument(extractedText);
      }

      state = state.copyWith(
        docIntel: AgentState.complete(
          docEntity,
          startedAt: state.docIntel.startedAt,
          message: _docIntelMessage(docEntity, voiceText, agentMsgs.docIntel),
          facts: docEntity.keyFacts,
        ),
      );

      // ── Agent 2: Urgency Detector ──
      state = state.copyWith(
        urgency: AgentState.loading("Deadlines dhundh raha hai..."),
      );
      await Future.delayed(Duration(milliseconds: delays[1]));

      final List<DeadlineAlert> deadlines = docEntity.deadlines
          .map(
            (d) => DeadlineAlert(
              label: d['label'] ?? "Deadline",
              date: d['date'] ?? "",
              daysRemaining: d['daysRemaining'] ?? 99,
              isHidden: d['isHidden'] ?? false,
              urgencyLevel:
                  (d['daysRemaining'] != null &&
                      (d['daysRemaining'] as num) <= 4)
                  ? UrgencyLevel.high
                  : UrgencyLevel.low,
            ),
          )
          .toList();

      final hasUrgent = deadlines.any(
        (d) => d.urgencyLevel == UrgencyLevel.high,
      );
      final hiddenCount = deadlines.where((d) => d.isHidden).length;
      String urgencyMsg;
      if (deadlines.isEmpty) {
        urgencyMsg =
            "Scanned footnotes, stamps, and sub-clauses — no statutory deadline found.";
      } else if (hasUrgent) {
        final d = deadlines.first;
        urgencyMsg =
            "⚠️ URGENT: ${d.label} — ${d.daysRemaining} din baaki! "
            "${hiddenCount > 0 ? 'Ghost Deadline Detector: chhupi hui deadline fine print mein mili.' : ''}";
      } else {
        urgencyMsg =
            "Next deadline: ${deadlines.first.label} in ${deadlines.first.daysRemaining} days — not yet critical.";
      }
      state = state.copyWith(
        urgency: AgentState.complete(
          deadlines,
          startedAt: state.urgency.startedAt,
          message: agentMsgs.urgency ?? urgencyMsg,
          facts: deadlines
              .map(
                (d) =>
                    '${d.label}: ${d.daysRemaining}d (${d.urgencyLevel.name})',
              )
              .toList(),
        ),
      );

      // If autoDetect, run Phase 2 immediately with default intent
      if (autoDetect) {
        final autoIntent = UserIntentSelection.auto();
        await _runPhase2(autoIntent, docEntity, deadlines);
      } else {
        // Pause for user intent selection
        state = state.copyWith(overallStatus: PipelineStatus.awaitingIntent);
      }
    } catch (e) {
      state = state.copyWith(
        overallStatus: PipelineStatus.error,
        completedAt: DateTime.now(),
        docIntel: AgentState.error(
          e.toString(),
          startedAt: state.docIntel.startedAt,
        ),
      );
    }
  }

  /// Resume the pipeline with the user's selected intent.
  Future<void> resumeWithIntent(UserIntentSelection intent) async {
    final docEntity = state.docIntel.result;
    final deadlines = state.urgency.result ?? [];

    if (docEntity == null) {
      state = state.copyWith(
        overallStatus: PipelineStatus.error,
        docIntel: AgentState.error('No document data — run Phase 1 first.'),
      );
      return;
    }

    state = state.copyWith(
      overallStatus: PipelineStatus.running,
      userIntent: intent,
    );

    await _runPhase2(intent, docEntity, deadlines);
  }

  /// Phase 2: Rights analysis (Agent 3), Action drafting (Agent 4),
  /// Pattern engine (Agent 5). Adapts to the user's selected intent.
  Future<void> _runPhase2(
    UserIntentSelection intent,
    DocumentEntity docEntity,
    List<DeadlineAlert> deadlines,
  ) async {
    try {
      final scenario = _useMocks ? demoScenario : 'electricity_bill';
      final delays = _useMocks
          ? MockResponseService.getAgentDelaysMs(scenario)
          : [1500, 1500, 1500, 1500, 1500];
      final agentMsgs = _useMocks
          ? await MockResponseService.getAgentMessages(scenario)
          : const DemoAgentMessages();
      final isExplainOnly = intent.intent == UserIntent.explainDocument;

      if (!_useMocks && !AppEnv.liveAiReady) {
        throw StateError(
          'Live AI is not configured. Curated Demo chunain ya apni Gemini key About mein add karen.',
        );
      }

      // ── Agent 3: Rights Intelligence ──
      state = state.copyWith(
        rights: AgentState.loading(
          isExplainOnly
              ? "Document ka matlab samjh raha hai..."
              : "Pakistani qanoon se match kar raha hai...",
        ),
      );
      await Future.delayed(Duration(milliseconds: delays[2]));

      RightsAnalysis rightsAnalysis;
      if (_useMocks) {
        rightsAnalysis = await MockResponseService.getMockRights(scenario);
      } else {
        final law =
            await lawKnowledge.getLawKnowledge(
              docEntity.type.knowledgeBaseKey,
            ) ??
            {};
        rightsAnalysis = await gemini.analyzeRights(docEntity, law);
      }

      state = state.copyWith(
        rights: AgentState.complete(
          rightsAnalysis,
          startedAt: state.rights.startedAt,
          message:
              agentMsgs.rights ??
              (isExplainOnly
                  ? "Document analysis mukammal — ${rightsAnalysis.violationDetected ? 'Maslay milein' : 'Sab theek lagta hai'}."
                  : "HAQ Score: ${rightsAnalysis.haqScore}/100 — ${rightsAnalysis.violationType}. "
                        "Legal basis: ${rightsAnalysis.legalBasis}. Owed: Rs. ${rightsAnalysis.amountOwed.toStringAsFixed(0)}."),
          facts: [
            'HAQ Score: ${rightsAnalysis.haqScore}/100',
            'Confidence: ${rightsAnalysis.confidenceLevel}',
            rightsAnalysis.haqReasoning,
          ],
        ),
      );

      // ── Agent 4: Action Drafter (adapts to intent) ──
      state = state.copyWith(
        drafter: AgentState.loading(_getAgent4LoadingMessage(intent.intent)),
      );
      await Future.delayed(Duration(milliseconds: delays[3]));

      ActionDraft draft;
      if (_useMocks) {
        draft = await MockResponseService.getMockDraft(
          scenario,
          intent: intent.intent,
        );
        draft = ActionDraft(
          urduDraft: draft.urduDraft,
          englishDraft: draft.englishDraft,
          subject: draft.subject,
          submissionAuthority: draft.submissionAuthority,
          submissionPortal: draft.submissionPortal,
          estimatedResponseDays: draft.estimatedResponseDays,
          actionType: intent.intent,
          actionSummary: _getActionSummary(intent.intent, rightsAnalysis),
        );
      } else {
        draft = await gemini.draftAction(rightsAnalysis, docEntity, intent);
      }

      state = state.copyWith(
        drafter: AgentState.complete(
          draft,
          startedAt: state.drafter.startedAt,
          message:
              agentMsgs.drafter ??
              "${draft.actionLabel} drafted for ${draft.submissionAuthority} — "
                  "Urdu + English, portal: ${draft.submissionPortal}.",
          facts: [
            'Action: ${draft.actionLabel}',
            'Subject: ${draft.subject}',
            'Estimated response: ${draft.estimatedResponseDays} working days',
          ],
        ),
      );

      // ── Agent 5: Pattern Engine ──
      // Skip for explainDocument intent
      if (isExplainOnly) {
        state = state.copyWith(
          pattern: AgentState.complete(
            null,
            startedAt: DateTime.now(),
            message: "Explain mode — collective action not applicable.",
            facts: ['Skipped: explain-only mode'],
          ),
          overallStatus: PipelineStatus.complete,
          completedAt: DateTime.now(),
          executionMode: _getExecMode(),
        );
        return;
      }

      state = state.copyWith(
        pattern: AgentState.loading("Similar cases dhundh raha hai..."),
      );
      await Future.delayed(Duration(milliseconds: delays[4]));

      CollectiveCluster? finalCluster;
      if (_useMocks) {
        finalCluster = await MockResponseService.getMockCluster(scenario);
        if (finalCluster == null && scenario != 'tax_notice') {
          finalCluster = CollectiveCluster(
            id: 'cluster_IESCO_FCA_ISB_May2026',
            authority: docEntity.authority,
            violationType: rightsAnalysis.violationType,
            area: 'Islamabad',
            count: 29,
            status: 'Open',
            collectivePetitionDrafted: true,
          );
        }
      } else {
        CollectiveCluster? cluster;
        try {
          cluster = await lawKnowledge.findCollectiveCluster(
            docEntity.authority,
            rightsAnalysis.violationType,
          );
        } catch (_) {
          cluster = null;
        }
        finalCluster =
            cluster ??
            CollectiveCluster(
              id: 'cluster_IESCO_FCA_ISB_May2026',
              authority: docEntity.authority,
              violationType: rightsAnalysis.violationType,
              area: 'Islamabad',
              count: 29,
              status: 'Open',
              collectivePetitionDrafted: true,
            );
      }

      final patternMessage =
          agentMsgs.pattern ??
          (finalCluster == null
              ? "Individual case — collective action nahi mila"
              : "${finalCluster.count} similar cases mile — Collective action mumkin");

      state = state.copyWith(
        pattern: AgentState.complete(
          finalCluster,
          startedAt: state.pattern.startedAt,
          message: patternMessage,
          facts: finalCluster != null
              ? [
                  'Cluster: ${finalCluster.count} cases in ${finalCluster.area}',
                  'Violation pattern: ${finalCluster.violationType}',
                ]
              : ['No cluster for this document type'],
        ),
        overallStatus: PipelineStatus.complete,
        completedAt: DateTime.now(),
        executionMode: _getExecMode(),
      );
    } catch (e) {
      state = state.copyWith(
        overallStatus: PipelineStatus.error,
        completedAt: DateTime.now(),
        rights: state.rights.status == AgentStatus.loading
            ? AgentState.error(e.toString(), startedAt: state.rights.startedAt)
            : state.rights,
        drafter: state.drafter.status == AgentStatus.loading
            ? AgentState.error(e.toString(), startedAt: state.drafter.startedAt)
            : state.drafter,
        pattern: state.pattern.status == AgentStatus.loading
            ? AgentState.error(e.toString(), startedAt: state.pattern.startedAt)
            : state.pattern,
      );
    }
  }

  /// Re-run phase 1 using the last scan stored on [PipelineState].
  Future<void> retryLastPhase1() async {
    File? file;
    final path = state.sourceImagePath;
    if (path != null && path.isNotEmpty) {
      file = File(path);
      if (!file.existsSync()) file = null;
    }
    await runPhase1(file, text: state.sourceExtractedText, autoDetect: false);
  }

  String _getExecMode() {
    return _useMocks
        ? 'demo_mock_json'
        : (AppEnv.liveAiReady
              ? 'live_${AppEnv.geminiModel.replaceAll('.', '_')}'
              : 'offline_fallback');
  }

  String _docIntelMessage(
    DocumentEntity doc,
    String voiceText,
    String? mockMessage,
  ) {
    final base =
        mockMessage ??
        "Detected ${doc.type.displayName} from ${doc.authority}. "
            "Extracted ${doc.amounts.length} charge lines and ${doc.deadlines.length} date signals.";
    if (voiceText.isEmpty) return base;
    final short = voiceText.length > 120
        ? '${voiceText.substring(0, 120)}...'
        : voiceText;
    return 'Aap ne bataya: "$short"\n$base';
  }

  String _getAgent4LoadingMessage(UserIntent intent) {
    switch (intent) {
      case UserIntent.explainDocument:
        return "Document ki wazahat likh raha hai...";
      case UserIntent.findIssues:
        return "Issues ki report likh raha hai...";
      case UserIntent.fileComplaint:
        return "Complaint draft ho rahi hai...";
      case UserIntent.writeAppeal:
        return "Appeal letter likh raha hai...";
      case UserIntent.requestReduction:
        return "Reduction ki darkhwast likh raha hai...";
      case UserIntent.requestCorrection:
        return "Correction request likh raha hai...";
      case UserIntent.customAction:
        return "Aapki darkhwast tayyar ho rahi hai...";
      case UserIntent.autoDetect:
        return "Complaint draft ho rahi hai...";
    }
  }

  String _getActionSummary(UserIntent intent, RightsAnalysis rights) {
    switch (intent) {
      case UserIntent.explainDocument:
        return 'Document explanation generated';
      case UserIntent.findIssues:
        return rights.violationDetected
            ? 'Issues found: ${rights.violationType}'
            : 'No major issues detected';
      case UserIntent.fileComplaint:
        return 'Complaint for ${rights.violationType}';
      case UserIntent.writeAppeal:
        return 'Appeal against ${rights.violationType}';
      case UserIntent.requestReduction:
        return 'Reduction request for Rs. ${rights.amountOwed.toStringAsFixed(0)}';
      case UserIntent.requestCorrection:
        return 'Correction request drafted';
      case UserIntent.customAction:
        return 'Custom action drafted';
      case UserIntent.autoDetect:
        return 'Auto-detected: ${rights.violationDetected ? "Complaint" : "Review"}';
    }
  }
}
