import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../providers/agent_pipeline_provider.dart';
import 'agent_log_exporter.dart';

class LogViewerScreen extends ConsumerWidget {
  const LogViewerScreen({super.key});

  Future<void> _share(BuildContext context, WidgetRef ref) async {
    final pipeline = ref.read(pipelineProvider);
    if (!pipeline.isComplete && !pipeline.isError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pehle pipeline complete karen (scan karen).')),
      );
      return;
    }
    try {
      await AgentLogExporter.shareLog(pipeline);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    }
  }

  Future<void> _copy(BuildContext context, WidgetRef ref) async {
    final pipeline = ref.read(pipelineProvider);
    await AgentLogExporter.copyToClipboard(pipeline);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agent trace copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pipeline = ref.watch(pipelineProvider);
    final logData = pipeline.toJson();
    final agents = logData['agents'] as List;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Agentic Reasoning Trace'),
        actions: [
          IconButton(
            tooltip: 'Copy JSON',
            onPressed: () => _copy(context, ref),
            icon: const Icon(Icons.copy_rounded),
          ),
          IconButton(
            tooltip: 'Share JSON',
            onPressed: () => _share(context, ref),
            icon: const Icon(Icons.share_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildHeader(logData),
          const SizedBox(height: 24),
          Text('Agent Breakdown', style: AppTextStyles.title),
          const SizedBox(height: 16),
          ...agents.map((a) => _buildAgentCard(a as Map<String, dynamic>)),
          const SizedBox(height: 24),
          _buildOutcome(logData['final_outcome'] as Map<String, dynamic>),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _share(context, ref),
              icon: const Icon(Icons.ios_share_rounded),
              label: const Text('Share Trace (For Judges)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> data) {
    final orch = data['orchestration'] as Map<String, dynamic>?;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['trace_format'] != null)
            Text(
              '${data['trace_format']} · Google Antigravity',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 6),
          Text(
            'RUN ID: ${data['run_id']}',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Timestamp: ${data['timestamp']}',
            style: AppTextStyles.caption.copyWith(color: Colors.white70),
          ),
          if (orch != null) ...[
            const SizedBox(height: 4),
            Text(
              '${orch['llm']} · ${orch['llm_mode'] ?? orch['execution_mode']}',
              style: AppTextStyles.caption.copyWith(color: Colors.white70),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Doc: ${data['input_document_type']} · ${data['input_authority'] ?? 'N/A'}',
            style: AppTextStyles.caption.copyWith(color: AppColors.accent),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCard(Map<String, dynamic> agent) {
    final isComplete = agent['status'] == 'complete';
    final facts = (agent['facts'] as List?)?.cast<String>() ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(
          isComplete ? Icons.check_circle_rounded : Icons.pending_rounded,
          color: isComplete ? AppColors.success : Colors.grey,
        ),
        title: Text(
          agent['agent'] as String,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Step ${agent['step'] ?? '?'} · ${agent['status']}'
          '${agent['duration_ms'] != null ? ' · ${agent['duration_ms']}ms' : ''}',
          style: AppTextStyles.caption,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'REASONING',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(agent['reasoning'] as String,
                    style: AppTextStyles.body.copyWith(fontSize: 13)),
                if (facts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'FACTS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...facts.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ',
                              style: TextStyle(color: AppColors.primary)),
                          Expanded(
                              child: Text(f, style: AppTextStyles.caption)),
                        ],
                      ),
                    ),
                  ),
                ],
                if (agent['decision'] != null) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'DECISION',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    agent['decision'] as String,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                const Text(
                  'OUTPUT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    agent['output_summary'] as String,
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutcome(Map<String, dynamic> outcome) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Final Outcome',
            style: AppTextStyles.title
                .copyWith(fontSize: 16, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          _outcomeRow('HAQ Score', '${outcome['haq_score']}/100'),
          _outcomeRow('Amount Owed', 'Rs. ${outcome['amount_owed']}'),
          _outcomeRow('Violation', '${outcome['violation_type']}'),
          _outcomeRow('Case Ref', '${outcome['case_reference']}'),
          _outcomeRow('Collective', '${outcome['collective_action_joined']}'),
          _outcomeRow('Urgent', '${outcome['urgent_deadline_detected']}'),
          _outcomeRow(
              'Ghost Deadline', '${outcome['ghost_deadline_detected']}'),
          _outcomeRow('Action', '${outcome['recommended_action']}'),
        ],
      ),
    );
  }

  Widget _outcomeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
