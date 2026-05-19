import 'package:flutter/material.dart';

/// What the user wants the AI to do with their scanned document.
enum UserIntent {
  /// Just explain what the document says in plain language.
  explainDocument,

  /// Scan for errors, overcharges, violations, or hidden issues.
  findIssues,

  /// Draft and file a formal complaint.
  fileComplaint,

  /// Write an appeal or application letter.
  writeAppeal,

  /// Request a reduction in charges, fees, or penalties.
  requestReduction,

  /// Request a correction of data, records, or billing info.
  requestCorrection,

  /// User provides freeform text describing what they want.
  customAction,

  /// Let the AI automatically decide the best action.
  autoDetect,
}

extension UserIntentDisplay on UserIntent {
  String get displayName {
    switch (this) {
      case UserIntent.explainDocument:
        return 'Explain Document';
      case UserIntent.findIssues:
        return 'Find Issues';
      case UserIntent.fileComplaint:
        return 'File Complaint';
      case UserIntent.writeAppeal:
        return 'Write Appeal';
      case UserIntent.requestReduction:
        return 'Request Reduction';
      case UserIntent.requestCorrection:
        return 'Request Correction';
      case UserIntent.customAction:
        return 'Custom Action';
      case UserIntent.autoDetect:
        return 'AI Decide Kare';
    }
  }

  String get displayNameUrdu {
    switch (this) {
      case UserIntent.explainDocument:
        return 'Document samjhein';
      case UserIntent.findIssues:
        return 'Issues dhundhein';
      case UserIntent.fileComplaint:
        return 'Complaint likhein';
      case UserIntent.writeAppeal:
        return 'Appeal likhein';
      case UserIntent.requestReduction:
        return 'Reduction mangein';
      case UserIntent.requestCorrection:
        return 'Correction karwayein';
      case UserIntent.customAction:
        return 'Apni baat likhein';
      case UserIntent.autoDetect:
        return 'AI faisla kare';
    }
  }

  String get description {
    switch (this) {
      case UserIntent.explainDocument:
        return 'Yeh document kya kehta hai, asaan Urdu mein samjhein';
      case UserIntent.findIssues:
        return 'Galtiyan, extra charges, ya violations dhundhein';
      case UserIntent.fileComplaint:
        return 'Citizens Portal ya authority ko shikayat darj karen';
      case UserIntent.writeAppeal:
        return 'Faislay ke khilaf appeal ya darkhwast likhein';
      case UserIntent.requestReduction:
        return 'Bill ya charges mein kami ki darkhwast likhein';
      case UserIntent.requestCorrection:
        return 'Ghalat information ki correction mangein';
      case UserIntent.customAction:
        return 'Apne lafzon mein batayein kya karna hai';
      case UserIntent.autoDetect:
        return 'AI best action khud choose karega';
    }
  }

  IconData get icon {
    switch (this) {
      case UserIntent.explainDocument:
        return Icons.menu_book_rounded;
      case UserIntent.findIssues:
        return Icons.search_rounded;
      case UserIntent.fileComplaint:
        return Icons.report_problem_rounded;
      case UserIntent.writeAppeal:
        return Icons.gavel_rounded;
      case UserIntent.requestReduction:
        return Icons.trending_down_rounded;
      case UserIntent.requestCorrection:
        return Icons.edit_note_rounded;
      case UserIntent.customAction:
        return Icons.chat_bubble_outline_rounded;
      case UserIntent.autoDetect:
        return Icons.auto_awesome_rounded;
    }
  }

  /// Whether this intent requires the full rights analysis pipeline (Agent 3-5).
  bool get requiresFullPipeline {
    switch (this) {
      case UserIntent.explainDocument:
        return false;
      case UserIntent.findIssues:
      case UserIntent.fileComplaint:
      case UserIntent.writeAppeal:
      case UserIntent.requestReduction:
      case UserIntent.requestCorrection:
      case UserIntent.customAction:
      case UserIntent.autoDetect:
        return true;
    }
  }

  /// The label for Agent 4 card based on intent.
  String get agent4Label {
    switch (this) {
      case UserIntent.explainDocument:
        return 'Document Explainer';
      case UserIntent.findIssues:
        return 'Issue Report Drafter';
      case UserIntent.fileComplaint:
        return 'Complaint Drafter';
      case UserIntent.writeAppeal:
        return 'Appeal Drafter';
      case UserIntent.requestReduction:
        return 'Reduction Application';
      case UserIntent.requestCorrection:
        return 'Correction Request';
      case UserIntent.customAction:
        return 'Custom Action Drafter';
      case UserIntent.autoDetect:
        return 'Action Drafter';
    }
  }
}

/// Holds the user's selected intent plus optional custom text.
class UserIntentSelection {
  final UserIntent intent;
  final String? customText;

  const UserIntentSelection({
    required this.intent,
    this.customText,
  });

  Map<String, dynamic> toJson() => {
        'intent': intent.name,
        'customText': customText,
      };

  factory UserIntentSelection.fromJson(Map<String, dynamic> json) {
    return UserIntentSelection(
      intent: UserIntent.values.firstWhere(
        (e) => e.name == json['intent'],
        orElse: () => UserIntent.autoDetect,
      ),
      customText: json['customText'],
    );
  }

  /// Default: let AI decide.
  factory UserIntentSelection.auto() =>
      const UserIntentSelection(intent: UserIntent.autoDetect);
}
