import 'package:flutter/material.dart';

// --- Placeholder Colors & Styles for Clean Code ---
// In a real app, these would come from lib/core/constants/
const Color _primaryGreen = Color(0xFF4CAF50);
const Color _primaryBlue = Color(0xFF2196F3);
const Color _warningOrange = Color(0xFFFF9800);
const Color _backgroundColor = Color(0xFFF9F9F9);
const Color _textDark = Color(0xFF333333);
const Color _textLight = Color(0xFF666666);
const Color _alertRed = Color(0xFFF44336);

const TextStyle _headline2 = TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textDark);
const TextStyle _subhead1 = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textDark);
const TextStyle _bodyText1 = TextStyle(fontSize: 14, color: _textDark);
const TextStyle _bodyText2 = TextStyle(fontSize: 12, color: _textLight);
const TextStyle _smallGreen = TextStyle(fontSize: 10, color: _primaryGreen, fontWeight: FontWeight.w500);


class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Analytics & Insights', style: _headline2),
        backgroundColor: _backgroundColor,
        elevation: 0,
        foregroundColor: _textDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Track performance and environmental impact', style: _bodyText1.copyWith(color: _textLight)),
            const SizedBox(height: 24),

            // 1. Key Performance Indicators (KPIs)
            _buildKeyMetricsGrid(context),
            const SizedBox(height: 24),

            // 2. Monthly Performance Trends
            Text('Monthly Performance Trends', style: _subhead1),
            const SizedBox(height: 16),
            _buildMonthlyTrendsCard(),
            const SizedBox(height: 24),

            // 3. Environmental Impact
            Text('Environmental Impact', style: _subhead1),
            const SizedBox(height: 16),
            _buildEnvironmentalImpactCard(),
            const SizedBox(height: 24),

            // 4. Quarterly Comparison
            Text('Quarterly Comparison', style: _subhead1),
            const SizedBox(height: 16),
            _buildQuarterlyComparisonCard(),
          ],
        ),
      ),
    );
  }
  
 //Key metrics grid

  Widget _buildKeyMetricsGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final int axisCount = (screenWidth > 600) ? 4 : 2;
    return GridView.count(
      crossAxisCount: axisCount, // 4 columns as seen in the wide web view (analytics.png)
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: (axisCount == 4) ? 1.5 : 1.2,
      //childAspectRatio: aspectRatio,  // Now dynamic
      children: [
        _MetricCard(
          title: 'Waste Reduction',
          value: '18.5%',
          subText: '+5.2% vs last quarter',
          icon: Icons.eco_outlined,
          changeColor: _primaryGreen,
        ),
        _MetricCard(
          title: 'Response Time',
          value: '16 min',
          subText: '+1.2% vs last month',
          icon: Icons.timer_outlined,
          changeColor: _primaryBlue,
        ),
        _MetricCard(
          title: 'Community Reports',
          value: '1,245',
          subText: '+28% vs last month',
          icon: Icons.people_outline,
          changeColor: _warningOrange,
        ),
        _MetricCard(
          title: 'Goal Achievement',
          value: '94%',
          subText: '+6% vs last month',
          icon: Icons.track_changes_outlined,
          changeColor: _primaryGreen,
        ),
      ],
    );
  }
  
//Monthly trends card

  Widget _buildMonthlyTrendsCard() {
    return Card(
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
    );
  }

  Widget _buildMonthlyTrend(String month, double wasteValue, double efficiencyValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(month, style: _bodyText1),
          ),
          const SizedBox(width: 16),
          // Waste Trend (Blue Bar)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Waste: ${(wasteValue * 100).toInt()}T', style: _bodyText2),
                LinearProgressIndicator(
                  value: wasteValue,
                  backgroundColor: _primaryBlue.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(_primaryBlue),
                  minHeight: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Efficiency Trend (Green Bar)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Efficiency: ${(efficiencyValue * 100).toInt()}%', style: _bodyText2),
                LinearProgressIndicator(
                  value: efficiencyValue,
                  backgroundColor: _primaryGreen.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(_primaryGreen),
                  minHeight: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
 //Environmental impact card

  Widget _buildEnvironmentalImpactCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildEnvironmentalImpactItem('CO₂ Reduced', '142T', 0.75, '75% of annual target'),
            const Divider(),
            _buildEnvironmentalImpactItem('Recycling Rate', '68%', 0.68, 'Up 12% from last year', valueColor: _primaryBlue),
            const Divider(),
            _buildEnvironmentalImpactItem('Water Saved', '24,500L', 0.60, 'Through efficient operations'),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentalImpactItem(String title, String value, double progress, String subText, {Color valueColor = _primaryGreen}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: _bodyText1),
              Text(value, style: _subhead1.copyWith(color: valueColor)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(valueColor),
            minHeight: 10,
          ),
          const SizedBox(height: 4),
          Text(subText, style: _bodyText2.copyWith(color: _textLight)),
        ],
      ),
    );
  }
 
  Widget _buildQuarterlyComparisonCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuarterlyComparison('Q1 2024', '267T', '-1.8% vs Q4 2023', changeIsNegative: true),
            _buildQuarterlyComparison('Q2 2024', '233T', '+1.3% improvement'),
            _buildQuarterlyComparison('Projected Q3 2024', '210T', '+10% target', highlight: true),
          ],
        ),
      ),
    );
  }

  Widget _buildQuarterlyComparison(String quarter, String value, String? change, {bool highlight = false, bool changeIsNegative = false}) {
    Color changeColor = changeIsNegative ? _alertRed : _primaryGreen;

    return Expanded(
      child: Container(
        padding: highlight ? const EdgeInsets.all(16) : null,
        decoration: highlight ? BoxDecoration(
          color: _primaryGreen.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ) : null,
        child: Column(
          children: [
            Text(
              quarter, 
              style: _bodyText2.copyWith(color: highlight ? Colors.white70 : _textLight)
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: _headline2.copyWith(
                color: highlight ? Colors.white : _textDark,
              ),
            ),
            if (change != null)
              Text(
                change,
                style: _smallGreen.copyWith(
                  color: highlight ? Colors.white : changeColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}


// A reusable widget for the Key Metric Cards (KPIs)
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subText;
  final IconData icon;
  final Color changeColor;

  const _MetricCard({
    required this.title,
    required this.value,
    this.subText,
    required this.icon,
    required this.changeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(title, style: _bodyText1),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: changeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: changeColor, size: 20),
                ),
              ],
            ),
            Text(value, style: _headline2.copyWith(fontSize: 28, color: _textDark)),
            if (subText != null)
              Text(
                subText!,
                style: _smallGreen.copyWith(
                  color: subText!.contains('-') ? _alertRed : changeColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}