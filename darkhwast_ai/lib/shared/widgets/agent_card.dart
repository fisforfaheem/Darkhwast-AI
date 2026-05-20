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

  Color _cardBackground(
    bool isIdle,
    bool isLoading,
    bool isComplete,
    bool isError,
  ) {
    if (isUrgent && (isLoading || isComplete)) {
      return const Color(0xFFFFF5F5);
    }
    if (isLoading || isComplete || isError) {
      return AppColors.surface;
    }
    return Colors.white.withValues(alpha: 0.14);
  }

  @override
  Widget build(BuildContext context) {
    final bool isIdle = status == AgentStatus.idle;
    final bool isLoading = status == AgentStatus.loading;
    final bool isComplete = status == AgentStatus.complete;
    final bool isError = status == AgentStatus.error;
    final bool onDarkScaffold = isIdle;
    final cardBg = _cardBackground(isIdle, isLoading, isComplete, isError);

    Color borderColor = Colors.white.withValues(alpha: 0.25);
    if (isUrgent && (isLoading || isComplete)) {
      borderColor = AppColors.urgent;
    } else if (isLoading) {
      borderColor = AppColors.accent;
    } else if (isComplete) {
      borderColor = AppColors.success;
    }
    if (isError) borderColor = AppColors.urgent;

    final titleColor = onDarkScaffold
        ? Colors.white.withValues(alpha: 0.92)
        : AppColors.textPrimary;
    final subtitleColor = onDarkScaffold
        ? Colors.white.withValues(alpha: 0.72)
        : AppColors.textSecondary;

    return Container(
          constraints: const BoxConstraints(minHeight: 92),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border(left: BorderSide(color: borderColor, width: 6)),
            boxShadow: onDarkScaffold
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: onDarkScaffold
                        ? Colors.white.withValues(alpha: 0.12)
                        : borderColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: _buildIcon(
                    isLoading,
                    isComplete,
                    isError,
                    onDarkScaffold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "Agent $agentNumber: $title",
                              style: AppTextStyles.title.copyWith(
                                fontSize: 15,
                                color: titleColor,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isComplete && time != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              time!,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (isLoading)
                        TypewriterText(
                          text: message,
                          maxLines: 6,
                          overflow: TextOverflow.visible,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        )
                      else if (isComplete)
                        Text(
                          message,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                          softWrap: true,
                        )
                      else if (isError)
                        Text(
                          message,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.urgent,
                            height: 1.4,
                          ),
                          softWrap: true,
                        )
                      else
                        Text(
                          message.isNotEmpty
                              ? message
                              : "Waiting to analyze...",
                          style: AppTextStyles.caption.copyWith(
                            color: subtitleColor,
                            height: 1.4,
                          ),
                          softWrap: true,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(target: isLoading ? 1 : 0)
        .custom(
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

  Widget _buildIcon(
    bool isLoading,
    bool isComplete,
    bool isError,
    bool onDarkScaffold,
  ) {
    if (isComplete) {
      return const Icon(
        Icons.check_circle_rounded,
        color: AppColors.success,
        size: 26,
      ).animate().scale(curve: Curves.easeOutBack);
    }
    if (isError) {
      return const Icon(
        Icons.error_outline_rounded,
        color: AppColors.urgent,
        size: 26,
      );
    }

    final iconWidget = Icon(
      icon,
      color: isLoading
          ? AppColors.accent
          : onDarkScaffold
          ? Colors.white.withValues(alpha: 0.55)
          : AppColors.textSecondary,
      size: 22,
    );

    if (isLoading) {
      return iconWidget
          .animate(onPlay: (c) => c.repeat())
          .rotate(duration: 2.seconds);
    }

    return iconWidget;
  }
}
