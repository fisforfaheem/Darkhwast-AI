import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

class LoadingOverlay extends StatelessWidget {
  final String message;

  const LoadingOverlay({
    super.key,
    this.message = "Analysis chal rahi hai...",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.network(
              'https://assets10.lottiefiles.com/packages/lf20_m6cu96.json', // Search animation
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) => const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: AppTextStyles.headline.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
