import 'user_intent.dart';

/// Unified action draft — can be a complaint, appeal, reduction request,
/// correction, explanation, or custom action depending on the user's intent.
class ActionDraft {
  final String urduDraft;
  final String englishDraft;
  final String subject;
  final String submissionAuthority;
  final String submissionPortal;
  final int estimatedResponseDays;

  /// What kind of action this draft represents.
  final UserIntent actionType;

  /// Short summary of the drafted action (for case cards, etc.).
  final String actionSummary;

  /// Plain-language explanation (used for explainDocument intent).
  final String? documentExplanation;

  ActionDraft({
    required this.urduDraft,
    required this.englishDraft,
    required this.subject,
    required this.submissionAuthority,
    required this.submissionPortal,
    required this.estimatedResponseDays,
    this.actionType = UserIntent.fileComplaint,
    this.actionSummary = '',
    this.documentExplanation,
  });

  factory ActionDraft.fromJson(Map<String, dynamic> json) {
    return ActionDraft(
      urduDraft: json['urduDraft'] ?? '',
      englishDraft: json['englishDraft'] ?? '',
      subject: json['subject'] ?? '',
      submissionAuthority: json['submissionAuthority'] ?? '',
      submissionPortal: json['submissionPortal'] ?? '',
      estimatedResponseDays: json['estimatedResponseDays'] ?? 14,
      actionType: UserIntent.values.firstWhere(
        (e) => e.name == json['actionType'],
        orElse: () => UserIntent.fileComplaint,
      ),
      actionSummary: json['actionSummary'] ?? '',
      documentExplanation: json['documentExplanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'urduDraft': urduDraft,
      'englishDraft': englishDraft,
      'subject': subject,
      'submissionAuthority': submissionAuthority,
      'submissionPortal': submissionPortal,
      'estimatedResponseDays': estimatedResponseDays,
      'actionType': actionType.name,
      'actionSummary': actionSummary,
      'documentExplanation': documentExplanation,
    };
  }

  /// Display label for the action type.
  String get actionLabel {
    switch (actionType) {
      case UserIntent.explainDocument:
        return 'Explanation';
      case UserIntent.findIssues:
        return 'Issue Report';
      case UserIntent.fileComplaint:
        return 'Complaint';
      case UserIntent.writeAppeal:
        return 'Appeal';
      case UserIntent.requestReduction:
        return 'Reduction Request';
      case UserIntent.requestCorrection:
        return 'Correction Request';
      case UserIntent.customAction:
        return 'Custom Action';
      case UserIntent.autoDetect:
        return 'Complaint';
    }
  }
}

/// Backward compatibility alias — existing code referencing ComplaintDraft
/// will continue to work.
typedef ComplaintDraft = ActionDraft;
