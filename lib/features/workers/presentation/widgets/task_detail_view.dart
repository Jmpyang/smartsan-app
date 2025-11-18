import 'package:flutter/material.dart';
import 'package:smartsan_app/core/constants/app_colors.dart';
import 'package:smartsan_app/core/constants/app_text_styles.dart';

class TaskCard extends StatelessWidget {
  final String taskType;
  final String status;
  final String location;
  final String distanceTime;
  final Color statusColor;
  final TextStyle statusTextStyle;

  const TaskCard({
    Key? key,
    required this.taskType,
    required this.status,
    required this.location,
    required this.distanceTime,
    required this.statusColor,
    required this.statusTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  taskType,
                  style: AppTextStyles.subhead1,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: statusTextStyle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textLight),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: AppTextStyles.bodyText1.copyWith(color: AppColors.textLight),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: AppColors.textLight),
                const SizedBox(width: 4),
                Text(
                  distanceTime,
                  style: AppTextStyles.bodyText1.copyWith(color: AppColors.textLight),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement Navigate action
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Navigating to $location')),
                    );
                  },
                  icon: const Icon(Icons.near_me_outlined, size: 18, color: AppColors.primaryGreen),
                  label: Text('Navigate', style: AppTextStyles.bodyText2.copyWith(color: AppColors.primaryGreen)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement Start action
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Starting task: $taskType')),
                    );
                  },
                  icon: const Icon(Icons.play_arrow, size: 18, color: AppColors.textWhite),
                  label: Text('Start', style: AppTextStyles.buttonText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}