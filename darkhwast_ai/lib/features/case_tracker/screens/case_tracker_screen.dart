import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/providers/case_providers.dart';
import '../../../shared/widgets/case_card.dart';

class CaseTrackerScreen extends ConsumerWidget {
  const CaseTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cases = ref.watch(caseListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Aapke Cases"),
        centerTitle: true,
      ),
      body: cases.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () => ref.read(caseListProvider.notifier).loadCases(),
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: cases.length,
                itemBuilder: (context, index) {
                  return CaseCard(caseData: cases[index])
                      .animate()
                      .fadeIn(delay: (index * 100).ms)
                      .slideY(begin: 0.1, end: 0);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open_rounded, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          Text(
            "Abhi koi case nahi",
            style: AppTextStyles.title.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Text(
            "Document scan karen aur apna haq payein.",
            style: AppTextStyles.caption,
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}
