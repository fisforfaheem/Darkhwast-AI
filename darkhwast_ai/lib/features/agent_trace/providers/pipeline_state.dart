import 'dart:convert';
import '../../../core/config/app_env.dart';
import '../../../core/models/document_entity.dart';
import '../../../core/models/deadline_alert.dart';
import '../../../core/models/rights_analysis.dart';
import '../../../core/models/complaint_draft.dart';
import '../../../core/models/collective_cluster.dart';
import '../../../core/models/agent_state.dart';
import '../../../core/models/user_intent.dart';

enum PipelineStatus { idle, running, awaitingIntent, complete, error }

class PipelineState {
  final AgentState<DocumentEntity> docIntel;
  final AgentState<List<DeadlineAlert>> urgency;
  final AgentState<RightsAnalysis> rights;
  final AgentState<ActionDraft> drafter;
  final AgentState<CollectiveCluster?> pattern;
  final PipelineStatus overallStatus;
  final String runId;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? filedCaseReference;
  final bool collectiveJoined;
  final String? executionMode;

  /// The user's selected intent (set after intent selection screen).
  final UserIntentSelection? userIntent;

  PipelineState({
    required this.docIntel,
    required this.urgency,
    required this.rights,
    required this.drafter,
    required this.pattern,
    required this.overallStatus,
    required this.runId,
    this.startedAt,
    this.completedAt,
    this.filedCaseReference,
    this.collectiveJoined = false,
    this.executionMode,
    this.userIntent,
  });

  factory PipelineState.initial() {
    final runId = 'run-${DateTime.now().millisecondsSinceEpoch}';
    return PipelineState(
      docIntel: AgentState.idle(),
      urgency: AgentState.idle(),
      rights: AgentState.idle(),
      drafter: AgentState.idle(),
      pattern: AgentState.idle(),
      overallStatus: PipelineStatus.idle,
      runId: runId,
    );
  }

  PipelineState copyWith({
    AgentState<DocumentEntity>? docIntel,
    AgentState<List<DeadlineAlert>>? urgency,
    AgentState<RightsAnalysis>? rights,
    AgentState<ActionDraft>? drafter,
    AgentState<CollectiveCluster?>? pattern,
    PipelineStatus? overallStatus,
    String? runId,
    DateTime? startedAt,
    DateTime? completedAt,
    String? filedCaseReference,
    bool? collectiveJoined,
    String? executionMode,
    UserIntentSelection? userIntent,
  }) {
    return PipelineState(
      docIntel: docIntel ?? this.docIntel,
      urgency: urgency ?? this.urgency,
      rights: rights ?? this.rights,
      drafter: drafter ?? this.drafter,
      pattern: pattern ?? this.pattern,
      overallStatus: overallStatus ?? this.overallStatus,
      runId: runId ?? this.runId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      filedCaseReference: filedCaseReference ?? this.filedCaseReference,
      collectiveJoined: collectiveJoined ?? this.collectiveJoined,
      executionMode: executionMode ?? this.executionMode,
      userIntent: userIntent ?? this.userIntent,
    );
  }

  bool get isComplete => overallStatus == PipelineStatus.complete;
  bool get isRunning => overallStatus == PipelineStatus.running;
  bool get isError => overallStatus == PipelineStatus.error;
  bool get isAwaitingIntent => overallStatus == PipelineStatus.awaitingIntent;

  bool get hasUrgentDeadline {
    final deadlines = urgency.result ?? [];
    return deadlines.any((d) => d.urgencyLevel == UrgencyLevel.high);
  }

  bool get hasGhostDeadline {
    final deadlines = urgency.result ?? [];
    return deadlines.any((d) => d.isHidden);
  }

  Map<String, dynamic> toJson() {
    final llmMode =
        executionMode ?? (AppEnv.liveAiReady ? 'live_gemini' : 'offline');

    return {
      'trace_format': 'antigravity_agent_v1',
      'orchestration': {
        'platform': 'Google Antigravity',
        'build_tool': 'Antigravity autonomous agent sessions',
        'runtime': 'Flutter 3 + Riverpod StateNotifier',
        'llm': AppEnv.geminiModel,
        'llm_mode': llmMode,
        'challenge':
            'AISeekho 2026 — Challenge 1: Autonomous Content-to-Action Agent',
        'execution_mode': 'sequential_handoff',
        'agent_count': 5,
        'interrupt_logic':
            'UrgencyDetectorAgent flags deadlines <= 4 days or ghost (hidden) dates',
      },
      'run_id': runId,
      'timestamp':
          (completedAt ?? startedAt ?? DateTime.now()).toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'pipeline_duration_ms': _pipelineDurationMs(),
      'input_document_type':
          docIntel.result?.type.knowledgeBaseKey ?? 'UNKNOWN',
      'input_authority': docIntel.result?.authority,
      'user_intent': userIntent?.toJson(),
      'agents': [
        _agentToJson(
          step: 1,
          name: 'DocumentIntelligenceAgent',
          role: 'Extract structured data from OCR / document text',
          state: docIntel,
          summarize: _summarizeDocIntel,
          tools: [
            'Google ML Kit OCR',
            '${AppEnv.geminiModel} vision-language JSON',
          ],
        ),
        _agentToJson(
          step: 2,
          name: 'UrgencyDetectorAgent',
          role: 'Ghost Deadline Detector — scan footnotes and fine print',
          state: urgency,
          summarize: _summarizeUrgency,
          tools: const [
            'Rule engine on DocumentEntity.deadlines',
            'Hidden-date heuristics'
          ],
        ),
        _agentToJson(
          step: 3,
          name: 'RightsIntelligenceAgent',
          role:
              'Match charges to Pakistani consumer protection law; compute HAQ Score',
          state: rights,
          summarize: _summarizeRights,
          tools: [
            'Firestore knowledgeBase',
            '${AppEnv.geminiModel} legal reasoning',
          ],
        ),
        _agentToJson(
          step: 4,
          name: userIntent?.intent.agent4Label ?? 'ActionDrafterAgent',
          role: _agent4Role(),
          state: drafter,
          summarize: _summarizeDrafter,
          tools: [
            '${AppEnv.geminiModel} drafting',
            'Urdu + English letter templates',
          ],
        ),
        _agentToJson<CollectiveCluster?>(
          step: 5,
          name: 'CollectivePatternAgent',
          role: 'Cluster similar complaints for collective petitions',
          state: pattern,
          summarize: _summarizePattern,
          tools: const [
            'Firestore collectiveCases query',
            'Violation pattern matching'
          ],
        ),
      ],
      'final_outcome': {
        'haq_score': rights.result?.haqScore,
        'amount_owed': rights.result?.amountOwed,
        'violation_type': rights.result?.violationType,
        'legal_basis': rights.result?.legalBasis,
        'confidence': rights.result?.confidenceLevel,
        'complaint_filed': filedCaseReference != null,
        'case_reference': filedCaseReference ?? 'PENDING',
        'collective_action_joined': collectiveJoined,
        'urgent_deadline_detected': hasUrgentDeadline,
        'ghost_deadline_detected': hasGhostDeadline,
        'user_selected_action': userIntent?.intent.name ?? 'auto_detect',
        'action_type': drafter.result?.actionLabel,
        'recommended_action': rights.result?.violationDetected == true
            ? 'FILE_COMPLAINT'
            : 'REVIEW_ONLY',
        'content_to_action_complete': isComplete,
      },
    };
  }

  String _agent4Role() {
    final intent = userIntent?.intent ?? UserIntent.autoDetect;
    switch (intent) {
      case UserIntent.explainDocument:
        return 'Generate plain-language document explanation';
      case UserIntent.writeAppeal:
        return 'Generate bilingual appeal letter for submission';
      case UserIntent.requestReduction:
        return 'Generate reduction/discount application letter';
      case UserIntent.requestCorrection:
        return 'Generate correction request for authorities';
      case UserIntent.customAction:
        return 'Generate custom action draft based on user instructions';
      default:
        return 'Generate bilingual formal action document for submission';
    }
  }

  int? _pipelineDurationMs() {
    if (startedAt == null || completedAt == null) return null;
    return completedAt!.difference(startedAt!).inMilliseconds;
  }

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());

  Map<String, dynamic> _agentToJson<T>({
    required int step,
    required String name,
    required String role,
    required AgentState<T> state,
    required String Function(T?) summarize,
    required List<String> tools,
  }) {
    return {
      'step': step,
      'agent': name,
      'role': role,
      'status': state.status.name,
      'started_at': state.startedAt?.toIso8601String(),
      'completed_at': state.completedAt?.toIso8601String(),
      'duration_ms': state.durationMs,
      'tools_used': tools,
      'reasoning': _buildReasoning(name, state),
      'decision': _buildDecision(name, state),
      'facts': state.facts,
      'output_summary': summarize(state.result),
      if (state.isComplete) 'output': _serializeOutput(name, state.result),
    };
  }

  String _buildReasoning(String agentName, AgentState<dynamic> state) {
    if (state.isError) {
      return state.errorMessage ?? 'Agent $agentName failed.';
    }
    if (state.agentMessage != null && state.agentMessage!.isNotEmpty) {
      final buffer = StringBuffer(state.agentMessage!);
      if (state.facts.isNotEmpty) {
        buffer.write(' | Key facts: ${state.facts.join('; ')}');
      }
      return buffer.toString();
    }
    return 'Awaiting $agentName execution.';
  }

  String _buildDecision(String agentName, AgentState<dynamic> state) {
    if (!state.isComplete) return 'PENDING';
    switch (agentName) {
      case 'DocumentIntelligenceAgent':
        final doc = state.result as DocumentEntity?;
        return doc != null
            ? 'Classified as ${doc.type.knowledgeBaseKey} from ${doc.authority}'
            : 'UNKNOWN';
      case 'UrgencyDetectorAgent':
        final deadlines = state.result as List<DeadlineAlert>?;
        if (deadlines == null || deadlines.isEmpty) {
          return 'NO_URGENT_ACTION';
        }
        if (deadlines.any((d) => d.isHidden)) {
          return 'GHOST_DEADLINE_ALERT';
        }
        if (deadlines.any((d) => d.urgencyLevel == UrgencyLevel.high)) {
          return 'URGENT_INTERRUPT';
        }
        return 'MONITOR_DEADLINE';
      case 'RightsIntelligenceAgent':
        final r = state.result as RightsAnalysis?;
        return r != null && r.violationDetected
            ? 'VIOLATION_CONFIRMED_HAQ_${r.haqScore}'
            : 'NO_VIOLATION';
      case 'CollectivePatternAgent':
        final c = state.result as CollectiveCluster?;
        return c != null
            ? 'COLLECTIVE_CLUSTER_${c.count}'
            : 'INDIVIDUAL_FILING';
      default:
        // ActionDrafterAgent or intent-specific agent names
        final draft = state.result as ActionDraft?;
        return draft != null
            ? '${draft.actionLabel.toUpperCase()}_DRAFT_READY'
            : 'COMPLETE';
    }
  }

  dynamic _serializeOutput(String agentName, dynamic result) {
    if (result == null) return null;
    if (agentName == 'DocumentIntelligenceAgent') {
      return (result as DocumentEntity).toJson();
    }
    if (agentName == 'UrgencyDetectorAgent') {
      return (result as List<DeadlineAlert>).map((d) => d.toJson()).toList();
    }
    if (agentName == 'RightsIntelligenceAgent') {
      return (result as RightsAnalysis).toJson();
    }
    if (agentName == 'CollectivePatternAgent') {
      final c = result as CollectiveCluster?;
      return c?.toJson();
    }
    // ActionDrafter or any intent-specific agent
    if (result is ActionDraft) {
      return result.toJson();
    }
    return result.toString();
  }

  static String _summarizeDocIntel(DocumentEntity? doc) {
    if (doc == null) return 'N/A';
    return 'DocumentEntity: type=${doc.type.knowledgeBaseKey}, authority=${doc.authority}, '
        'amounts=${doc.amounts.length}, deadlines=${doc.deadlines.length}';
  }

  static String _summarizeUrgency(List<DeadlineAlert>? deadlines) {
    if (deadlines == null || deadlines.isEmpty) {
      return 'No time-sensitive deadlines detected in document body or footnotes.';
    }
    final d = deadlines.first;
    return 'DeadlineAlert: label=${d.label}, daysRemaining=${d.daysRemaining}, '
        'hidden=${d.isHidden}, urgency=${d.urgencyLevel.name}';
  }

  static String _summarizeRights(RightsAnalysis? rights) {
    if (rights == null) return 'N/A';
    return 'RightsAnalysis: haqScore=${rights.haqScore}, violation=${rights.violationType}, '
        'owed=Rs.${rights.amountOwed}, basis=${rights.legalBasis}';
  }

  static String _summarizeDrafter(ActionDraft? draft) {
    if (draft == null) return 'N/A';
    return 'ActionDraft(${draft.actionLabel}): authority=${draft.submissionAuthority}, '
        'portal=${draft.submissionPortal}, responseDays=${draft.estimatedResponseDays}';
  }

  static String _summarizePattern(CollectiveCluster? cluster) {
    if (cluster == null) {
      return 'No collective cluster — individual filing recommended.';
    }
    return 'CollectiveCluster: authority=${cluster.authority}, '
        'violation=${cluster.violationType}, area=${cluster.area}, count=${cluster.count}';
  }
}
