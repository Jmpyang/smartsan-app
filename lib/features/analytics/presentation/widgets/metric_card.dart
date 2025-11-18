import 'package:flutter/material.dart';
import 'package:smartsan_app/core/constants/app_colors.dart';
import 'package:smartsan_app/core/constants/app_text_styles.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subText;
  final IconData icon;
  final Color iconColor;

  const MetricCard({
    Key? key,
    required this.title,
    required this.value,
    this.subText,
    required this.icon,
    this.iconColor = AppColors.primaryGreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: AppTextStyles.bodyText1),
                const Spacer(),
                Icon(icon, color: iconColor, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.headline2.copyWith(color: AppColors.textDark)),
            if (subText != null)
              Text(
                subText!,
                style: AppTextStyles.smallGreen.copyWith(
                  color: subText!.contains('-') ? AppColors.alertRed : AppColors.primaryGreen,
                ),
              ),
          ],
        ),
      ),
    );
  }
}