import 'package:flutter/material.dart';

class WorkersDashboardScreen extends StatelessWidget {
  const WorkersDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Dashboard'),
        backgroundColor: Colors.green,
      ),
      // --- Simplified Body for Workers Dashboard ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Worker Dashboard',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Manage and track your daily tasks.'),
            const SizedBox(height: 24),

            // Example Task List
            _buildTaskCard('Waste Collection', 'Pending', '0.5 km'),
            _buildTaskCard('Bin Maintenance', 'Active', '1.2 km'),
            _buildTaskCard('Emergency Cleanup', 'Alert', '2.1 km'),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.warning),
              label: const Text('Emergency Support'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(String taskType, String status, String distance) {
    Color statusColor = status == 'Pending' ? Colors.orange : status == 'Active' ? Colors.green : Colors.red;
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: Icon(Icons.assignment, color: statusColor),
        title: Text(taskType),
        subtitle: Text('Status: $status | Distance: $distance'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Implement task details navigation
        },
      ),
    );
  }
}


/*import 'package:flutter/material.dart';
import 'package:smartsan_app/core/constants/app_colors.dart';
import 'package:smartsan_app/core/constants/app_text_styles.dart';
import 'package:smartsan_app/features/workers/presentation/widgets/task_card.dart';

class WorkersDashboardScreen extends StatelessWidget {
  const WorkersDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Worker Dashboard', style: AppTextStyles.headline2),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: AppColors.textDark)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, color: AppColors.textDark)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manage and track your daily tasks', style: AppTextStyles.bodyText1.copyWith(color: AppColors.textLight)),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Active Tasks
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: AppColors.textDark),
                          const SizedBox(width: 8),
                          Text('Active Tasks', style: AppTextStyles.subhead1),
                          const Spacer(),
                          Text('3 pending', style: AppTextStyles.bodyText2.copyWith(color: AppColors.textLight)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const TaskCard(
                        taskType: 'Waste Collection',
                        status: 'Pending',
                        statusColor: AppColors.warningOrange,
                        statusTextStyle: AppTextStyles.statusPending,
                        location: 'Main Street & 5th Ave',
                        distanceTime: '0.5 km  ~10 min',
                      ),
                      const TaskCard(
                        taskType: 'Bin Maintenance',
                        status: 'Active',
                        statusColor: AppColors.primaryGreen,
                        statusTextStyle: AppTextStyles.statusActive,
                        location: 'Park Avenue',
                        distanceTime: '1.2 km  ~15 min',
                      ),
                      const TaskCard(
                        taskType: 'Emergency Cleanup',
                        status: 'Alert',
                        statusColor: AppColors.alertRed,
                        statusTextStyle: AppTextStyles.statusAlert,
                        location: 'Central Market',
                        distanceTime: '2.1 km  ~20 min',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Right Column: Performance and Completed
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Today\'s Performance', style: AppTextStyles.subhead1),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text('3', style: AppTextStyles.headline1.copyWith(color: AppColors.primaryGreen)),
                              Text('Tasks Completed!', style: AppTextStyles.bodyText2.copyWith(color: AppColors.textLight)),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Efficiency', style: AppTextStyles.bodyText2),
                                  Text('96%', style: AppTextStyles.smallGreen),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: 0.96,
                                backgroundColor: AppColors.lightGreen,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text('8.2km', style: AppTextStyles.subhead1),
                                      Text('Distance', style: AppTextStyles.bodyText2.copyWith(color: AppColors.textLight)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text('4.5h', style: AppTextStyles.subhead1),
                                      Text('Active Time', style: AppTextStyles.bodyText2.copyWith(color: AppColors.textLight)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Completed Today', style: AppTextStyles.subhead1),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildCompletedTaskItem('Beach Road', 'Waste Collection', '2 hours ago'),
                              const Divider(),
                              _buildCompletedTaskItem('School District', 'Street Cleaning', '3 hours ago'),
                              const Divider(),
                              _buildCompletedTaskItem('Market Square', 'Bin Replacement', '4 hours ago'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement Emergency Support
                             ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Contacting Emergency Support')),
                            );
                          },
                          icon: const Icon(Icons.warning, color: AppColors.textWhite),
                          label: Text('Emergency Support', style: AppTextStyles.buttonText),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.alertRed,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedTaskItem(String location, String taskType, String timeAgo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 20, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(location, style: AppTextStyles.bodyText1),
              Text(taskType, style: AppTextStyles.bodyText2),
            ],
          ),
          const Spacer(),
          Text(timeAgo, style: AppTextStyles.bodyText2.copyWith(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
*/