import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/models/complaint_draft.dart';
import '../../../core/providers/case_providers.dart';
import '../../agent_trace/providers/agent_pipeline_provider.dart';
import '../../../shared/widgets/pipeline_data_error.dart';
import '../utils/email_composer.dart';

/// True when [text] contains Perso-Arabic script (proper Urdu), not Roman Urdu.
bool _usesUrduScript(String text) => RegExp(r'[\u0600-\u06FF]').hasMatch(text);

/// Opens the platform share sheet (Gmail-first on Android) with the full
/// complaint draft pre-filled and the scanned document attached.
Future<void> _emailDraft(BuildContext context, WidgetRef ref) async {
  final draft = ref.read(complaintDraftProvider);
  if (draft == null) return;

  final doc = ref.read(documentEntityProvider);
  final rights = ref.read(rightsAnalysisProvider);
  final cluster = ref.read(collectiveClusterProvider);
  final joinedCollective = ref.read(joinCollectiveProvider);
  final pipeline = ref.read(pipelineProvider);

  final messenger = ScaffoldMessenger.of(context);
  try {
    await ComplaintEmailComposer.compose(
      draft: draft,
      doc: doc,
      rights: rights,
      cluster: cluster,
      joinedCollective: joinedCollective,
      caseReference: pipeline.filedCaseReference,
      sourceImagePath: pipeline.sourceImagePath,
    );
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text('Email open nahi ho saka: $e')),
    );
  }
}

class ComplaintDraftScreen extends ConsumerWidget {
  const ComplaintDraftScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(complaintDraftProvider);

    if (draft == null) {
      return const PipelineDataError(
        message: 'Complaint draft tayyar nahi. Pehle analysis mukammal karen.',
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "${draft.actionLabel} Draft",
            style: AppTextStyles.title.copyWith(color: AppColors.primary),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => _EditDraftBottomSheet(
                    draft: draft,
                    onSave: (updated) {
                      ref
                          .read(pipelineProvider.notifier)
                          .updateActionDraft(updated);
                    },
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: AppTextStyles.title.copyWith(fontSize: 16),
            tabs: const [
              Tab(text: "اردو"),
              Tab(text: "English"),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  // Urdu Draft
                  _DraftView(
                    content: draft.urduDraft,
                    isUrdu: true,
                    subject: draft.subject,
                  ),

                  // English Draft
                  _DraftView(
                    content: draft.englishDraft,
                    isUrdu: false,
                    subject: draft.subject,
                  ),
                ],
              ),
            ),

            // Bottom Info Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Filed to: ${draft.submissionAuthority}",
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          draft.submissionPortal,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.security_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => _emailDraft(context, ref),
                  icon: const Icon(Icons.mail_outline_rounded),
                  label: const Text(
                    "Email Karen (Gmail)",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.push('/filing'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Confirm aur File Karen",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DraftView extends StatelessWidget {
  final String content;
  final bool isUrdu;
  final String subject;

  const _DraftView({
    required this.content,
    required this.isUrdu,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    final useRtl = isUrdu && _usesUrduScript(content);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: useRtl
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: useRtl
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  isUrdu ? "موضوع:" : "Subject:",
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subject,
                  style: isUrdu
                      ? AppTextStyles.urduBody.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )
                      : AppTextStyles.title.copyWith(
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                  textAlign: useRtl ? TextAlign.right : TextAlign.left,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            content,
            style: isUrdu
                ? AppTextStyles.urduBody.copyWith(height: 1.8)
                : AppTextStyles.body.copyWith(height: 1.6),
            textAlign: useRtl ? TextAlign.right : TextAlign.left,
            textDirection: useRtl ? TextDirection.rtl : TextDirection.ltr,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _EditDraftBottomSheet extends StatefulWidget {
  final ActionDraft draft;
  final Function(ActionDraft) onSave;

  const _EditDraftBottomSheet({required this.draft, required this.onSave});

  @override
  State<_EditDraftBottomSheet> createState() => _EditDraftBottomSheetState();
}

class _EditDraftBottomSheetState extends State<_EditDraftBottomSheet> {
  late final TextEditingController _subjectController;
  late final TextEditingController _englishController;
  late final TextEditingController _urduController;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.draft.subject);
    _englishController = TextEditingController(text: widget.draft.englishDraft);
    _urduController = TextEditingController(text: widget.draft.urduDraft);
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _englishController.dispose();
    _urduController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Account for keyboard heights
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Draft Edit Karen",
                style: AppTextStyles.title.copyWith(
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Subject / موضوع (English & Urdu)",
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _subjectController,
                    decoration: InputDecoration(
                      hintText: "Enter subject...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "English Version",
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _englishController,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: "Enter English content...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "اردو تحریر (Urdu Version)",
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _urduController,
                    maxLines: 8,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: AppTextStyles.urduBody.copyWith(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: "...اردو تحریر لکھیں",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                final updated = ActionDraft(
                  urduDraft: _urduController.text,
                  englishDraft: _englishController.text,
                  subject: _subjectController.text,
                  submissionAuthority: widget.draft.submissionAuthority,
                  submissionPortal: widget.draft.submissionPortal,
                  estimatedResponseDays: widget.draft.estimatedResponseDays,
                  actionType: widget.draft.actionType,
                  actionSummary: widget.draft.actionSummary,
                  documentExplanation: widget.draft.documentExplanation,
                );
                widget.onSave(updated);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Draft successfully updated!")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Mehfooz Karen (Save)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
