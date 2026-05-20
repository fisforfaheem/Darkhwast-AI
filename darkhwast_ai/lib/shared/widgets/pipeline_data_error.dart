import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

/// Shown when a screen expects pipeline data that is missing.
class PipelineDataError extends StatelessWidget {
  const PipelineDataError({
    super.key,
    this.message = 'Analysis data nahi mili. Dobara scan karen.',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.urgent, size: 48),
            const SizedBox(height: 16),
            Text(
              'Kuch galat ho gaya',
              style: AppTextStyles.headline.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style:
                  AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => context.go('/home'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Home par wapas'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.go('/scanner'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Naya scan'),
            ),
          ],
        ),
      ),
    );
  }
}
