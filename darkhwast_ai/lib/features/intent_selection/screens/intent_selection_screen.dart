import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/models/user_intent.dart';
import '../../../core/models/document_entity.dart';
import '../../agent_trace/providers/agent_pipeline_provider.dart';
import '../widgets/intent_card.dart';

class IntentSelectionScreen extends ConsumerStatefulWidget {
  const IntentSelectionScreen({super.key});

  @override
  ConsumerState<IntentSelectionScreen> createState() =>
      _IntentSelectionScreenState();
}

class _IntentSelectionScreenState extends ConsumerState<IntentSelectionScreen> {
  UserIntent _selectedIntent = UserIntent.autoDetect;
  final TextEditingController _customController = TextEditingController();
  bool _showCustomField = false;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  /// Intents shown to the user (excludes autoDetect — it gets a special button).
  static const _intents = [
    UserIntent.explainDocument,
    UserIntent.findIssues,
    UserIntent.fileComplaint,
    UserIntent.writeAppeal,
    UserIntent.requestReduction,
    UserIntent.requestCorrection,
    UserIntent.customAction,
  ];

  @override
  Widget build(BuildContext context) {
    final doc = ref.watch(documentEntityProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Aap kya karna chahte hain?",
                    style: AppTextStyles.headline
                        .copyWith(color: AppColors.primary, fontSize: 22),
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05),
                  const SizedBox(height: 8),
                  if (doc != null) _buildDocSummary(doc),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Intent List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  ..._intents.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final intent = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: IntentCard(
                        intent: intent,
                        isSelected: _selectedIntent == intent,
                        onTap: () {
                          setState(() {
                            _selectedIntent = intent;
                            _showCustomField =
                                intent == UserIntent.customAction;
                          });
                        },
                      )
                          .animate()
                          .fadeIn(delay: (80 * idx).ms, duration: 350.ms)
                          .slideY(begin: 0.08, end: 0),
                    );
                  }),
                  // Custom text field
                  if (_showCustomField)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: TextField(
                        controller: _customController,
                        maxLines: 3,
                        style: AppTextStyles.body.copyWith(fontSize: 14),
                        decoration: InputDecoration(
                          hintText:
                              "Batayein aap kya chahte hain...\ne.g. 'Mujhe yeh bill kam karwana hai'",
                          hintStyle: AppTextStyles.body.copyWith(
                            color:
                                AppColors.textSecondary.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: 80),
                ],
              ),
            ),

            // Bottom Action Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Main CTA
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _selectedIntent == UserIntent.autoDetect
                            ? "AI Decide Kare →"
                            : "${_selectedIntent.displayNameUrdu} →",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Auto detect option
                  if (_selectedIntent != UserIntent.autoDetect)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedIntent = UserIntent.autoDetect;
                          _showCustomField = false;
                        });
                        _onContinue();
                      },
                      child: Text(
                        "Ya AI khud decide kare",
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocSummary(DocumentEntity doc) {
    final amountStr = doc.amounts.isNotEmpty
        ? doc.amounts.map((a) => "Rs. ${a['amount']}").take(2).join(', ')
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.description_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${doc.type.displayName} — ${doc.authority}",
                  style: AppTextStyles.title.copyWith(
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (amountStr != null)
                  Text(
                    amountStr,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 20),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  void _onContinue() {
    final selection = UserIntentSelection(
      intent: _selectedIntent,
      customText: _selectedIntent == UserIntent.customAction
          ? _customController.text.trim()
          : null,
    );

    // Resume the pipeline with the user's intent
    ref.read(pipelineProvider.notifier).resumeWithIntent(selection);

    // Navigate back to agent trace to watch Phase 2
    context.go('/agent-trace-resume');
  }
}
