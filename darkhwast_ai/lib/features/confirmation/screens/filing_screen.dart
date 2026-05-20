import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/providers/case_providers.dart';
import '../../agent_trace/providers/agent_pipeline_provider.dart';

class FilingScreen extends ConsumerStatefulWidget {
  const FilingScreen({super.key});

  @override
  ConsumerState<FilingScreen> createState() => _FilingScreenState();
}

class _FilingScreenState extends ConsumerState<FilingScreen> {
  @override
  void initState() {
    super.initState();
    _simulateFiling();
  }

  void _simulateFiling() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) {
      context.go('/confirmation');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cluster = ref.watch(collectiveClusterProvider);
    final joinedCollective = ref.watch(joinCollectiveProvider);
    final isCollective = joinedCollective && cluster != null;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated airplane toward portal
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Portal Icon
                  const Icon(Icons.account_balance_rounded,
                          color: Colors.white, size: 80)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .shimmer(
                          duration: 2.seconds,
                          color: AppColors.accent.withValues(alpha: 0.3)),

                  // Flying Airplane
                  const Icon(Icons.send_rounded,
                          color: AppColors.accent, size: 40)
                      .animate(onPlay: (c) => c.repeat())
                      .move(
                        begin: const Offset(-150, 50),
                        end: const Offset(50, -50),
                        duration: 1.5.seconds,
                        curve: Curves.easeInCirc,
                      )
                      .fadeOut(delay: 1.2.seconds, duration: 300.ms)
                      .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(0.5, 0.5)),
                ],
              ),
            ),

            const SizedBox(height: 40),

            Text(
              isCollective
                  ? "${cluster.count} logon ke saath submission tayyar ho rahi hai..."
                  : "Aap ki darkhwast tayyar ho rahi hai...",
              style: AppTextStyles.headline
                  .copyWith(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 800.ms),
            const SizedBox(height: 8),
            Text(
              'Demo: portal integration simulated',
              style: AppTextStyles.caption
                  .copyWith(color: Colors.white38, fontSize: 12),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Animated Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ).animate().scaleX(
                      begin: 0,
                      end: 1,
                      duration: 2.8.seconds,
                      curve: Curves.easeInOut,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
