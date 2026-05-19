import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/models/agent_state.dart';
import 'typewriter_text.dart';

class AgentCard extends StatelessWidget {
  final int agentNumber;
  final IconData icon;
  final String title;
  final AgentStatus status;
  final String message;
  final String? time;
  final bool isUrgent;

  const AgentCard({
    super.key,
    required this.agentNumber,
    required this.icon,
    required this.title,
    required this.status,
    required this.message,
    this.time,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIdle = status == AgentStatus.idle;
    final bool isLoading = status == AgentStatus.loading;
    final bool isComplete = status == AgentStatus.complete;
    final bool isError = status == AgentStatus.error;

    Color borderColor = Colors.grey.withValues(alpha: 0.2);
    if (isUrgent && (isLoading || isComplete)) {
      borderColor = AppColors.urgent;
    } else if (isLoading) {
      borderColor = AppColors.accent;
    } else if (isComplete) {
      borderColor = AppColors.primary;
    }
    if (isError) borderColor = AppColors.urgent;

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isUrgent && (isLoading || isComplete)
            ? AppColors.urgent.withValues(alpha: 0.08)
            : isComplete
                ? AppColors.primary.withValues(alpha: 0.05)
                : AppColors.surface.withValues(alpha: isIdle ? 0.4 : 1.0),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: borderColor,
            width: 6,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icon section
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: _buildIcon(isLoading, isComplete, isError),
            ),
            const SizedBox(width: 16),

            // Content section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Agent $agentNumber: $title",
                    style: AppTextStyles.title.copyWith(
                      fontSize: 16,
                      color: isIdle
                          ? AppColors.textSecondary.withValues(alpha: 0.5)
                          : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isLoading)
                    Row(
                      children: [
                        Expanded(
                          child: TypewriterText(
                            text: message,
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.accent),
                          ),
                        ),
                        Text(
                          "...",
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.accent),
                        ).animate(onPlay: (c) => c.repeat()).shimmer(),
                      ],
                    )
                  else if (isComplete)
                    Text(
                      message,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.primary),
                    )
                  else if (isError)
                    Text(
                      message,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.urgent),
                    )
                  else
                    Text(
                      "Waiting to analyze...",
                      style: AppTextStyles.caption.copyWith(
                          color:
                              AppColors.textSecondary.withValues(alpha: 0.5)),
                    ),
                ],
              ),
            ),

            // Right side (Time or Status)
            if (isComplete && time != null)
              Text(
                time!,
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.bold),
              ).animate().fadeIn(),
          ],
        ),
      ),
    ).animate(target: isLoading ? 1 : 0).custom(
          duration: 1.seconds,
          builder: (context, value, child) => Container(
            decoration: BoxDecoration(
              boxShadow: [
                if (isLoading)
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.2 * value),
                    blurRadius: 15 * value,
                    spreadRadius: 2 * value,
                  ),
              ],
            ),
            child: child,
          ),
        );
  }

  Widget _buildIcon(bool isLoading, bool isComplete, bool isError) {
    if (isComplete) {
      return const Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 28)
          .animate()
          .scale(curve: Curves.easeOutBack);
    }
    if (isError) {
      return const Icon(Icons.error_outline_rounded,
          color: AppColors.urgent, size: 28);
    }

    final iconWidget = Icon(
      icon,
      color: isLoading
          ? AppColors.accent
          : AppColors.textSecondary.withValues(alpha: 0.5),
      size: 24,
    );

    if (isLoading) {
      return iconWidget
          .animate(onPlay: (c) => c.repeat())
          .rotate(duration: 2.seconds)
          .then()
          .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.1, 1.1),
              duration: 1.seconds);
    }

    return iconWidget;
  }
}
