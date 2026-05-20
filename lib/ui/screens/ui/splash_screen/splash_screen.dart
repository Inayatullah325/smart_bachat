import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_bachat/providers/auth_provider.dart';

import 'package:smart_bachat/core/constant_colors.dart';

import '../bottom_navigation_bar/my_bottom_bar.dart';
import '../login_screen/login_screen.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkLoginStatus();

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                authProvider.isLoggedIn ? const MyBottomBar() : const LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor,
              AppColors.buttonsColor,
              Colors.lightBlueAccent,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: MediaQuery.of(context).size.height * 0.40,
                //color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
