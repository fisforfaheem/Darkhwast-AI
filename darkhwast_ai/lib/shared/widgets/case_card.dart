import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/models/case_entity.dart';
import '../../../core/models/user_intent.dart';

class CaseCard extends StatefulWidget {
  final CaseEntity caseData;

  const CaseCard({
    super.key,
    required this.caseData,
  });

  @override
  State<CaseCard> createState() => _CaseCardState();
}

class _CaseCardState extends State<CaseCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: 300.ms,
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
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
        border: Border.all(
          color: _isExpanded
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Main Info Row
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_getIcon(widget.caseData.document.type.name),
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.caseData.document.authority,
                            style: AppTextStyles.title.copyWith(fontSize: 16),
                          ),
                          Text(
                            widget.caseData.caseReference,
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildStatusChip(widget.caseData.status),
                        const SizedBox(height: 4),
                        if (widget.caseData.userIntent != UserIntent.autoDetect &&
                            widget.caseData.userIntent != UserIntent.fileComplaint)
                          Text(
                            widget.caseData.actionDraft.actionLabel,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          )
                        else
                          Text(
                            "HAQ: ${widget.caseData.rightsAnalysis.haqScore}",
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Expanded Timeline
              if (_isExpanded)
                _buildTimeline(widget.caseData)
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: -0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(CaseEntity data) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 16),
          _TimelineRow(
            label: "${data.actionDraft.actionLabel} Filed",
            date: DateFormat('dd MMM yyyy').format(data.filedDate),
            isDone: true,
            isFirst: true,
          ),
          _TimelineRow(
            label: "Department Review",
            date:
                data.status == CaseStatus.pending ? "Processing" : "Completed",
            isDone: data.status != CaseStatus.pending,
          ),
          _TimelineRow(
            label: "Response Due",
            date: DateFormat('dd MMM yyyy')
                .format(data.filedDate.add(const Duration(days: 14))),
            isDone: false,
            isOverdue: DateTime.now()
                .isAfter(data.filedDate.add(const Duration(days: 14))),
          ),
          _TimelineRow(
            label: "Resolution",
            date: "Expected",
            isDone: data.status == CaseStatus.resolved,
            isLast: true,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/logs'),
              icon: const Icon(Icons.analytics_outlined, size: 18),
              label: const Text('Agent Log Dekhein'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(CaseStatus status) {
    Color color;
    String label;
    switch (status) {
      case CaseStatus.pending:
        color = AppColors.accent;
        label = "Processing";
        break;
      case CaseStatus.filed:
        color = AppColors.success;
        label = "Filed";
        break;
      case CaseStatus.resolved:
        color = AppColors.primary;
        label = "Resolved";
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption
            .copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  IconData _getIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('electricity')) return Icons.electric_bolt_rounded;
    if (t.contains('gas')) return Icons.fire_hydrant_alt_rounded;
    if (t.contains('bisp')) return Icons.account_balance_rounded;
    if (t.contains('tax')) return Icons.description_rounded;
    if (t.contains('water')) return Icons.water_drop_rounded;
    if (t.contains('property')) return Icons.home_rounded;
    if (t.contains('pension')) return Icons.elderly_rounded;
    if (t.contains('nadra')) return Icons.credit_card_rounded;
    if (t.contains('challan') || t.contains('police')) return Icons.local_police_rounded;
    if (t.contains('school') || t.contains('fee')) return Icons.school_rounded;
    if (t.contains('municipal')) return Icons.location_city_rounded;
    if (t.contains('legal') || t.contains('court')) return Icons.gavel_rounded;
    if (t.contains('government') || t.contains('form')) return Icons.article_rounded;
    return Icons.insert_drive_file_rounded;
  }
}

class _TimelineRow extends StatelessWidget {
  final String label;
  final String date;
  final bool isDone;
  final bool isOverdue;
  final bool isFirst;
  final bool isLast;

  const _TimelineRow({
    required this.label,
    required this.date,
    required this.isDone,
    this.isOverdue = false,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                if (!isFirst)
                  Container(
                      width: 1,
                      height: 10,
                      color: Colors.grey.withValues(alpha: 0.3)),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOverdue
                        ? AppColors.urgent
                        : (isDone
                            ? AppColors.success
                            : Colors.grey.withValues(alpha: 0.3)),
                  ),
                ),
                if (!isLast)
                  Expanded(
                      child: Container(
                          width: 1, color: Colors.grey.withValues(alpha: 0.3))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label,
                      style: AppTextStyles.caption.copyWith(
                        color: isOverdue
                            ? AppColors.urgent
                            : (isDone
                                ? AppColors.textPrimary
                                : AppColors.textSecondary),
                        fontWeight:
                            isDone ? FontWeight.bold : FontWeight.normal,
                      )),
                  Text(
                    isOverdue ? "Response nahi aaya" : date,
                    style: AppTextStyles.caption.copyWith(
                      color: isOverdue
                          ? AppColors.urgent
                          : AppColors.textSecondary,
                      fontSize: 10,
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
}
