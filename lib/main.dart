import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartsan_app/app.dart';
import 'package:smartsan_app/features/community_reporting/presentation/report_issue_view.dart';
import 'firebase_options.dart';
import 'package:smartsan_app/features/auth/presentation/login_view.dart';
import 'package:smartsan_app/features/auth/presentation/signup_view.dart';
import 'package:smartsan_app/features/auth/data/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:smartsan_app/services/firestore_service.dart'; // For IssueReport class
import 'package:smartsan_app/services/report_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      // 1. Instantiate your AuthProvider
      create: (context) => AuthProvider(), 
      // 2. Wrap your entire application
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart san',
      //create: (context) => AuthProvider(),
      home: const HomePage(),
    );
  }
}



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF62B570),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            Container(
              color: const Color(0xFF62B570),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    color: const Color(0xFF62B570),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "Sustainable Sanitization Management",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Building \nCleaner \nCommunities \nTogether",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Empowering communities, workers, and administrators with intelligent sanitation management. Real-time monitoring, AI-driven insights, and collaborative problem-solving.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                        },
                        label: const Text("View Dashboard"),
                        icon: const Icon(Icons.arrow_forward),
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF338E46)
                        ),
                      ),
                      ElevatedButton(onPressed: () {
                         Navigator.push(context, MaterialPageRoute(
                             builder: (context) => LoginPage()));
                      },
                        child: Text("Report an Issue"),
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF2279CF)
                        ),
                      )

                    ],
                  ),
                ],
              ),
            ),


            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard("50K+", "Active Users"),
                      _buildStatCard("125K+", "Issues Resolved"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard("18.5%", "Waste Reduced"),
                      _buildStatCard("200+", "Communities"),
                    ],
                  ),
                ],
              ),
            ),


      Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Ready to Transform Your Community?",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              "Join thousands of communities already making a difference with SmartSan",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            ElevatedButton.icon(onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
              label: Text("Get Started Now"),
              icon: Icon(Icons.arrow_forward),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2279CF),
                  foregroundColor: Colors.white
              ),
            )
          ],
        ),
      ),
            //const Spacer(),

            _buildCopyrightBar(),

          ],
        ),
      ),
    );
  }



            // Container(
            //   padding: const EdgeInsets.all(16.0),
            //   child: Card(
            //     child: Padding(
            //       padding: const EdgeInsets.all(16.0),
            //       child: Column(
            //         children: [
            //           Icon(Icons.phone_android, size: 50, color: Colors.blue),
            //           const SizedBox(height: 8),
            //           const Text(
            //             "Mobile-First Access",
            //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //           ),
            //           const SizedBox(height: 8),
            //           const Text("Access the platform from anywhere"),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            //
            // Container(
            //   padding: const EdgeInsets.all(16.0),
            //   child: Card(
            //     child: Padding(
            //       padding: const EdgeInsets.all(16.0),
            //       child: Column(
            //         children: [
            //           Icon(Icons.work, size: 50, color: Colors.blue),
            //           const SizedBox(height: 8),
            //           const Text(
            //             "Community Powered",
            //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //           ),
            //           const SizedBox(height: 8),
            //           const Text("Gamified reporting system that rewards active community participation"),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            //
            // Container(
            //   padding: const EdgeInsets.all(16.0),
            //   child: Card(
            //     child: Padding(
            //       padding: const EdgeInsets.all(16.0),
            //       child: Column(
            //         children: [
            //           Icon(Icons.analytics, size: 50, color: Colors.blue),
            //           const SizedBox(height: 8),
            //           const Text(
            //             "Real-Time Analytics",
            //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //           ),
            //           const SizedBox(height: 8),
            //           const Text("AI-powered insights and predictive maintenance for optimal efficiency"),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            //
            // Container(
            //   padding: const EdgeInsets.all(16.0),
            //   child: Card(
            //     child: Padding(
            //       padding: const EdgeInsets.all(16.0),
            //       child: Column(
            //         children: [
            //           Icon(Icons.spher, size: 50, color: Colors.blue),
            //           const SizedBox(height: 8),
            //           const Text(
            //             "Multilingual Support",
            //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //           ),
            //           const SizedBox(height: 8),
            //           const Text("Access the platform from anywhere"),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),


  Widget _buildStatCard(String value, String label) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCheck(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCopyrightBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.eco, color: Color(0xFF62B570)),
              const SizedBox(width: 4),
              const Text(
                "SmartSan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const Text(
            "© 2025 SmartSan. Building \n sustainable communities worldwide.",
            style: TextStyle(fontSize: 10, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }
}