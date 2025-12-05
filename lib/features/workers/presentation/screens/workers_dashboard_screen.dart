import 'package:flutter/material.dart';

// --- Placeholder Colors & Styles for Clean Code ---
const Color _primaryGreen = Color(0xFF4CAF50);
const Color _backgroundColor = Color(0xFFF9F9F9);
const Color _textDark = Color(0xFF333333);
const Color _textLight = Color(0xFF666666);
const Color _alertRed = Color(0xFFF44336);
const Color _warningOrange = Color(0xFFFF9800);

const TextStyle _headline2 = TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textDark);
const TextStyle _subhead1 = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textDark);
const TextStyle _bodyText1 = TextStyle(fontSize: 14, color: _textDark);
const TextStyle _bodyText2 = TextStyle(fontSize: 12, color: _textLight);
const TextStyle _metricValue = TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _textDark);


class WorkersDashboardScreen extends StatelessWidget {
  const WorkersDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We use a LayoutBuilder to check the screen width and decide on the layout (stacking vs side-by-side).
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Worker Dashboard', style: _headline2),
        backgroundColor: _backgroundColor,
        elevation: 0,
        foregroundColor: _textDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Check if the screen is wide (Tablet/Web) or narrow (Mobile)
            bool isWideScreen = constraints.maxWidth > 800;

            if (isWideScreen) {
              // 1. WIDE SCREEN LAYOUT (Side-by-side: Active Tasks | Performance/Summary)
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildActiveTasksCard()),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 350, // Fixed width for the performance/summary pane
                    child: Column(
                      children: [
                        _buildPerformanceSummaryCard(),
                        const SizedBox(height: 16),
                        _buildCompletedTasksCard(context),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              // 2. NARROW SCREEN LAYOUT (Stacked: Active Tasks | Performance | Summary)
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildActiveTasksCard(),
                  const SizedBox(height: 16),
                  _buildPerformanceSummaryCard(),
                  const SizedBox(height: 16),
                  _buildCompletedTasksCard(context),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  // =========================================================================
  // === 1. Active Tasks Card ================================================
  // =========================================================================

  Widget _buildActiveTasksCard() {
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
                const Icon(Icons.access_time, size: 20, color: _textLight),
                const SizedBox(width: 8),
                Text('Active Tasks', style: _subhead1),
                const Spacer(),
                Text('3 pending', style: _bodyText2.copyWith(color: _warningOrange)),
              ],
            ),
            const Divider(),
            _buildTaskItem(
              title: 'Waste Collection',
              location: 'Main Street & 5th Ave',
              distance: '0.5 km',
              time: '10 min',
              status: 'Pending',
              statusColor: _warningOrange,
            ),
            _buildTaskItem(
              title: 'Bin Maintenance',
              location: 'Park Avenue',
              distance: '1.2 km',
              time: '15 min',
              status: 'Active',
              statusColor: _primaryGreen,
            ),
            _buildTaskItem(
              title: 'Emergency Cleanup',
              location: 'Central Market',
              distance: '2.1 km',
              time: '20 min',
              status: 'Alert',
              statusColor: _alertRed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem({
    required String title,
    required String location,
    required String distance,
    required String time,
    required String status,
    required Color statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: _bodyText1.copyWith(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(status, style: _bodyText2.copyWith(color: statusColor)),
              ),
            ],
          ),
          Text(location, style: _bodyText2),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$distance ~ $time', style: _bodyText2.copyWith(color: _textLight)),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.alt_route, size: 16, color: _primaryGreen),
                    label: const Text('Navigate', style: TextStyle(color: _primaryGreen)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      minimumSize: const Size(60, 30),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: const Text('Start', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),
        ],
      ),
    );
  }

  // =========================================================================
  // === 2. Performance Summary Card =========================================
  // =========================================================================

  Widget _buildPerformanceSummaryCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today\'s Performance', style: _subhead1),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text('3', style: _metricValue.copyWith(fontSize: 48, color: _primaryGreen)),
                  Text('Tasks Completed', style: _bodyText1.copyWith(color: _textLight)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Efficiency', style: _bodyText1),
                Text('96%', style: _bodyText1.copyWith(color: _primaryGreen)),
              ],
            ),
            LinearProgressIndicator(
              value: 0.96,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(_primaryGreen),
              minHeight: 8,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricColumn('8.2km', 'Distance'),
                _buildMetricColumn('4.5h', 'Active Time'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String value, String label) {
    return Column(
      children: [
        Text(value, style: _metricValue.copyWith(fontSize: 22)),
        Text(label, style: _bodyText2),
      ],
    );
  }

  // =========================================================================
  // === 3. Completed Tasks & Emergency Button Card ==========================
  // =========================================================================

  Widget _buildCompletedTasksCard(BuildContext context) {
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
                const Icon(Icons.check_circle_outline, size: 20, color: _primaryGreen),
                const SizedBox(width: 8),
                Text('Completed Today', style: _subhead1),
              ],
            ),
            const Divider(),
            _buildCompletedItem('Beach Road', 'Waste Collection', '2 hours ago'),
            _buildCompletedItem('School District', 'Street Cleaning', '3 hours ago'),
            _buildCompletedItem('Market Square', 'Bin Replacement', '4 hours ago'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement Emergency Call/Report Functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Emergency Support activated.')),
                );
              },
              icon: const Icon(Icons.call, color: Colors.white),
              label: const Text('Emergency Support', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _alertRed,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedItem(String location, String task, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(location, style: _bodyText1.copyWith(fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(task, style: _bodyText2.copyWith(color: _textLight)),
              Text(time, style: _bodyText2.copyWith(color: _textLight)),
            ],
          ),
        ],
      ),
    );
  }
}


/*r Dashboard'),
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
*/

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