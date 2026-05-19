import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

class HaqGauge extends StatelessWidget {
  final int score;
  final String reasoning;

  const HaqGauge({
    super.key,
    required this.score,
    required this.reasoning,
  });

  @override
  Widget build(BuildContext context) {
    Color gaugeColor;
    String strengthText;
    
    if (score >= 80) {
      gaugeColor = const Color(0xFF2D6A4F); // Forest Green
      strengthText = "mazboot hai ✓";
    } else if (score >= 50) {
      gaugeColor = const Color(0xFFF5A623); // Amber
      strengthText = "theek hai";
    } else {
      gaugeColor = const Color(0xFFD62828); // Crimson
      strengthText = "kamzor hai";
    }

    return Column(
      children: [
        CircularPercentIndicator(
          radius: 90.0,
          lineWidth: 14.0,
          percent: score / 100.0,
          animation: true,
          animationDuration: 1500,
          startAngle: 180,
          arcType: ArcType.FULL,
          circularStrokeCap: CircularStrokeCap.round,
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    "$score",
                    style: AppTextStyles.display.copyWith(fontSize: 48, color: gaugeColor),
                  ),
                  Text(
                    "/100",
                    style: AppTextStyles.body.copyWith(fontSize: 20, color: AppColors.textSecondary),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  reasoning,
                  style: AppTextStyles.caption.copyWith(fontSize: 13, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          progressColor: gaugeColor,
          backgroundColor: Colors.grey.withValues(alpha: 0.1),
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            style: AppTextStyles.title.copyWith(fontSize: 18, color: AppColors.textPrimary),
            children: [
              const TextSpan(text: "Aapka case "),
              TextSpan(
                text: strengthText,
                style: TextStyle(color: gaugeColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
