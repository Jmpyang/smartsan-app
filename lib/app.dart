import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartsan_app/features/community_reporting/presentation/report_issue_view.dart';
import 'package:smartsan_app/main.dart';
import 'package:provider/provider.dart';
import 'package:smartsan_app/features/auth/data/providers/auth_provider.dart';
import 'package:smartsan_app/features/workers/presentation/screens/workers_dashboard_screen.dart';
import 'package:smartsan_app/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:smartsan_app/features/auth/domain/services/auth_service.dart';

void main(){
  runApp(const DashBoard());
}


class DashBoard extends StatelessWidget {
  const DashBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Dashboard",
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        cardColor: const Color(0xFF1A1A1A),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF111111),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D0D0D),
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<StatefulWidget> createState() => _DashBoardPage();
}

class _DashBoardPage extends State<DashboardPage> {
  bool _isRefreshing = false;

  Future<void> _refreshDashboard() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 1)); // simulate refresh
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      endDrawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              trailing: const Icon(Icons.home, color: Colors.white),
              title: const Text("Home", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const HomePage()),
                // );
              },
            ),
            ListTile(
              trailing: const Icon(Icons.dashboard, color: Colors.white),
              title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                MaterialPageRoute(builder: (context) => const DashBoard());
              },
            ),
            ListTile(trailing: Icon(Icons.location_city),
              title: Text("Report Issue"),
              onTap: (){
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CommunityApp()));
              },
            ),
            ListTile(
              trailing: const Icon(Icons.work, color: Colors.white),
              title: const Text("Workers", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WorkersDashboardScreen()),
                );
              },
            ),
            ListTile(
              trailing: const Icon(Icons.analytics, color: Colors.white),
              title: const Text("Analytics", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AnalyticsScreen()),
                );
              },
            ),
            ListTile(
              trailing: const Icon(Icons.logout, color: Colors.white),
              title: const Text("Logout", style: TextStyle(color: Colors.white)),
              onTap: () async {
    
            Navigator.pop(context);

            bool confirm = await showLogoutConfirmationDialog(context);
            final authProvider = Provider.of<AuthProvider>(context, listen: false);

            if (confirm) {
            await authProvider.logout();
            Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HomePage()),
                );
                }
  },
),

          ],
        ),
      ),
      body:
          RefreshIndicator(onRefresh: _refreshDashboard, child:
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D0D0D),
                  Color(0xFF1A1A1A),
                  Color(0xFF121212),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: const [
                        Text(
                          "Dashboard",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 25, color: Colors.white),
                        ),
                        Text(
                          "Monitor sanitization operations in real time",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  _statCard("Active Workers", "142", "On duty today",
                      "+12% vs last month", Icons.people, Colors.green),
                  _statCard("Waste Collected", "24.5T", "This week",
                      "+8% vs last month", Icons.delete, Colors.green),
                  _statCard("Service Efficiency", "94%", "Target 90%",
                      "+3% vs last month", Icons.analytics, Colors.green),
                  _statCard("Service Efficiency", "94%", "Target 90%",
                      "-5% vs last month", Icons.location_on, Colors.red),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.location_on, size: 20, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              "Recent Community reports",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        _reportCard("Main Street & 5th Ave", "15 min ago", "Pending"),
                        _reportCard("Park Avenue", "1 hour ago", "Active"),
                        _reportCard("Beach road", "3 hour ago", "Completed"),
                        _reportCard("Central market", "30 min ago", "Alert"),
                      ],
                    ),
                  ),

                  // 🔹 New "Today's Summary" Container
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: const Color(0xFF1A1A1A),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Today's Summary",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            _summaryItem(Icons.check_circle, Colors.green, "Completed", "47"),
                            _summaryItem(Icons.access_time, Colors.orange, "In Progress", "23"),
                            _summaryItem(Icons.warning_amber_rounded, Colors.red, "Alerts", "3"),
                            const Divider(color: Colors.white24, height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("Avg Response Time",
                                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                                Text("18 min",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: const LinearProgressIndicator(
                                value: 0.8,
                                minHeight: 8,
                                color: Colors.green,
                                backgroundColor: Colors.white10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),)

    );
  }
}

Future<bool> showLogoutConfirmationDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    barrierDismissible: false, // User must choose an option
    builder: (context) => AlertDialog(
      title: const Text("Confirm Logout"),
      content: const Text("Are you sure you want to log out?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false), // Cancel
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true), // Confirm
          child: const Text(
            "Logout",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  ) ?? false;
}


Widget _summaryItem(IconData icon, Color color, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

Widget _statCard(String title, String value, String subtitle, String change,
    IconData icon, Color accentColor) {
  return Container(
    padding: const EdgeInsets.all(16.0),
    child: Card(
      color: const Color(0xFF1A1A1A),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                    const TextStyle(color: Colors.white70, fontSize: 14)),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style:
                    const TextStyle(color: Colors.white60, fontSize: 14)),
                Text(change,
                    style: TextStyle(color: accentColor, fontSize: 13)),
              ],
            ),
            Icon(icon, size: 30, color: accentColor),
          ],
        ),
      ),
    ),
  );
}

Widget _reportCard(String location, String time, String status) {
  return Card(
    color: const Color(0xFF1A1A1A),
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.lock_clock,
                        size: 16, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(time, style: const TextStyle(color: Colors.white70)),
                  ],
                )
              ],
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return Colors.green;
    case 'pending':
      return Colors.orange;
    case 'alert':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
