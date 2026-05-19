import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

enum ChipType { pending, filed, resolved }

class StatusChip extends StatelessWidget {
  final ChipType type;
  final String? label;

  const StatusChip({
    super.key,
    required this.type,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (type) {
      case ChipType.pending:
        color = AppColors.statusPending;
        text = label ?? "Pending";
        break;
      case ChipType.filed:
        color = AppColors.statusFiled;
        text = label ?? "Filed";
        break;
      case ChipType.resolved:
        color = AppColors.statusResolved;
        text = label ?? "Resolved";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
