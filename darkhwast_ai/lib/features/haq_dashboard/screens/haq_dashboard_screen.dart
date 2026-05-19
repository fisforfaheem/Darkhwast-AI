import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../shared/widgets/haq_gauge.dart';
import '../../../core/providers/case_providers.dart';
import '../../agent_trace/providers/agent_pipeline_provider.dart';

class HaqDashboardScreen extends ConsumerWidget {
  const HaqDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rights = ref.watch(rightsAnalysisProvider);
    final doc = ref.watch(documentEntityProvider);
    final cluster = ref.watch(collectiveClusterProvider);
    final pipeline = ref.watch(pipelineProvider);
    final draft = ref.watch(complaintDraftProvider);

    // Get the first deadline for display logic
    final deadlines = pipeline.urgency.result ?? [];
    final mainDeadline = deadlines.isNotEmpty ? deadlines.first : null;

    if (rights == null || doc == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F4F0),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Aapka Haq Analysis",
            style: AppTextStyles.title.copyWith(color: AppColors.primary)),
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.close_rounded, color: AppColors.primary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          children: [
            // SECTION 1: HAQ Score Gauge
            HaqGauge(
              score: rights.haqScore,
              reasoning: rights.haqReasoning,
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.8, 0.8)),

            const SizedBox(height: 24),

            _buildImpactCard(rights)
                .animate()
                .fadeIn(delay: 80.ms, duration: 600.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // SECTION 2: Detail Card
            _buildDetailCard(doc, rights)
                .animate()
                .fadeIn(delay: 100.ms, duration: 600.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // SECTION 3: Deadline Card (Conditional)
            if (mainDeadline != null)
              _buildDeadlineCard(mainDeadline)
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 600.ms)
                  .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // SECTION 4: Collective Action Banner
            if (cluster != null)
              _buildCollectiveActionBanner(ref, cluster, context)
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 600.ms)
                  .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 32),

            // SECTION 5: Action Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => context.push('/complaint'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("${draft?.actionLabel ?? 'Complaint'} File Karen",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => context.push('/complaint'),
                    style: OutlinedButton.styleFrom(
                      side:
                          const BorderSide(color: AppColors.primary, width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Draft Dekhein",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactCard(dynamic rights) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Impact Analysis",
              style: AppTextStyles.title
                  .copyWith(fontSize: 14, color: AppColors.primary)),
          const SizedBox(height: 8),
          Text(
            "Agar aap abhi action na len to Rs. ${rights.amountOwed.toStringAsFixed(0)} ka nuqsan ho sakta hai. "
            "${rights.haqReasoning}",
            style: AppTextStyles.body.copyWith(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(dynamic doc, dynamic rights) {
    return Container(
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
        children: [
          _Row(
              icon: Icons.description_outlined,
              label: "Document",
              value: doc.type.displayName),
          _Row(
              icon: Icons.account_balance_outlined,
              label: "Authority",
              value: doc.authority),
          _Row(
              icon: Icons.gavel_outlined,
              label: "Violation",
              value: rights.violationType),
          _Row(
              icon: Icons.article_outlined,
              label: "Legal Basis",
              value: rights.legalBasis,
              isSmall: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          _Row(
              icon: Icons.money_off_rounded,
              label: "Max Allowed",
              value: "Rs. ${rights.maxAllowed.toStringAsFixed(0)}"),
          _Row(
              icon: Icons.request_quote_outlined,
              label: "Billed",
              value: "Rs. ${rights.actualCharged.toStringAsFixed(0)}"),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Aapko mila:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.primary)),
                Text(
                  "Rs. ${rights.amountOwed.toStringAsFixed(0)}",
                  style: AppTextStyles.headline
                      .copyWith(color: AppColors.primary, fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineCard(dynamic deadline) {
    final isGhost = deadline.isHidden == true;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.urgent, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
                  color: AppColors.urgent, size: 32)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isGhost)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      "Ghost Deadline Detector",
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.urgent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                Text(
                  isGhost
                      ? "⚠️ Chhupi hui deadline: ${deadline.label}"
                      : "⚠️ ${deadline.daysRemaining} din baaki hain",
                  style: AppTextStyles.title
                      .copyWith(color: AppColors.urgent, fontSize: 16),
                ),
                const SizedBox(height: 4),
                _CountdownWidget(daysRemaining: deadline.daysRemaining as int),
                const SizedBox(height: 4),
                Text(
                  isGhost
                      ? "Fine print / footnote mein mili — fauran action len"
                      : "Fauran action len",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.urgent),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).custom(
          duration: 2.seconds,
          builder: (context, value, child) => Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.urgent.withValues(alpha: 0.1 * value),
                  blurRadius: 10 * value,
                  spreadRadius: 2 * value,
                ),
              ],
            ),
            child: child,
          ),
        );
  }

  Widget _buildCollectiveActionBanner(
      WidgetRef ref, dynamic cluster, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.handshake_rounded,
                    color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${cluster.count} logon ne same issue face kiya",
                      style: AppTextStyles.title
                          .copyWith(color: AppColors.primary, fontSize: 16),
                    ),
                    Text(
                      "Mil kar file karen — zyada asar hoga",
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(joinCollectiveProvider.notifier).state = true;
                    context.push('/complaint');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text("Shamil Hoon"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(joinCollectiveProvider.notifier).state = false;
                    context.push('/complaint');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text("Akela File Karen"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isSmall;

  const _Row(
      {required this.icon,
      required this.label,
      required this.value,
      this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: isSmall
                  ? AppTextStyles.caption
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 12)
                  : AppTextStyles.title
                      .copyWith(fontSize: 14, color: AppColors.primary),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownWidget extends StatefulWidget {
  final int daysRemaining;

  const _CountdownWidget({required this.daysRemaining});

  @override
  State<_CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<_CountdownWidget> {
  late Timer _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();
    _timeLeft = Duration(days: widget.daysRemaining.clamp(0, 365));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeLeft = _timeLeft - const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _timeLeft.inDays;
    final hours = _timeLeft.inHours.remainder(24);
    final minutes = _timeLeft.inMinutes.remainder(60);
    final seconds = _timeLeft.inSeconds.remainder(60);

    return Text(
      "${days}d : ${hours}h : ${minutes}m : ${seconds}s",
      style: const TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          color: AppColors.urgent),
    );
  }
}
