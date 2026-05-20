import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/models/complaint_draft.dart';
import '../../../core/models/document_entity.dart';
import '../../../core/models/rights_analysis.dart';
import '../../agent_trace/providers/agent_pipeline_provider.dart';
import '../../../shared/widgets/pipeline_data_error.dart';

/// Screen shown when user picks "Document Samjhein" (Explain Document) intent.
/// Displays the document explanation without HAQ Score or complaint filing.
class DocumentExplanationScreen extends ConsumerWidget {
  const DocumentExplanationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doc = ref.watch(documentEntityProvider);
    final rights = ref.watch(rightsAnalysisProvider);
    final draft = ref.watch(complaintDraftProvider);

    if (doc == null) {
      return const PipelineDataError(
        message: 'Document explanation load nahi hui.',
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Document Samjhein",
          style: AppTextStyles.title.copyWith(color: AppColors.primary),
        ),
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.close_rounded, color: AppColors.primary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document Type Header
            _buildDocumentHeader(
              doc,
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05),

            const SizedBox(height: 24),

            // Plain Language Explanation
            if (draft?.documentExplanation != null)
              _buildExplanationCard(
                    "Asaan Lafzon Mein",
                    draft!.documentExplanation!,
                    Icons.lightbulb_outline_rounded,
                    AppColors.accent,
                  )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 500.ms)
                  .slideY(begin: 0.05),

            if (draft?.documentExplanation != null) const SizedBox(height: 16),

            // Key Facts
            if (doc.keyFacts.isNotEmpty)
              _buildKeyFactsCard(doc.keyFacts)
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 500.ms)
                  .slideY(begin: 0.05),

            const SizedBox(height: 16),

            // Amounts Breakdown
            if (doc.amounts.isNotEmpty)
              _buildAmountsCard(doc.amounts)
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 500.ms)
                  .slideY(begin: 0.05),

            const SizedBox(height: 16),

            // Important Dates
            if (doc.dates.isNotEmpty)
              _buildDatesCard(doc.dates)
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 500.ms)
                  .slideY(begin: 0.05),

            const SizedBox(height: 16),

            // Issues Found (if any)
            if (rights != null && rights.violationDetected)
              _buildIssueCard(rights)
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 500.ms)
                  .slideY(begin: 0.05),

            const SizedBox(height: 24),

            // Detailed Explanation (Urdu + English tabs)
            if (draft != null)
              _buildDetailedExplanation(
                draft,
              ).animate().fadeIn(delay: 600.ms, duration: 500.ms),

            const SizedBox(height: 32),

            // Action Buttons
            _buildActionButtons(context, rights)
                .animate()
                .fadeIn(delay: 700.ms, duration: 500.ms)
                .slideY(begin: 0.05),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentHeader(DocumentEntity doc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  documentTypeDisplayName(doc.type),
                  style: AppTextStyles.headline.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "From: ${doc.authority}",
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                if (doc.consumerRef != null)
                  Text(
                    "Ref: ${doc.consumerRef}",
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationCard(
    String title,
    String content,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.title.copyWith(
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: AppTextStyles.body.copyWith(fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyFactsCard(List<String> facts) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.fact_check_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Key Facts",
                style: AppTextStyles.title.copyWith(
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...facts.map(
            (fact) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      fact,
                      style: AppTextStyles.body.copyWith(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountsCard(List<Map<String, dynamic>> amounts) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.payments_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Charges / Amounts",
                style: AppTextStyles.title.copyWith(
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...amounts.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      a['label'] ?? 'Charge',
                      style: AppTextStyles.body.copyWith(fontSize: 14),
                    ),
                  ),
                  Text(
                    "Rs. ${a['amount'] ?? 0}",
                    style: AppTextStyles.title.copyWith(
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatesCard(List<Map<String, dynamic>> dates) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Important Dates",
                style: AppTextStyles.title.copyWith(
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...dates.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      d['label'] ?? 'Date',
                      style: AppTextStyles.body.copyWith(fontSize: 14),
                    ),
                  ),
                  Text(
                    d['date'] ?? 'N/A',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueCard(RightsAnalysis rights) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.urgent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.urgent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.urgent,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                "Issue Detected",
                style: AppTextStyles.title.copyWith(
                  fontSize: 16,
                  color: AppColors.urgent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "${rights.violationType}\n"
            "Legal Basis: ${rights.legalBasis}\n"
            "Amount: Rs. ${rights.amountOwed.toStringAsFixed(0)}",
            style: AppTextStyles.body.copyWith(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 8),
          Text(
            rights.haqReasoning,
            style: AppTextStyles.body.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedExplanation(ActionDraft draft) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.menu_book_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Full Explanation",
                style: AppTextStyles.title.copyWith(
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            draft.englishDraft,
            style: AppTextStyles.body.copyWith(fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, RightsAnalysis? rights) {
    return Column(
      children: [
        if (rights != null && rights.violationDetected) ...[
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/haq-dashboard'),
              icon: const Icon(Icons.gavel_rounded),
              label: const Text(
                "Action Lein →",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.home_rounded),
            label: const Text(
              "Home Jayein",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary, width: 2),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
