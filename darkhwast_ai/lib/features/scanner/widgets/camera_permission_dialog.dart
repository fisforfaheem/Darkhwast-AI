import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

Future<bool> showCameraPermissionDialog(
  BuildContext context, {
  required bool permanentlyDenied,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: !permanentlyDenied,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Camera zaroor hai',
        style: AppTextStyles.headline.copyWith(color: AppColors.primary),
      ),
      content: Text(
        permanentlyDenied
            ? 'Document scan ke liye Settings mein camera ki ijazat den.'
            : 'Bill ya notice scan karne ke liye camera access chahiye.',
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(permanentlyDenied ? 'Cancel' : 'Baad mein'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () async {
            if (permanentlyDenied) {
              await openAppSettings();
              if (ctx.mounted) Navigator.pop(ctx, true);
            } else {
              Navigator.pop(ctx, true);
            }
          },
          child: Text(permanentlyDenied ? 'Settings' : 'Ijazat den'),
        ),
      ],
    ),
  );
  return result ?? false;
}
