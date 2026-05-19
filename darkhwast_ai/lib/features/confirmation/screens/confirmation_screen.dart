import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/models/case_entity.dart';
import '../../../core/models/complaint_draft.dart';
import '../../../core/providers/case_providers.dart';
import '../../agent_trace/providers/agent_pipeline_provider.dart';

class ConfirmationScreen extends ConsumerStatefulWidget {
  const ConfirmationScreen({super.key});

  @override
  ConsumerState<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends ConsumerState<ConfirmationScreen> {
  late final String _caseRef;
  final String _today = DateFormat('dd MMM yyyy').format(DateTime.now());
  bool _caseSaved = false;

  @override
  void initState() {
    super.initState();
    final random = Random().nextInt(9000) + 1000;
    _caseRef = "DW-2026-ISB-$random";
    WidgetsBinding.instance.addPostFrameCallback((_) => _persistCase());
  }

  Future<void> _persistCase() async {
    if (_caseSaved) return;

    final doc = ref.read(documentEntityProvider);
    final rights = ref.read(rightsAnalysisProvider);
    final draft = ref.read(complaintDraftProvider);
    final joinedCollective = ref.read(joinCollectiveProvider);
    final cluster = ref.read(collectiveClusterProvider);

    if (doc == null || rights == null || draft == null) return;

    final now = DateTime.now();
    final caseEntity = CaseEntity(
      id: const Uuid().v4(),
      document: doc,
      rightsAnalysis: rights,
      actionDraft: draft,
      status: CaseStatus.filed,
      filedDate: now,
      followUpDates: [
        now.add(const Duration(days: 7)),
        now.add(const Duration(days: 14)),
        now.add(const Duration(days: 30)),
      ],
      caseReference: _caseRef,
      joinedCollective: joinedCollective,
    );

    await ref.read(caseListProvider.notifier).addCase(
          caseEntity,
          cluster: cluster,
          joinedCollective: joinedCollective,
        );
    ref.read(pipelineProvider.notifier).setFilingMeta(
          caseReference: _caseRef,
          collectiveJoined: joinedCollective,
        );
    if (mounted) setState(() => _caseSaved = true);
  }

  @override
  Widget build(BuildContext context) {
    final rights = ref.watch(rightsAnalysisProvider);
    final doc = ref.watch(documentEntityProvider);
    final draft = ref.watch(complaintDraftProvider);
    final cluster = ref.watch(collectiveClusterProvider);
    final joinedCollective = ref.watch(joinCollectiveProvider);
    final isCollective = joinedCollective && cluster != null;
    final amountOwed = rights?.amountOwed ?? 0;
    final authority = draft?.submissionAuthority ?? 'Citizens Portal';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 100)
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.easeOutBack)
                  .fadeIn(),
              const SizedBox(height: 24),
              Text(
                "${draft?.actionLabel ?? 'Complaint'} File Ho Gayi!",
                style: AppTextStyles.headline
                    .copyWith(color: AppColors.primary, fontSize: 24),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 32),
              _buildBeforeAfterCard(amountOwed, isCollective, cluster?.count),
              const SizedBox(height: 24),
              _buildExecutionLog(authority, isCollective, cluster?.count),
              const SizedBox(height: 24),
              _buildCaseRefCard(
                  rights, authority, draft?.estimatedResponseDays ?? 14),
              const SizedBox(height: 24),
              _buildTimeline(draft),
              const SizedBox(height: 24),
              if (isCollective) _buildCollectiveBanner(cluster.count),
              const SizedBox(height: 40),
              _buildActions(context, rights, doc, draft),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBeforeAfterCard(
      double amountOwed, bool isCollective, int? clusterCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("System State Change",
              style: AppTextStyles.title.copyWith(fontSize: 16)),
          const SizedBox(height: 16),
          _StateRow(
            label: "BEFORE",
            value:
                "Unfiled · Rs. ${amountOwed.toStringAsFixed(0)} at risk · No case ref",
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          const Icon(Icons.arrow_downward_rounded, color: AppColors.accent),
          const SizedBox(height: 12),
          _StateRow(
            label: "AFTER",
            value: isCollective
                ? "Filed · $_caseRef · ${clusterCount ?? 0} citizens · Follow-ups scheduled"
                : "Filed · $_caseRef · Follow-ups Day 7/14/30 scheduled",
            color: AppColors.success,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildExecutionLog(
      String authority, bool isCollective, int? clusterCount) {
    final logs = <String>[
      'POST mock://citizens-portal/complaints → 201 Created',
      'CASE_REF $_caseRef assigned',
      'SCHEDULE follow_up +7d, +14d, +30d',
      if (isCollective)
        'JOIN collective_cluster_${authority.replaceAll(' ', '_')} (count: ${clusterCount ?? 0})',
      'NOTIFY citizen: confirmation receipt generated',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal_rounded,
                  color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Text(
                "Action Execution Log",
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...logs.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '> $line',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildCaseRefCard(dynamic rights, String authority, int responseDays) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            const Border(left: BorderSide(color: AppColors.primary, width: 6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DataRow(label: "Case Ref:", value: _caseRef, isBold: true),
          const SizedBox(height: 12),
          _DataRow(label: "Authority:", value: authority),
          const SizedBox(height: 8),
          _DataRow(label: "Filed:", value: _today),
          const SizedBox(height: 8),
          _DataRow(
            label: "Amount Owed:",
            value: "Rs. ${rights?.amountOwed.toStringAsFixed(0) ?? '0'}",
            valueColor: AppColors.primary,
          ),
          const SizedBox(height: 8),
          _DataRow(label: "Expected:", value: "$responseDays working days"),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildTimeline(ActionDraft? draft) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Follow-up Schedule",
              style: AppTextStyles.title.copyWith(fontSize: 16)),
          const SizedBox(height: 20),
          _TimelineItem(
              day: "Day 0", task: "${draft?.actionLabel ?? 'Complaint'} Filed", isComplete: true),
          const _TimelineItem(day: "Day 7", task: "Auto reminder scheduled"),
          const _TimelineItem(day: "Day 14", task: "Status check scheduled"),
          const _TimelineItem(day: "Day 30", task: "Escalation if no response"),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms);
  }

  Widget _buildCollectiveBanner(int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.groups_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Aap $count logon ke saath case mein shamil hain",
              style: AppTextStyles.body.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 900.ms).shake();
  }

  Widget _buildActions(BuildContext context, dynamic rights, dynamic doc, ActionDraft? draft) {
    final receipt = '''
DarkhwastAI — ${draft?.actionLabel ?? 'Complaint'} Receipt
Case: $_caseRef
Filed: $_today
Amount claimed: Rs. ${rights?.amountOwed.toStringAsFixed(0) ?? '0'}
Document: ${doc?.type.displayName ?? 'N/A'}
''';

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/logs'),
            icon: const Icon(Icons.analytics_outlined),
            label: const Text('Agent Log Dekhein'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.accent, width: 2),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: receipt));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Receipt copied to clipboard!")),
              );
            },
            icon: const Icon(Icons.share_rounded),
            label: const Text("Receipt Share Karen"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.go('/cases'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Case Track Karen"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.go('/home'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Ghar Wapis (Home)"),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 1100.ms);
  }
}

class _StateRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StateRow(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption
                .copyWith(color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value,
            style: AppTextStyles.body
                .copyWith(fontSize: 13, color: AppColors.textPrimary)),
      ],
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _DataRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? AppColors.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String day;
  final String task;
  final bool isComplete;

  const _TimelineItem(
      {required this.day, required this.task, this.isComplete = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isComplete
                  ? AppColors.success
                  : Colors.grey.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(width: 16),
          Text(day,
              style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(width: 12),
          Expanded(
              child:
                  Text(task, style: AppTextStyles.body.copyWith(fontSize: 14))),
          if (isComplete)
            const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 16),
        ],
      ),
    );
  }
}
