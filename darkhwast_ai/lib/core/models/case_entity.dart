import 'document_entity.dart';
import 'rights_analysis.dart';
import 'complaint_draft.dart';
import 'user_intent.dart';

enum CaseStatus { pending, filed, resolved }

class CaseEntity {
  final String id;
  final DocumentEntity document;
  final RightsAnalysis rightsAnalysis;
  final ActionDraft actionDraft;
  final CaseStatus status;
  final DateTime filedDate;
  final List<DateTime> followUpDates;
  final String caseReference;
  final bool joinedCollective;

  /// What the user chose to do with this document.
  final UserIntent userIntent;

  CaseEntity({
    required this.id,
    required this.document,
    required this.rightsAnalysis,
    required this.actionDraft,
    required this.status,
    required this.filedDate,
    required this.followUpDates,
    required this.caseReference,
    this.joinedCollective = false,
    this.userIntent = UserIntent.autoDetect,
  });

  /// Backward-compatible alias for actionDraft.
  ActionDraft get complaintDraft => actionDraft;

  factory CaseEntity.fromJson(Map<String, dynamic> json) {
    // Support both old 'complaintDraft' and new 'actionDraft' keys.
    final draftJson = json['actionDraft'] ?? json['complaintDraft'] ?? {};

    return CaseEntity(
      id: json['id'],
      document: DocumentEntity.fromJson(json['document']),
      rightsAnalysis: RightsAnalysis.fromJson(json['rightsAnalysis']),
      actionDraft: ActionDraft.fromJson(
        Map<String, dynamic>.from(draftJson),
      ),
      status: CaseStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CaseStatus.filed,
      ),
      filedDate: DateTime.parse(json['filedDate']),
      followUpDates: (json['followUpDates'] as List)
          .map((d) => DateTime.parse(d))
          .toList(),
      caseReference: json['caseReference'],
      joinedCollective: json['joinedCollective'] ?? false,
      userIntent: UserIntent.values.firstWhere(
        (e) => e.name == (json['userIntent'] ?? ''),
        orElse: () => UserIntent.autoDetect,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'document': document.toJson(),
      'rightsAnalysis': rightsAnalysis.toJson(),
      'actionDraft': actionDraft.toJson(),
      // Keep backward-compat key for Firestore docs
      'complaintDraft': actionDraft.toJson(),
      'status': status.name,
      'filedDate': filedDate.toIso8601String(),
      'followUpDates': followUpDates.map((d) => d.toIso8601String()).toList(),
      'caseReference': caseReference,
      'joinedCollective': joinedCollective,
      'userIntent': userIntent.name,
    };
  }
}
