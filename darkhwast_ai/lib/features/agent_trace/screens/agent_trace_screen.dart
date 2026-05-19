import 'package:darkhwast_ai/shared/widgets/typewriter_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/models/agent_state.dart';
import '../../../core/models/user_intent.dart';
import '../../../shared/widgets/agent_card.dart';
import '../../../core/providers/case_providers.dart';
import '../providers/agent_pipeline_provider.dart';
import '../providers/pipeline_state.dart';

class AgentTraceScreen extends ConsumerStatefulWidget {
  final File? documentFile;
  final String? voiceText;

  /// If true, this screen is resuming Phase 2 (no need to re-run Phase 1).
  final bool isResuming;

  const AgentTraceScreen({
    super.key,
    this.documentFile,
    this.voiceText,
    this.isResuming = false,
  });

  @override
  ConsumerState<AgentTraceScreen> createState() => _AgentTraceScreenState();
}

class _AgentTraceScreenState extends ConsumerState<AgentTraceScreen> {
  bool _showBottomSummary = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isResuming) {
        ref.read(joinCollectiveProvider.notifier).state = false;
        // Run Phase 1 only — pipeline will pause for intent selection
        ref.read(pipelineProvider.notifier).runPhase1(
              widget.documentFile,
              text: widget.voiceText,
              autoDetect: false,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pipeline = ref.watch(pipelineProvider);
    final urgentDeadline = pipeline.hasUrgentDeadline;
    final userIntent = pipeline.userIntent;

    // Listen for awaitingIntent → navigate to intent selection
    ref.listen(pipelineProvider, (previous, next) {
      if (next.isAwaitingIntent &&
          !(previous?.isAwaitingIntent ?? false)) {
        context.go('/intent-selection');
      }
    });

    // Listen for completion to show summary and then navigate
    ref.listen(pipelineProvider, (previous, next) {
      if (next.isComplete && !(previous?.isComplete ?? false)) {
        setState(() => _showBottomSummary = true);

        final isExplainOnly =
            next.userIntent?.intent == UserIntent.explainDocument;

        Future.delayed(const Duration(seconds: 2), () {
          if (!context.mounted) return;
          if (isExplainOnly) {
            context.go('/document-explanation');
          } else {
            context.go('/haq-dashboard');
          }
        });
      }
    });

    if (pipeline.isError) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  'Pipeline Error',
                  style: AppTextStyles.display
                      .copyWith(color: Colors.white, fontSize: 22),
                ),
                const SizedBox(height: 16),
                Text(
                  pipeline.docIntel.agentMessage ?? 'Unknown error',
                  style: AppTextStyles.body.copyWith(color: Colors.white70),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => context.go('/about'),
                  child: const Text('About — check .env / Demo Mode'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Dynamic Agent 4 label based on intent
    final agent4Title = userIntent?.intent.agent4Label ?? 'Action Drafter';

    return Scaffold(
      backgroundColor: AppColors.primary, // Deep Teal #0D3B44
      body: Stack(
        children: [
          // Background Glow Decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.1),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(1, 1),
                end: const Offset(1.2, 1.2),
                duration: 3.seconds),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "AI Soch Rahi Hai...",
                        style: AppTextStyles.display
                            .copyWith(color: Colors.white, fontSize: 24),
                      ).animate().fadeIn().slideX(),
                      const SizedBox(height: 8),
                      TypewriterText(
                        text: _getCurrentAgentMessage(pipeline),
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

                // Agent Cards List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      AgentCard(
                        agentNumber: 1,
                        icon: Icons.document_scanner_rounded,
                        title: "Document Intelligence",
                        status: pipeline.docIntel.status,
                        message: pipeline.docIntel.agentMessage ??
                            "Extracting text...",
                        time: "1.2s",
                      ),
                      AgentCard(
                        agentNumber: 2,
                        icon: Icons.timer_outlined,
                        title: "Urgency Detector",
                        status: pipeline.urgency.status,
                        message: pipeline.urgency.agentMessage ??
                            "Scanning deadlines...",
                        time: "0.8s",
                        isUrgent: urgentDeadline &&
                            pipeline.urgency.status != AgentStatus.idle,
                      ),
                      AgentCard(
                        agentNumber: 3,
                        icon: Icons.balance_rounded,
                        title: "Rights Intelligence",
                        status: pipeline.rights.status,
                        message:
                            pipeline.rights.agentMessage ?? "Checking laws...",
                        time: "2.5s",
                      ),
                      AgentCard(
                        agentNumber: 4,
                        icon: _getAgent4Icon(userIntent?.intent),
                        title: agent4Title,
                        status: pipeline.drafter.status,
                        message: pipeline.drafter.agentMessage ??
                            "Drafting action...",
                        time: "1.9s",
                      ),
                      AgentCard(
                        agentNumber: 5,
                        icon: Icons.group_rounded,
                        title: "Collective Pattern",
                        status: pipeline.pattern.status,
                        message: pipeline.pattern.agentMessage ??
                            "Finding clusters...",
                        time: "0.5s",
                      ),
                      const SizedBox(height: 100), // Space for bottom summary
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Summary Sheet
          if (_showBottomSummary)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                            color: AppColors.success, size: 64)
                        .animate()
                        .scale(curve: Curves.easeOutBack),
                    const SizedBox(height: 16),
                    Text(
                      "Analysis Mukammal!",
                      style: AppTextStyles.headline
                          .copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getCompletionMessage(userIntent?.intent),
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        final isExplainOnly =
                            userIntent?.intent == UserIntent.explainDocument;
                        context.go(isExplainOnly
                            ? '/document-explanation'
                            : '/haq-dashboard');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: const Text("Details Dekhein →"),
                    ),
                  ],
                ),
              ).animate().slideY(
                  begin: 1,
                  end: 0,
                  duration: 500.ms,
                  curve: Curves.easeOutQuart),
            ),
        ],
      ),
    );
  }

  IconData _getAgent4Icon(UserIntent? intent) {
    if (intent == null) return Icons.edit_note_rounded;
    return intent.icon;
  }

  String _getCompletionMessage(UserIntent? intent) {
    switch (intent) {
      case UserIntent.explainDocument:
        return "Document ki wazahat tayyar hai.";
      case UserIntent.writeAppeal:
        return "Aapki appeal tayyar hai.";
      case UserIntent.requestReduction:
        return "Reduction ki darkhwast tayyar hai.";
      case UserIntent.requestCorrection:
        return "Correction request tayyar hai.";
      default:
        return "Aapka HAQ Score tayyar hai.";
    }
  }

  String _getCurrentAgentMessage(PipelineState pipeline) {
    if (pipeline.docIntel.status == AgentStatus.loading) {
      return "Document ko samjha ja raha hai...";
    }
    if (pipeline.urgency.status == AgentStatus.loading) {
      return "Deadlines check ki ja rahi hain...";
    }
    if (pipeline.isAwaitingIntent) {
      return "Aap se pooch rahe hain kya karna hai...";
    }
    if (pipeline.rights.status == AgentStatus.loading) {
      return "Qanoon ke mutabiq analysis ho rahi hai...";
    }
    if (pipeline.drafter.status == AgentStatus.loading) {
      return "Aapki darkhwast likhi ja rahi hai...";
    }
    if (pipeline.pattern.status == AgentStatus.loading) {
      return "Milte julte cases talaash kiye ja rahe hain...";
    }
    if (pipeline.isComplete) {
      return "Analysis khatam ho gayi!";
    }
    return "Taiyari ho rahi hai...";
  }
}
