import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../../../core/models/collective_cluster.dart';
import '../../../core/models/complaint_draft.dart';
import '../../../core/models/document_entity.dart';
import '../../../core/models/rights_analysis.dart';

/// Composes the complaint as an email and hands it to the platform share sheet,
/// where Gmail is the default mail target on Android (and a top option on iOS).
///
/// The email is pre-filled with:
/// - Subject  → [ActionDraft.subject]
/// - Body     → English draft + Urdu draft + submission details + HAQ analysis
///              + collective action info + case reference (if filed)
/// - Attachment → original captured document image (when available)
class ComplaintEmailComposer {
  static Future<void> compose({
    required ActionDraft draft,
    DocumentEntity? doc,
    RightsAnalysis? rights,
    CollectiveCluster? cluster,
    bool joinedCollective = false,
    String? caseReference,
    String? sourceImagePath,
  }) async {
    final body = _buildBody(
      draft: draft,
      doc: doc,
      rights: rights,
      cluster: cluster,
      joinedCollective: joinedCollective,
      caseReference: caseReference,
    );

    final files = <XFile>[];
    final imagePath = sourceImagePath;
    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (file.existsSync()) {
        files.add(
          XFile(
            imagePath,
            name: _attachmentName(imagePath, draft),
            mimeType: _mimeTypeFor(imagePath),
          ),
        );
      }
    }

    final subject = draft.subject.isNotEmpty
        ? draft.subject
        : '${draft.actionLabel} — ${draft.submissionAuthority}';

    await SharePlus.instance.share(
      ShareParams(
        subject: subject,
        text: body,
        files: files.isEmpty ? null : files,
        title: 'Email via Gmail',
      ),
    );
  }

  static String _attachmentName(String path, ActionDraft draft) {
    final dotIndex = path.lastIndexOf('.');
    final ext = dotIndex >= 0
        ? path.substring(dotIndex + 1).toLowerCase()
        : 'jpg';
    final safe = draft.subject
        .replaceAll(RegExp(r'[^a-zA-Z0-9_\- ]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    final base = safe.isEmpty ? 'DarkhwastAI_Document' : safe;
    return '$base.$ext';
  }

  static String? _mimeTypeFor(String path) {
    final p = path.toLowerCase();
    if (p.endsWith('.png')) return 'image/png';
    if (p.endsWith('.heic')) return 'image/heic';
    if (p.endsWith('.webp')) return 'image/webp';
    if (p.endsWith('.pdf')) return 'application/pdf';
    if (p.endsWith('.jpg') || p.endsWith('.jpeg')) return 'image/jpeg';
    return null;
  }

  static String _buildBody({
    required ActionDraft draft,
    DocumentEntity? doc,
    RightsAnalysis? rights,
    CollectiveCluster? cluster,
    bool joinedCollective = false,
    String? caseReference,
  }) {
    final buf = StringBuffer();

    if (caseReference != null && caseReference.isNotEmpty) {
      buf
        ..writeln('Case Reference: $caseReference')
        ..writeln();
    }

    if (draft.englishDraft.trim().isNotEmpty) {
      buf
        ..writeln(draft.englishDraft.trim())
        ..writeln();
    }

    if (draft.urduDraft.trim().isNotEmpty) {
      buf
        ..writeln('— — —')
        ..writeln()
        ..writeln('اردو نسخہ / Urdu Version')
        ..writeln(draft.urduDraft.trim())
        ..writeln();
    }

    buf
      ..writeln('— — —')
      ..writeln('Submission Details')
      ..writeln('Authority: ${draft.submissionAuthority}')
      ..writeln('Portal: ${draft.submissionPortal}')
      ..writeln(
        'Estimated response: ${draft.estimatedResponseDays} working days',
      );

    if (doc != null) {
      buf
        ..writeln()
        ..writeln('Document');
      buf.writeln('Type: ${documentTypeDisplayName(doc.type)}');
      if (doc.authority.isNotEmpty) {
        buf.writeln('Issued by: ${doc.authority}');
      }
      final ref = doc.consumerRef;
      if (ref != null && ref.isNotEmpty) {
        buf.writeln('Consumer Ref: $ref');
      }
    }

    if (rights != null) {
      buf
        ..writeln()
        ..writeln('Legal Analysis')
        ..writeln('HAQ Score: ${rights.haqScore}/100')
        ..writeln('Violation: ${rights.violationType}')
        ..writeln('Amount Owed: Rs. ${rights.amountOwed.toStringAsFixed(0)}')
        ..writeln('Legal Basis: ${rights.legalBasis}');
    }

    if (joinedCollective && cluster != null) {
      buf
        ..writeln()
        ..writeln('Collective Action')
        ..writeln(
          '${cluster.count} citizens joined · ${cluster.authority} · ${cluster.area}',
        );
    }

    buf
      ..writeln()
      ..writeln('—')
      ..writeln('Sent via DarkhwastAI — Apka document. Apka haq.');

    return buf.toString();
  }
}
