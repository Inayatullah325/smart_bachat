import 'dart:io';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/ui/components/alert_dialog.dart';
import 'package:smart_bachat/ui/screens/ui/home_screen/home_screen.dart';
import 'package:smart_bachat/ui/screens/ui/income_screen/income_screen.dart';
import 'package:smart_bachat/ui/screens/ui/all_expenses_screen/all_expenses_screen.dart';
import 'package:smart_bachat/ui/screens/ui/reports_screen/reports_screen.dart';
import 'package:smart_bachat/ui/screens/ui/profile_screen/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:smart_bachat/providers/auth_provider.dart';

class MyNavigationDrawer extends StatefulWidget {
  const MyNavigationDrawer({super.key});

  @override
  State<MyNavigationDrawer> createState() => _MyNavigationDrawerState();
}

class _MyNavigationDrawerState extends State<MyNavigationDrawer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Drawer(
      width: MediaQuery.of(context).size.width / 2,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.only(top: 2.h, bottom: 0.02.h),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.zero,
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.only(
                  top: 6.h,
                  bottom: 3.h,
                  left: 5.w,
                  right: 5.w,
                ),
                child: Column(
                  children: [
                    // Profile Image or Logo
                    Container(
                      height: 14.h,
                      width: 14.h,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white24,
                      ),
                      child: ClipOval(
                        child: authProvider.imagePath.isNotEmpty
                            ? Image.file(
                                File(authProvider.imagePath),
                                fit: BoxFit.cover,
                                width: 14.h,
                                height: 14.h,
                              )
                            : Padding(
                                padding: EdgeInsets.all(1.5.h),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    // Name
                    Text(
                      authProvider.userName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Email
                    Text(
                      authProvider.userEmail,
                      style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white54, indent: 20, endIndent: 20),

              // Menu Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerTile(
                      icon: Icons.home_outlined,
                      title: 'Home',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      },
                    ),
                    _buildDrawerTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Income',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const IncomeScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerTile(
                      icon: Icons.credit_score_outlined,
                      title: 'Expenses',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AllExpensesScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerTile(
                      icon: Icons.bar_chart_outlined,
                      title: 'Statistics',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReportsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerTile(
                      icon: Icons.person_outline,
                      title: 'Profile',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),

                    // Logout
                    _buildDrawerTile(
                      icon: Icons.logout,
                      title: 'Logout',
                      onTap: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (_) => const MyAlertDialog(),
                          barrierDismissible: false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 22.sp),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: onTap,
    );
  }
}
