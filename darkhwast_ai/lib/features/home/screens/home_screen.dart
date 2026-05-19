import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/providers/case_providers.dart';
import '../../../shared/widgets/case_card.dart';
import '../../scanner/screens/scanner_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cases = ref.watch(caseListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "DarkhwastAI",
          style: AppTextStyles.headline
              .copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/about'),
            icon: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
            tooltip: "Settings & About",
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Koi bhi document — AI samjhe ga, haq dila ye ga",
                style:
                    AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 40),
            _buildHeroScanButton(context),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSecondaryAction(
                      icon: Icons.photo_library_outlined,
                      label: "Gallery",
                      onTap: () => context.push('/scanner'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSecondaryAction(
                      icon: Icons.mic_none_rounded,
                      label: "Voice",
                      onTap: () =>
                          context.push('/scanner', extra: ScannerMode.voice),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Cases",
                    style:
                        AppTextStyles.title.copyWith(color: AppColors.primary),
                  ),
                  TextButton(
                    onPressed: () => context.push('/cases'),
                    child: const Text("View All",
                        style: TextStyle(color: AppColors.accent)),
                  ),
                ],
              ),
            ),
            if (cases.isEmpty)
              _buildEmptyHistory()
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: cases.length > 3 ? 3 : cases.length,
                itemBuilder: (context, index) =>
                    CaseCard(caseData: cases[index]),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroScanButton(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Material(
            color: AppColors.primary,
            shape: const CircleBorder(),
            elevation: 4,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => context.push('/scanner'),
              child: const SizedBox(
                width: 112,
                height: 112,
                child: Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: 44),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Document scan karen",
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(label,
                  style: AppTextStyles.body.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Padding(
      padding: const EdgeInsets.all(48.0),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.history_rounded,
                size: 64,
                color: AppColors.textSecondary.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              "Abhi koi case nahi. Scan karen!",
              style:
                  AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
