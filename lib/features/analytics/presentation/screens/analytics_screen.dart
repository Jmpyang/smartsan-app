import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Insights'),
        backgroundColor: Colors.green,
      ),
      // --- Simplified Body for Analytics Screen ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Key Performance Indicators',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Grid of Metrics
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMetricCard('Waste Reduction', '18.5%', Icons.eco),
                _buildMetricCard('Response Time', '16 min', Icons.timer),
                _buildMetricCard('Community Reports', '1,245', Icons.people),
                _buildMetricCard('Goal Achievement', '94%', Icons.track_changes),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              'Monthly Efficiency Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            // Placeholder for Chart/Trend (represented by a simple container)
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text('Placeholder for Performance Chart')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
              ],
            ),
            Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}


/*import 'package:flutter/material.dart';
import 'package:smartsan_app/core/constants/app_colors.dart';
import 'package:smartsan_app/core/constants/app_text_styles.dart';
import 'package:smartsan_app/features/analytics/presentation/widgets/metric_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Analytics & Insights', style: AppTextStyles.headline2),
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
            Text('Track performance and environmental impact', style: AppTextStyles.bodyText1.copyWith(color: AppColors.textLight)),
            const SizedBox(height: 24),
            // Top Row Metrics
            GridView.count(
              crossAxisCount: 4, // Adjust for responsiveness
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: const [
                MetricCard(
                  title: 'Waste Reduction',
                  value: '18.5%',
                  subText: '+5.2% vs last quarter',
                  icon: Icons.eco_outlined,
                  iconColor: AppColors.primaryGreen,
                ),
                MetricCard(
                  title: 'Response Time',
                  value: '16 min',
                  subText: '+1.2% vs last month',
                  icon: Icons.timer_outlined,
                  iconColor: AppColors.primaryBlue,
                ),
                MetricCard(
                  title: 'Community Reports',
                  value: '1,245',
                  subText: '+28% vs last month',
                  icon: Icons.people_outline,
                  iconColor: AppColors.warningOrange,
                ),
                MetricCard(
                  title: 'Goal Achievement',
                  value: '94%',
                  subText: '+6% vs last month',
                  icon: Icons.track_changes_outlined,
                  iconColor: AppColors.secondaryGreen,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Monthly Performance Trends
            Text('Monthly Performance Trends', style: AppTextStyles.subhead1),
            const SizedBox(height: 16),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildMonthlyTrend('Jan', 0.85, 0.88),
                    _buildMonthlyTrend('Feb', 0.92, 0.90),
                    _buildMonthlyTrend('Mar', 0.88, 0.92),
                    _buildMonthlyTrend('Apr', 0.90, 0.94),
                    _buildMonthlyTrend('May', 0.96, 0.96),
                    _buildMonthlyTrend('Jun', 0.94, 0.94),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Environmental Impact
            Text('Environmental Impact', style: AppTextStyles.subhead1),
            const SizedBox(height: 16),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildEnvironmentalImpactItem('CO₂ Reduced', '142T', 0.75, '75% of annual target'),
                    const Divider(),
                    _buildEnvironmentalImpactItem('Recycling Rate', '68%', 0.68, 'Up 12% from last year', valueColor: AppColors.primaryBlue),
                    const Divider(),
                    _buildEnvironmentalImpactItem('Water Saved', '24,500L', 0.60, 'Through efficient operations'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quarterly Comparison
            Text('Quarterly Comparison', style: AppTextStyles.subhead1),
            const SizedBox(height: 16),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuarterlyComparison('Q1 2024', '267T', null),
                    _buildQuarterlyComparison('Q2 2024', '233T', '+1.3% improvement'),
                    _buildQuarterlyComparison('Projected Q3 2024', '210T', '+10% target', highlight: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTrend(String month, double wasteValue, double efficiencyValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(month, style: AppTextStyles.bodyText1),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Waste: ${(wasteValue * 100).toInt()}T', style: AppTextStyles.bodyText2),
                LinearProgressIndicator(
                  value: wasteValue,
                  backgroundColor: AppColors.lightBlue.withOpacity(0.5),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                  minHeight: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Efficiency: ${(efficiencyValue * 100).toInt()}%', style: AppTextStyles.bodyText2),
                LinearProgressIndicator(
                  value: efficiencyValue,
                  backgroundColor: AppColors.lightGreen.withOpacity(0.5),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                  minHeight: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalImpactItem(String title, String value, double progress, String subText, {Color valueColor = AppColors.primaryGreen}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.bodyText1),
              Text(value, style: AppTextStyles.subhead1.copyWith(color: valueColor)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.borderColor,
            valueColor: AlwaysStoppedAnimation<Color>(valueColor),
            minHeight: 10,
          ),
          const SizedBox(height: 4),
          Text(subText, style: AppTextStyles.bodyText2.copyWith(color: AppColors.textLight)),
        ],
      ),
    );
  }

  Widget _buildQuarterlyComparison(String quarter, String value, String? change, {bool highlight = false}) {
    return Expanded(
      child: Column(
        children: [
          Text(quarter, style: AppTextStyles.bodyText2.copyWith(color: AppColors.textLight)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headline2.copyWith(
              color: highlight ? AppColors.primaryGreen : AppColors.textDark,
            ),
          ),
          if (change != null)
            Text(
              change,
              style: AppTextStyles.smallGreen.copyWith(
                color: change.contains('+') ? AppColors.primaryGreen : AppColors.alertRed,
              ),
            ),
        ],
      ),
    );
  }
}
*/