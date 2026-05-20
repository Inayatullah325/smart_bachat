import 'dart:io';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/core/constant_colors.dart';
import 'package:smart_bachat/ui/screens/ui/profile_screen/edit_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:smart_bachat/providers/auth_provider.dart';
import 'package:smart_bachat/ui/components/alert_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
              // If data was updated, reload it
              if (result == true) {
                if (mounted) {
                  Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  ).loadUserData();
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(bottom: 4.h),
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 2.h),
                Container(
                  height: 17.h,
                  width: 17.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: authProvider.imagePath.isNotEmpty
                        ? Image.file(
                            File(authProvider.imagePath),
                            fit: BoxFit.cover,
                            width: 17.h,
                            height: 17.h,
                          )
                        : Container(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            child: Icon(
                              Icons.person,
                              size: 10.h,
                              color: AppColors.primaryColor,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  authProvider.userName,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  authProvider.userEmail,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          // Options Section
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: ListView(
                children: [
                  _buildProfileOption(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {},
                  ),
                  _buildProfileOption(
                    icon: Icons.security,
                    title: 'Security',
                    onTap: () {},
                  ),
                  _buildProfileOption(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {},
                  ),
                  _buildProfileOption(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const MyAlertDialog(),
                        barrierDismissible: false,
                      );
                    },
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
        leading: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withOpacity(0.1)
                : AppColors.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : AppColors.primaryColor,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
