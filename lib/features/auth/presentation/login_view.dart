import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartsan_app/main.dart';
import 'package:smartsan_app/app.dart';
import 'package:smartsan_app/features/auth/domain/services/auth_service.dart';
import 'package:smartsan_app/features/auth/data/models/user_model.dart';
import 'package:smartsan_app/features/auth/presentation/signup_view.dart';
import 'package:smartsan_app/features/auth/data/providers/auth_provider.dart';

class LoginPage extends StatefulWidget { // CHANGED to StatefulWidget to manage form state
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController(); // ADDED: Controller for email
  final TextEditingController _passwordController = TextEditingController(); // ADDED: Controller for password
  bool _isLoading = false; // ADDED: Loading state

  Future<void> _loginWithEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      // ADDED: Basic validation
      _showErrorDialog("Please enter both email and password");
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // ADDED: Get AuthService from provider and call signIn
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(_emailController.text, _passwordController.text);
      // Navigation will be handled by AuthWrapper in main.dart
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => DashBoard()),
        (Route<dynamic> route) => false, // This removes all previous routes
      );
    } catch (e) {
      String errorMessage = "Login failed. Please check your credentials.";
      if (e.toString().contains('user-not-found')) {
        errorMessage = "No user found with that email.";
      } else if (e.toString().contains('wrong-password')) {
        errorMessage = "Wrong password provided for that user.";
      }
      _showErrorDialog(errorMessage);
    } finally {
       if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Error'),
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
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFF62B570), 
      elevation: 0,
      automaticallyImplyLeading: false, 
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (context) => const HomePage()),
                (Route<dynamic> route) => false,
              );
            },
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    ),
    body: LayoutBuilder( // ADDED: For responsive height
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight( // ADDED: For proper content sizing
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF62B570), Color(0xFF62B570)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'SmartSan',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(height: 8),
                      const SizedBox(height: 40),
                      
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
                      const SizedBox(height: 24),
                      
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _loginWithEmail,
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
                                  'Login',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildLoginButton(
                        context,
                        'Login with Google',
                        Icons.g_mobiledata,
                        Colors.red,
                        onPressed: _isLoading ? null : () {
                          _showErrorDialog("Google Sign In not implemented yet");
                        },
                      ),
                      const SizedBox(height: 30),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: _isLoading ? null : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SignupPage()),
                              );
                            },
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                color: _isLoading ? Colors.white54 : Colors.white,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       backgroundColor: const Color(0xFF62B570), 
  //       elevation: 0,
  //       automaticallyImplyLeading: false, 
  //       actions: [
  //         Padding(
  //           padding: const EdgeInsets.only(right: 16.0),
  //           child: IconButton(
  //             onPressed: () {
  //               // Navigating back to HomePage, clearing login view from stack
  //               Navigator.pushAndRemoveUntil(
  //                 context, 
  //                 MaterialPageRoute(builder: (context) => const HomePage()),
  //                 (Route<dynamic> route) => false,
  //               );
  //             },
  //             icon: const Icon(
  //               Icons.close,
  //               color: Colors.white,
  //               size: 24,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
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
  //               'SmartSan',
  //               style: TextStyle(
  //                 fontSize: 28,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.white,
  //               ),
  //             ),
  //             const SizedBox(height: 8),
  //             const SizedBox(height: 8),
  //             const SizedBox(height: 40),
              
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
  //             const SizedBox(height: 24),
              
  //             // Login Button - UPDATED: Connected to login function
  //             SizedBox(
  //               width: double.infinity,
  //               height: 56,
  //               child: ElevatedButton(
  //                 onPressed: _isLoading ? null : _loginWithEmail, // ADDED: Login function
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
  //                         'Login',
  //                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //                       ),
  //               ),
  //             ),
  //             const SizedBox(height: 16),
              
  //             _buildLoginButton(
  //               context,
  //               'Login with Google',
  //               Icons.g_mobiledata,
  //               Colors.red,
  //               onPressed: _isLoading ? null : () {
  //                 // TODO: Implement Google Sign In
  //                 _showErrorDialog("Google Sign In not implemented yet");
  //               },
  //             ),
  //             const SizedBox(height: 30),
              
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 const Text(
  //                   "Don't have an account? ",
  //                   style: TextStyle(color: Colors.white),
  //                 ),
  //                 GestureDetector(
  //                   onTap: _isLoading ? null : () {
  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(builder: (context) => const SignupPage()),
  //                     );
  //                   },
  //                   child: Text(
  //                     'Sign up',
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

  Widget _buildLoginButton(
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



// import 'package:flutter/material.dart';
// import 'package:smartsan_app/main.dart';
// import 'package:smartsan_app/features/auth/domain/services/auth_service.dart';
// import 'package:smartsan_app/features/auth/data/repositories/user_repository.dart';
// import 'package:smartsan_app/features/auth/presentation/signup_view.dart';
// import 'package:smartsan_app/features/auth/data/models/user_model.dart';



// class LoginPage extends StatelessWidget {
//   const LoginPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//   backgroundColor: Color(0xFF62B570), 
//   elevation: 0,
//   automaticallyImplyLeading: false, 
//   actions: [
//     Padding(
//       padding: const EdgeInsets.only(right: 16.0),
//       child: IconButton(
//         onPressed: () {
//           Navigator.push(context, MaterialPageRoute(
//                             builder: (context) => HomePage()));
//         },
//         icon: const Icon(
//           Icons.close,
//           color: Colors.white,
//           size: 24,
//         ),
//       ),
//     ),
//   ],
// ),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF62B570), Color(0xFF62B570)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 'SmartSan',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const SizedBox(height: 8),
//               const SizedBox(height: 40),

//               const String email;
//               const String password;
              
//               // Email TextField
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.9),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: TextField(
//                   decoration: InputDecoration(
//                     prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
//                     hintText: 'Email',
//                     border: InputBorder.none,
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
              
//               // Password TextField
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.9),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: TextField(
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
//                     hintText: 'Password',
//                     border: InputBorder.none,
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
              
//               // Login Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Handle email/password login
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     foregroundColor: Colors.black,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     'Login',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
              
//               _buildLoginButton(
//                 context,
//                 'Login with Google',
//                 Icons.g_mobiledata,
//                 Colors.red,
//                 onPressed: () {
//                   // Handle Google sign in
//                 },
//               ),
//               const SizedBox(height: 30),
              
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     "Don't have an account? ",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => const SignupPage()),
//                       );
//                     },
//                     child: const Text(
//                       'Sign up',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         decoration: TextDecoration.underline,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLoginButton(
//       BuildContext context, String text, IconData icon, Color color,
//       {VoidCallback? onPressed}) {
//     return SizedBox(
//       width: double.infinity,
//       height: 56,
//       child: TextButton(
//         onPressed: onPressed,
//         style: TextButton.styleFrom(
//           backgroundColor: Colors.white.withOpacity(0.9),
//           foregroundColor: Colors.black,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: color, size: 24),
//             const SizedBox(width: 12),
//             Text(
//               text,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// SIGNUP PAGE
// class SignupPage extends StatelessWidget {
//   const SignupPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF62B570), Color(0xFF62B570)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 'Create Account',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Join our our smart sanitation community',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.white70,
//                 ),
//               ),
//               const SizedBox(height: 40),
              
//               // Name TextField
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.9),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: TextField(
//                   decoration: InputDecoration(
//                     prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
//                     hintText: 'Full Name',
//                     border: InputBorder.none,
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
              
//               // Email TextField
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.9),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: TextField(
//                   decoration: InputDecoration(
//                     prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
//                     hintText: 'Email',
//                     border: InputBorder.none,
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
              
//               // Password TextField
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.9),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: TextField(
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
//                     hintText: 'Password',
//                     border: InputBorder.none,
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
              
//               // Confirm Password TextField
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.9),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: TextField(
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
//                     hintText: 'Confirm Password',
//                     border: InputBorder.none,
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
              
//               // Sign Up Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Handle email/password sign up
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     foregroundColor: Colors.black,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     'Sign Up',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
              
//               _buildSignupButton(
//                 context,
//                 'Sign up with Google',
//                 Icons.g_mobiledata,
//                 Colors.red,
//                 onPressed: () {
//                   // Handle Google sign up
//                 },
//               ),
//               const SizedBox(height: 30),
              
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     "Already have an account? ",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => const LoginPage()),
//                       );
//                     },
//                     child: const Text(
//                       'Login',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         decoration: TextDecoration.underline,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSignupButton(
//       BuildContext context, String text, IconData icon, Color color,
//       {VoidCallback? onPressed}) {
//     return SizedBox(
//       width: double.infinity,
//       height: 56,
//       child: TextButton(
//         onPressed: onPressed,
//         style: TextButton.styleFrom(
//           backgroundColor: Colors.white.withOpacity(0.9),
//           foregroundColor: Colors.black,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: color, size: 24),
//             const SizedBox(width: 12),
//             Text(
//               text,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }