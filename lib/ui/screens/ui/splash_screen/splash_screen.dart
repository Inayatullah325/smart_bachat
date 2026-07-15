import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_bachat/core/constant_colors.dart';
import 'package:smart_bachat/providers/auth_provider.dart';
import 'package:smart_bachat/services/notification_service.dart';

import '../bottom_navigation_bar/my_bottom_bar.dart';
import 'package:smart_bachat/providers/settings_provider.dart';
import 'package:smart_bachat/ui/screens/ui/initial_setup_screen/initial_setup_screen.dart';

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
    try {
      await NotificationService().syncFiredNotifications();
      if (await NotificationService().isEnabled()) {
        await NotificationService().scheduleDailyNotification();
      }
    } catch (e) {
      debugPrint('Notification schedule failed: $e');
    }

    Timer(const Duration(seconds: 4), () async {
      if (!mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider
          .checkLoginStatus(); // keep local state populated if logged in previously

      if (mounted) {
        final settingsProvider = Provider.of<SettingsProvider>(
          context,
          listen: false,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              if (authProvider.isLoggedIn &&
                  settingsProvider.isSetupCompleted) {
                return const MyBottomBar();
              } else {
                return const InitialSetupScreen();
              }
            },
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
