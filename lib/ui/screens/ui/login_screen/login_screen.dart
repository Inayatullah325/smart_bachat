import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:provider/provider.dart';
import 'package:smart_bachat/providers/auth_provider.dart';
import 'package:smart_bachat/core/constant_colors.dart';

import '../bottom_navigation_bar/my_bottom_bar.dart';
import '../sign_up_screen/sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _login() async {
    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        email,
        password,
        onError: (errorMsg) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMsg),
                backgroundColor: AppColors.color_red,
              ),
            );
          }
        },
      );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyBottomBar()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter both email and password."),
            backgroundColor: AppColors.color_red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section
            Container(
              height: 40.h,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor,
                    AppColors.buttonsColor,
                    Colors.lightBlueAccent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 15.h,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Login to continue your journey',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 5.h),
            
            // Bottom Section (Form)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Column(
                children: [
                  // Email Field
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 3.h),
                  
                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: AppColors.primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 2.h),
                  
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppColors.secondaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 3.h),
                  
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 6.5.h,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'LOGIN',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final newEmail = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpScreen()),
                          );
                          if (newEmail != null && newEmail is String) {
                            setState(() {
                              _emailController.text = newEmail;
                              _passwordController.clear();
                            });
                          }
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
