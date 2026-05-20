import 'dart:io';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/core/constant_colors.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_bachat/providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _imagePath = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _emailController.text = authProvider.userEmail;
      _nameController.text = authProvider.userName;
      _imagePath = authProvider.imagePath;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveUserData() async {
    if (_emailController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email cannot be empty"),
            backgroundColor: AppColors.color_red,
          ),
        );
      }
      return;
    }

    final newEmail = _emailController.text.trim();
    final newName = _nameController.text.trim();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.saveUserData(
      newName,
      newEmail,
      _imagePath,
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
      Navigator.pop(context, true); // Return true to indicate data changed
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _showImagePickerBottomSheet,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      height: 18.h,
                      width: 18.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryColor,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: _imagePath.isNotEmpty
                            ? Image.file(
                                File(_imagePath),
                                fit: BoxFit.cover,
                                width: 18.h,
                                height: 18.h,
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
                    Container(
                      height: 4.h,
                      width: 4.h,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5.h),
              _buildTextField(
                label: 'Full Name',
                controller: _nameController,
                icon: Icons.person_outline,
              ),
              SizedBox(height: 3.h),
              _buildTextField(
                label: 'Email Address',
                controller: _emailController,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 5.h),
              SizedBox(
                width: double.infinity,
                height: 6.5.h,
                child: ElevatedButton(
                  onPressed: _saveUserData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor: AppColors.primaryColor.withOpacity(0.5),
                  ),
                  child: Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 1.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 16.sp, color: Colors.black87),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primaryColor),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: EdgeInsets.symmetric(
              vertical: 2.h,
              horizontal: 4.w,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
