import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartsan_app/features/auth/domain/services/auth_service.dart';
import 'package:smartsan_app/features/auth/data/models/user_model.dart';
import 'package:smartsan_app/features/auth/presentation/login_view.dart';
import 'package:smartsan_app/features/auth/data/providers/auth_provider.dart';
import 'package:smartsan_app/app.dart';

class SignupPage extends StatefulWidget { // CHANGED to StatefulWidget
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController(); // ADDED: Name controller
  final TextEditingController _emailController = TextEditingController(); // ADDED: Email controller
  final TextEditingController _passwordController = TextEditingController(); // ADDED: Password controller
  final TextEditingController _confirmPasswordController = TextEditingController(); // ADDED: Confirm password controller
  bool _isLoading = false; // ADDED: Loading state

  Future<void> _signUpWithEmail() async {
    // ADDED: Form validation
    if (_nameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passwordController.text.isEmpty) {
      _showErrorDialog("Please fill in all required fields");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog("Passwords do not match");
      return;
    }

    if (_passwordController.text.length < 6) {
      _showErrorDialog("Password should be at least 6 characters");
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      //final authService = Provider.of<AuthService>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Step 1: Create user in Firebase Authentication
      final userCredential = await authProvider.signUp(
        _emailController.text, 
        _passwordController.text
      );
      
      final user = userCredential.user;
      if (user != null) {
        // Step 2: Create user record in Realtime Database
        final userModel = UserModel(
          uid: user.uid,
          email: _emailController.text,
          name: _nameController.text,
          role: 'Community', // DEFAULT role for new users
        );
        
        await authProvider.createUserRecord(userModel);
        
        // Step 3: Show success and navigate (navigation handled by AuthWrapper)
        _showSuccessDialog();
      }
    } catch (e) {
      String errorMessage = "Sign up failed. Please try again.";
      if (e.toString().contains('email-already-in-use')) {
        errorMessage = "The email address is already in use by another account.";
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = "The email address format is invalid.";
      } 
      _showErrorDialog(errorMessage);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Up Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Account created successfully!'),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const DashBoard()),
                (Route<dynamic> route) => false, // This condition ensures all previous routes are removed
          );
            },
            child: const Text('Continue to App'),
          ),
        ],
      ),
    );
  }
 
@override
  Widget build(BuildContext context) {
    // Get the current screen height to ensure the SingleChildScrollView's content
    // takes up at least the full screen height when the keyboard is down.
    final double screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      // 1. GestureDetector to dismiss keyboard on tap outside any TextField
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          width: double.infinity,
          height: screenHeight, // Use exact screen height
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF62B570), Color(0xFF62B570)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          // 2. SingleChildScrollView enables scrolling when keyboard is active
          child: SingleChildScrollView(
            // ConstrainedBox and IntrinsicHeight ensure the content takes full
            // available height, allowing MainAxisAlignment.center to work
            // even when the content is smaller than the screen.
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Join our our smart sanitation community',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Name TextField
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
                            hintText: 'Full Name',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Email TextField
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
                            hintText: 'Email',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Password TextField
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                            hintText: 'Password',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Confirm Password TextField
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                            hintText: 'Confirm Password',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signUpWithEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.black)
                              : const Text(
                                  'Sign Up',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildSignupButton(
                        context,
                        'Sign up with Google',
                        Icons.g_mobiledata,
                        Colors.red,
                        onPressed: _isLoading ? null : () {
                          // TODO: Implement Google Sign Up
                          _showErrorDialog("Google Sign Up not implemented yet");
                        },
                      ),
                      
                      // Spacer pushes the remaining content to the bottom
                      const Spacer(),
                      
                      const SizedBox(height: 30),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: _isLoading ? null : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginPage()),
                              );
                            },
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: _isLoading ? Colors.white54 : Colors.white,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16), // Extra space at the bottom
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Container(
  //       width: double.infinity,
  //       height: double.infinity,
  //       decoration: const BoxDecoration(
  //         gradient: LinearGradient(
  //           colors: [Color(0xFF62B570), Color(0xFF62B570)],
  //           begin: Alignment.topCenter,
  //           end: Alignment.bottomCenter,
  //         ),
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.all(24.0),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             const Text(
  //               'Create Account',
  //               style: TextStyle(
  //                 fontSize: 28,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.white,
  //               ),
  //             ),
  //             const SizedBox(height: 8),
  //             const Text(
  //               'Join our our smart sanitation community',
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 color: Colors.white70,
  //               ),
  //             ),
  //             const SizedBox(height: 40),
              
  //             // Name TextField - UPDATED: Added controller
  //             Container(
  //               decoration: BoxDecoration(
  //                 color: Colors.white.withOpacity(0.9),
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: TextField(
  //                 controller: _nameController, // ADDED: Controller
  //                 decoration: InputDecoration(
  //                   prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
  //                   hintText: 'Full Name',
  //                   border: InputBorder.none,
  //                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 16),
              
  //             // Email TextField - UPDATED: Added controller
  //             Container(
  //               decoration: BoxDecoration(
  //                 color: Colors.white.withOpacity(0.9),
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: TextField(
  //                 controller: _emailController, // ADDED: Controller
  //                 decoration: InputDecoration(
  //                   prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
  //                   hintText: 'Email',
  //                   border: InputBorder.none,
  //                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 16),
              
  //             // Password TextField - UPDATED: Added controller
  //             Container(
  //               decoration: BoxDecoration(
  //                 color: Colors.white.withOpacity(0.9),
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: TextField(
  //                 controller: _passwordController, // ADDED: Controller
  //                 obscureText: true,
  //                 decoration: InputDecoration(
  //                   prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
  //                   hintText: 'Password',
  //                   border: InputBorder.none,
  //                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 16),
              
  //             // Confirm Password TextField - UPDATED: Added controller
  //             Container(
  //               decoration: BoxDecoration(
  //                 color: Colors.white.withOpacity(0.9),
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: TextField(
  //                 controller: _confirmPasswordController, // ADDED: Controller
  //                 obscureText: true,
  //                 decoration: InputDecoration(
  //                   prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
  //                   hintText: 'Confirm Password',
  //                   border: InputBorder.none,
  //                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 24),
              
  //             // Sign Up Button - UPDATED: Connected to signup function
  //             SizedBox(
  //               width: double.infinity,
  //               height: 56,
  //               child: ElevatedButton(
  //                 onPressed: _isLoading ? null : _signUpWithEmail, // ADDED: Signup function
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors.white,
  //                   foregroundColor: Colors.black,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(12),
  //                   ),
  //                 ),
  //                 child: _isLoading
  //                     ? const CircularProgressIndicator(color: Colors.black) // ADDED: Loading indicator
  //                     : const Text(
  //                         'Sign Up',
  //                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //                       ),
  //               ),
  //             ),
  //             const SizedBox(height: 16),
              
  //             _buildSignupButton(
  //               context,
  //               'Sign up with Google',
  //               Icons.g_mobiledata,
  //               Colors.red,
  //               onPressed: _isLoading ? null : () {
  //                 // TODO: Implement Google Sign Up
  //                 _showErrorDialog("Google Sign Up not implemented yet");
  //               },
  //             ),
  //             const SizedBox(height: 30),
              
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 const Text(
  //                   "Already have an account? ",
  //                   style: TextStyle(color: Colors.white),
  //                 ),
  //                 GestureDetector(
  //                   onTap: _isLoading ? null : () {
  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(builder: (context) => const LoginPage()),
  //                     );
  //                   },
  //                   child: Text(
  //                     'Login',
  //                     style: TextStyle(
  //                       color: _isLoading ? Colors.white54 : Colors.white,
  //                       fontWeight: FontWeight.bold,
  //                       decoration: TextDecoration.underline,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSignupButton(
      BuildContext context, String text, IconData icon, Color color,
      {VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.9),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}