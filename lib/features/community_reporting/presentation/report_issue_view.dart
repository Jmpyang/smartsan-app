import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:smartsan_app/features/community_reporting/domain/services/location_service.dart';
import 'package:smartsan_app/features/community_reporting/presentation/location_picker_screen.dart';
// --- Re-importing necessary project dependencies (assuming these are your actual paths) ---
import 'package:smartsan_app/services/firestore_service.dart'; // Contains ReportService
import 'package:smartsan_app/features/auth/data/providers/auth_provider.dart'; // The correct AuthProvider
import 'package:smartsan_app/app.dart'; // The file containing DashBoard
// ----------------------------------------------------------------------------------------


// NOTE: The main() function requires the actual AuthProvider to be defined or imported.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  runApp(
    // FIX: Use the imported AuthProvider
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const CommunityApp(),
    ),
  );
}

class CommunityApp extends StatelessWidget {
  const CommunityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Clean',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      // Assuming MainHomePage is your primary navigation structure
      home: const MainHomePage(), 
    );
  }
}

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'Impact',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Achievements',
          ),
        ],
      ),
    );
  }

  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return const ReportIssuePage();
      case 1:
        return const ImpactPage();
      case 2:
        return const AchievementsPage();
      default:
        return const ReportIssuePage();
    }
  }
}

class ReportIssuePage extends StatefulWidget {
  const ReportIssuePage({super.key});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  // Use the ReportService imported from firestore_service.dart
  final ReportService _reportService = ReportService();
  final LocationService _locationService = LocationService();

  // Re-added for map initialization consistency
  final double defaultLat = 34.0522;
  final double defaultLng = -118.2437;


  final _formKey = GlobalKey<FormState>();
  
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = []; // Still track images in UI, but don't upload
  bool _isLoading = false;
  bool _isLocationLoading = false;
  Position? _currentPosition;

  String? _selectedCategory;
  String? _selectedPriority;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final Map<String, String> _categories = {
    'Overflowing': 'Overflowing bins or containers',
    'Illegal Littering': 'Illegal dumping or littering',
    'Damaged Infrastructure': 'Damaged public infrastructure',
    'Blocked Drainage': 'Blocked drains or waterways',
    'Other': 'Other issues',
  };

  final List<String> _prioritiesList = [
    "Low - Can wait",
    "Medium - Address soon",
    "High - Urgent"
  ];

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImages
            ..clear()
            ..add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

// This function was defined inside _fetchLocation(), causing error 3. Moved to class scope.
Future<void> _navigateToLocationPicker() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => LocationPickerScreen(
        // Pass current coordinates to initialize the map if already fetched
        initialLat: _currentPosition?.latitude ?? defaultLat, // Using defaultLat
        initialLng: _currentPosition?.longitude ?? defaultLng, // Using defaultLng
      ),
    ),
  );

  if (result != null && result is PickedLocation) {
    // Successfully received the picked location
    setState(() {
      _currentPosition = Position(
        latitude: result.latitude,
        longitude: result.longitude,
        timestamp: DateTime.now(),
        accuracy: 0.0, // Default accuracy as it's user-picked
        altitude: 0.0, 
        heading: 0.0, 
        speed: 0.0, 
        speedAccuracy: 0.0, 
        headingAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        // The Position constructor requires both altitudeAccuracy and floor.
        floor: 0, 
        isMocked: false
      );
      _locationController.text = 
        'GPS: Lat ${result.latitude.toStringAsFixed(4)}, Lng ${result.longitude.toStringAsFixed(4)}';
    });
  }
}

  Future<void> _fetchLocation() async {
    if (_isLocationLoading) return;

    setState(() {
      _isLocationLoading = true;
      _locationController.text = 'Fetching GPS coordinates...';
      _currentPosition = null; // Clear previous position
    });

    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _currentPosition = position;
        _locationController.text = 
            'GPS: Lat ${position.latitude.toStringAsFixed(4)}, Lng ${position.longitude.toStringAsFixed(4)}';
      });
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location Error: ${e.toString()}')),
        );
      }
      setState(() {
        _locationController.clear();
        _currentPosition = null;
      });
    } finally {
      if (mounted) setState(() => _isLocationLoading = false);
    }
  }

  void _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields marked with *.')),
      );
      return;
    }

     if (_currentPosition == null && _locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fetch GPS location or manually enter the location.')),
      );
      return;
    }
    
    // Use Provider.of to access the AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reporterUid = authProvider.currentUser?.uid ?? 'anonymous';

    if (reporterUid == 'anonymous') {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User authentication failed. Cannot submit report.')),
      );
      return;
    }
    
    setState(() => _isLoading = true);

    try {
      // Image upload steps removed. Use a placeholder for the imageUrl field.
      const String placeholderImageUrl = ''; 

      // Extract the simple priority string (e.g., "High" from "High - Urgent")
      final priority = _selectedPriority!.split(' - ').first;

      
      // 1. Prepare Location Data
      double lat = _currentPosition?.latitude ?? 0.0;
      double lng = _currentPosition?.longitude ?? 0.0;
      String locationString = _locationController.text.trim();

      // Placeholder coordinates for demonstration (can be replaced by actual GPS coordinates later)
      // const double placeholderLat = 34.0522;
      // const double placeholderLng = -118.2437; // Removed these constants as they were causing errors 1 & 2

      await _reportService.submitReport(
        description: _descriptionController.text.trim(),
        category: _selectedCategory!,
        priority: priority,
        // Set to empty string to maintain the function signature
        imageUrl: placeholderImageUrl, 
        locationString: _locationController.text.trim(),
        // FIX: Use the calculated local variables 'lat' and 'lng'
        lat: lat,
        lng: lng,
        reporterUid: reporterUid, 
      );

      _showSubmissionSuccessDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSubmissionSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Submitted'),
        content: const Text('Thank you! Your report is being processed.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _selectedCategory = null;
                _selectedPriority = null;
                _locationController.clear();
                _descriptionController.clear();
                _selectedImages.clear(); // Clear local image selection
                _formKey.currentState!.reset();
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            // FIX: Navigate using the imported DashBoard class from app.dart
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DashBoard()));
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Report an Issue'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form( 
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Help keep your community clean and earn rewards',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              const Text(
                'Submit a Report',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Issue Category (Required Dropdown)
              const Text('Issue Category *', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  hintText: 'Select category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: _categories.entries
                    .map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.key)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
                validator: (value) => value == null ? 'Please select a category' : null, 
              ),
              const SizedBox(height: 20),
              const Text('Location *', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField( 
                      controller: _locationController,
                      readOnly: true, // Make it read-only since it's populated by GPS
                      decoration: InputDecoration(
                        hintText: 'Select location via map',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                      validator: (value) => value!.trim().isEmpty ? 'Location is required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                      height: 56, // Match height of TextFormField
                      child: ElevatedButton.icon(
                        // FIX: _navigateToLocationPicker is now available in the class scope
                        onPressed: _isLoading ? null : _navigateToLocationPicker, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.map),
                        label: const Text('Map'),
                      ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Description (Required TextFormField)
              const Text('Description *', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe the issue in detail...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  alignLabelWithHint: true,
                ),
                validator: (value) => value!.trim().isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 20),

              // Priority Level (Required Dropdown)
              const Text('Priority Level *', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: InputDecoration(
                  hintText: 'Select priority',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: _prioritiesList
                    .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedPriority = value),
                validator: (value) => value == null ? 'Please select a priority level' : null, 
              ),
              const SizedBox(height: 20),

              // Add Photos (Now Optional)
              const Text('Add Photos', style: TextStyle(fontWeight: FontWeight.w600)), // Removed *
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _isLoading ? null : _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[50],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_camera, size: 40, color: Colors.grey[600]), // Changed icon for better clarity
                      const SizedBox(height: 8),
                      const Text('Click to select a photo (Optional)', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      const Text('PNG, JPG (Image will not be saved)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              // REMOVED: Red text validation message for required photo

              if (_selectedImages.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final image = entry.value;
                    return Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: kIsWeb
                                  ? NetworkImage(image.path)
                                  : FileImage(File(image.path)) as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: -8,
                          right: -8,
                          child: IconButton(
                            icon: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                            onPressed: () => _removeImage(index),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : const Text('Submit Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

// ---------------- IMPACT PAGE ----------------
class ImpactPage extends StatelessWidget {
  const ImpactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Impact'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Total Points', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text('245', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Level 3', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('245/300', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 245 / 300,
                      backgroundColor: Colors.grey,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text('55 points to Level 4', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildStatRow('Reports Submitted', '24', Icons.description),
                    const Divider(),
                    _buildStatRow('Issues Resolved', '18', Icons.check_circle),
                    const Divider(),
                    _buildStatRow('Current Streak', '7 days', Icons.local_fire_department),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Recent Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: const [
                  _ActivityItem(title: 'Illegal Littering Report', points: '+10 points', time: '2 hours ago'),
                  _ActivityItem(title: 'Overflowing Bin Resolved', points: '+15 points', time: '1 day ago'),
                  _ActivityItem(title: 'Damaged Infrastructure Report', points: '+10 points', time: '2 days ago'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String points;
  final String time;

  const _ActivityItem({required this.title, required this.points, required this.time});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(Icons.eco, color: Colors.green[700]),
        ),
        title: Text(title),
        subtitle: Text(time),
        trailing: Text(points, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ---------------- ACHIEVEMENTS PAGE ----------------
class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Achievements'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Achievements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: const [
                  AchievementCard(title: 'First Report', description: 'Submit your first report', points: 10),
                  AchievementCard(title: 'Eco Hero', description: 'Resolve 10 issues', points: 50),
                  AchievementCard(title: 'Community Leader', description: 'Reach Level 5', points: 100),
                  AchievementCard(title: 'Clean Streak', description: '7 days of consecutive reports', points: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AchievementCard extends StatelessWidget {
  final String title;
  final String description;
  final int points;

  const AchievementCard({required this.title, required this.description, required this.points});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('+${points} pts', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:smartsan_app/app.dart';
// import 'package:smartsan_app/main.dart';
// import 'dart:io';
// // import 'package:smartsan_app/services/report_service.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/foundation.dart'; // For kIsWeb check and platform-specific file handling
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';
// import 'package:provider/provider.dart';
// import 'package:smartsan_app/features/auth/data/providers/auth_provider.dart';
// import 'package:smartsan_app/services/firestore_service.dart'; // For IssueReport class
// import 'package:smartsan_app/features/auth/domain/services/auth_service.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();

//   await FirebaseAppCheck.instance.activate(
//     androidProvider: AndroidProvider.debug,
//     appleProvider: AppleProvider.debug,
//   );

//   runApp(const CommunityApp());
// }

// class CommunityApp extends StatelessWidget {
//   const CommunityApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Community Clean',
//       theme: ThemeData(
//         primarySwatch: Colors.green,
//         useMaterial3: true,
//       ),
//       home: const MainHomePage(),
//     );
//   }
// }

// class MainHomePage extends StatefulWidget {
//   const MainHomePage({super.key});

//   @override
//   State<MainHomePage> createState() => _MainHomePageState();
// }

// class _MainHomePageState extends State<MainHomePage> {
//   int _currentIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _getCurrentPage(),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() => _currentIndex = index);
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.report),
//             label: 'Report',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.insights),
//             label: 'Impact',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.emoji_events),
//             label: 'Achievements',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _getCurrentPage() {
//     switch (_currentIndex) {
//       case 0:
//         return const ReportIssuePage();
//       case 1:
//         return const ImpactPage();
//       case 2:
//         return const AchievementsPage();
//       default:
//         return const ReportIssuePage();
//     }
//   }
// }

// class ReportIssuePage extends StatefulWidget {
//   const ReportIssuePage({super.key});

//   @override
//   State<ReportIssuePage> createState() => _ReportIssuePageState();
// }

// class _ReportIssuePageState extends State<ReportIssuePage> {
//   final ReportService _reportService = ReportService();

//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _titleController = TextEditingController();
//   double _currentLat = 0.0;
//   double _currentLon = 0.0;

//   final ImagePicker _picker = ImagePicker();
//   List<XFile> _selectedImages = [];
//   bool _isLoading = false;

//   String? _selectedCategory;
//   String? _selectedPriority;
//   final TextEditingController _locationController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();

//   final Map<String, String> _categories = {
//     'Overflowing': 'Overflowing bins or containers',
//     'Illegal Littering': 'Illegal dumping or littering',
//     'Damaged Infrastructure': 'Damaged public infrastructure',
//     'Blocked Drainage': 'Blocked drains or waterways',
//     'Other': 'Other issues',
//   };

//   final List<String> _prioritiesList = [
//     "Low - Can wait",
//     "Medium - Address soon",
//     "High - Urgent"
//   ];

//   Future<String?> _uploadImageToStorage(XFile file) async {
//     try {
//       final storageRef = FirebaseStorage.instance.ref();
//       final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
//       final imageRef = storageRef.child('reports/$fileName');

//       UploadTask uploadTask;
//       if (kIsWeb) {
//         final bytes = await file.readAsBytes();
//         uploadTask = imageRef.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
//       } else {
//         uploadTask = imageRef.putFile(File(file.path));
//       }

//       final snapshot = await uploadTask;
//       return await snapshot.ref.getDownloadURL();
//     } on FirebaseException catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Image upload failed: ${e.message}')),
//         );
//       }
//       return null;
//     }
//   }

//   Future<void> _pickImage() async {
//     try {
//       final XFile? image = await _picker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1920,
//         maxHeight: 1080,
//         imageQuality: 85,
//       );
//       if (image != null) {
//         setState(() {
//           _selectedImages
//             ..clear()
//             ..add(image);
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to pick image: $e')),
//         );
//       }
//     }
//   }

//   void _removeImage(int index) {
//     setState(() => _selectedImages.removeAt(index));
//   }

//   void _submitReport() async {
//     if (_selectedCategory == null || _selectedPriority == null || _selectedImages.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select category, priority, and at least one photo.')),
//       );
//       return;
//     }

//     if (_locationController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill in the location and description.')),
//       );
//       return;
//     }

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     //final authService = Provider.of<AuthService>(context, listen: false);
//     final reporterUid = authProvider.currentUser?.uid ?? 'anonymous';

//     if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
//       // If form state is available and invalid, return (though no fields currently use validators)
//       return;
//     }
    
//     setState(() => _isLoading = true);

//     try {
//       final imageUrl = await _uploadImageToStorage(_selectedImages.first);
//       if (imageUrl == null) return;

//       final priority = _selectedPriority!.split(' - ').first;

//       // Placeholder coordinates for demonstration
//       const double placeholderLat = 34.0522;
//       const double placeholderLng = -118.2437;

//       // --- FIRESTORE SUBMISSION ---
//       await _reportService.submitReport(
//         description: _descriptionController.text.trim(),
//         category: _selectedCategory!,
//         priority: priority,
//         imageUrl: imageUrl,
//         locationString: _locationController.text.trim(),
//         lat: placeholderLat,
//         lng: placeholderLng,
//         reporterUid: reporterUid, // Pass the authenticated user ID
//       );
//       // ----------------------------

//       _showSubmissionSuccessDialog();
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Submission failed: ${e.toString()}')),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   void _showSubmissionSuccessDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Report Submitted'),
//         content: const Text('Thank you! Your report is being processed for AI prioritization.'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               setState(() {
//                 _selectedCategory = null;
//                 _selectedPriority = null;
//                 _locationController.clear();
//                 _descriptionController.clear();
//                 _selectedImages.clear();
//               });
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Navigator.push(context, MaterialPageRoute(builder: (context) => DashBoard()));
//           },
//           icon: const Icon(Icons.arrow_back),
//         ),
//         title: const Text('Report an Issue'),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Help keep your community clean and earn rewards',
//               style: TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Submit a Report',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             const Text('Issue Category', style: TextStyle(fontWeight: FontWeight.w600)),
//             const SizedBox(height: 8),
//             DropdownButtonFormField<String>(
//               value: _selectedCategory,
//               decoration: InputDecoration(
//                 hintText: 'Select category',
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               items: _categories.entries
//                   .map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.key)))
//                   .toList(),
//               onChanged: (value) => setState(() => _selectedCategory = value),
//             ),
//             const SizedBox(height: 20),
//             const Text('Location', style: TextStyle(fontWeight: FontWeight.w600)),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _locationController,
//               decoration: InputDecoration(
//                 hintText: 'Enter or select location',
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 prefixIcon: const Icon(Icons.location_on),
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text('Description', style: TextStyle(fontWeight: FontWeight.w600)),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _descriptionController,
//               maxLines: 4,
//               decoration: InputDecoration(
//                 hintText: 'Describe the issue in detail...',
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 alignLabelWithHint: true,
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text('Priority Level', style: TextStyle(fontWeight: FontWeight.w600)),
//             const SizedBox(height: 8),
//             DropdownButtonFormField<String>(
//               value: _selectedPriority,
//               decoration: InputDecoration(
//                 hintText: 'Select priority',
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               items: _prioritiesList
//                   .map((item) => DropdownMenuItem(value: item, child: Text(item)))
//                   .toList(),
//               onChanged: (value) => setState(() => _selectedPriority = value),
//             ),
//             const SizedBox(height: 20),
//             const Text('Add Photos (Optional)', style: TextStyle(fontWeight: FontWeight.w600)),
//             const SizedBox(height: 8),
//             GestureDetector(
//               onTap: _isLoading ? null : _pickImage,
//               child: Container(
//                 width: double.infinity,
//                 height: 120,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey, width: 2),
//                   borderRadius: BorderRadius.circular(8),
//                   color: Colors.grey[50],
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.cloud_upload, size: 40, color: Colors.grey[600]),
//                     const SizedBox(height: 8),
//                     const Text('Click to upload or drag and drop', style: TextStyle(color: Colors.grey)),
//                     const SizedBox(height: 4),
//                     const Text('PNG, JPG up to 10MB', style: TextStyle(fontSize: 12, color: Colors.grey)),
//                   ],
//                 ),
//               ),
//             ),
//             if (_selectedImages.isNotEmpty) ...[
//               const SizedBox(height: 16),
//               Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: _selectedImages.asMap().entries.map((entry) {
//                   final index = entry.key;
//                   final image = entry.value;
//                   return Stack(
//                     children: [
//                       Container(
//                         width: 80,
//                         height: 80,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           image: DecorationImage(
//                             image: kIsWeb
//                                 ? NetworkImage(image.path)
//                                 : FileImage(File(image.path)) as ImageProvider,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         top: -8,
//                         right: -8,
//                         child: IconButton(
//                           icon: const CircleAvatar(
//                             radius: 12,
//                             backgroundColor: Colors.red,
//                             child: Icon(Icons.close, size: 16, color: Colors.white),
//                           ),
//                           onPressed: () => _removeImage(index),
//                         ),
//                       ),
//                     ],
//                   );
//                 }).toList(),
//               ),
//             ],
//             const SizedBox(height: 32),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _submitReport,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 child: _isLoading
//                     ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
//                       )
//                     : const Text('Submit Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _locationController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }
// }

// // ---------------- IMPACT PAGE ----------------
// class ImpactPage extends StatelessWidget {
//   const ImpactPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Impact'),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Card(
//               elevation: 4,
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     const Text('Total Points', style: TextStyle(fontSize: 16, color: Colors.grey)),
//                     const SizedBox(height: 8),
//                     Text('245', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green)),
//                     const SizedBox(height: 16),
//                     const Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text('Level 3', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//                         Text('245/300', style: TextStyle(color: Colors.grey)),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     LinearProgressIndicator(
//                       value: 245 / 300,
//                       backgroundColor: Colors.grey,
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
//                       minHeight: 8,
//                     ),
//                     const SizedBox(height: 8),
//                     const Align(
//                       alignment: Alignment.centerRight,
//                       child: Text('55 points to Level 4', style: TextStyle(fontSize: 12, color: Colors.grey)),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Card(
//               elevation: 4,
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     _buildStatRow('Reports Submitted', '24', Icons.description),
//                     const Divider(),
//                     _buildStatRow('Issues Resolved', '18', Icons.check_circle),
//                     const Divider(),
//                     _buildStatRow('Current Streak', '7 days', Icons.local_fire_department),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text('Recent Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 12),
//             Expanded(
//               child: ListView(
//                 children: const [
//                   _ActivityItem(title: 'Illegal Littering Report', points: '+10 points', time: '2 hours ago'),
//                   _ActivityItem(title: 'Overflowing Bin Resolved', points: '+15 points', time: '1 day ago'),
//                   _ActivityItem(title: 'Damaged Infrastructure Report', points: '+10 points', time: '2 days ago'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatRow(String title, String value, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.green),
//           const SizedBox(width: 12),
//           Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
//           Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
//         ],
//       ),
//     );
//   }
// }

// class _ActivityItem extends StatelessWidget {
//   final String title;
//   final String points;
//   final String time;

//   const _ActivityItem({required this.title, required this.points, required this.time});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: Colors.green[100],
//           child: Icon(Icons.eco, color: Colors.green[700]),
//         ),
//         title: Text(title),
//         subtitle: Text(time),
//         trailing: Text(points, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
//       ),
//     );
//   }
// }

// // ---------------- ACHIEVEMENTS PAGE ----------------
// class AchievementsPage extends StatelessWidget {
//   const AchievementsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Recent Achievements'),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Your Achievements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 16),
//             Expanded(
//               child: GridView.count(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 children: const [
//                   AchievementCard(title: 'First Report', description: 'Submit your first report', points: 10),
//                   AchievementCard(title: 'Eco Hero', description: 'Resolve 10 issues', points: 50),
//                   AchievementCard(title: 'Community Leader', description: 'Reach Level 5', points: 100),
//                   AchievementCard(title: 'Clean Streak', description: '7 days of consecutive reports', points: 20),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AchievementCard extends StatelessWidget {
//   final String title;
//   final String description;
//   final int points;

//   const AchievementCard({required this.title, required this.description, required this.points});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//             const SizedBox(height: 8),
//             Text(description, style: const TextStyle(fontSize: 14, color: Colors.grey)),
//             const Spacer(),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Text('+${points} pts', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
