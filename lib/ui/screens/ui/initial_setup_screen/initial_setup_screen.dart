import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/core/constant_colors.dart';
import 'package:smart_bachat/providers/settings_provider.dart';
import 'package:smart_bachat/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bottom_navigation_bar/my_bottom_bar.dart';

class InitialSetupScreen extends StatefulWidget {
  const InitialSetupScreen({super.key});

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentStep = 0; // 0 = name, 1 = language, 2 = currency

  late String _selectedLanguageCode;
  late String _selectedCurrencyCode;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final sp = Provider.of<SettingsProvider>(context, listen: false);
    _selectedLanguageCode = sp.locale.languageCode;
    _selectedCurrencyCode = sp.currencyCode;

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _animateToNextStep() {
    if (_currentStep == 0 && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }
    _slideController.reset();
    _fadeController.reset();
    setState(() => _currentStep++);
    _slideController.forward();
    _fadeController.forward();
  }

  void _animateToPrevStep() {
    if (_currentStep == 0) return;
    _slideController.reset();
    _fadeController.reset();
    setState(() => _currentStep--);
    _slideController.forward();
    _fadeController.forward();
  }

  Future<void> _finish() async {
    final sp = Provider.of<SettingsProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    final selCurr = SettingsProvider.supportedCurrencies.firstWhere(
      (c) => c.code == _selectedCurrencyCode,
    );
    await sp.setLocale(Locale(_selectedLanguageCode));
    await sp.setCurrency(selCurr.code, selCurr.symbol);
    await sp.completeSetup();

    // Set offline dummy user session
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = DateTime.now().microsecondsSinceEpoch.toString();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('loggedInUID', uid);
    await prefs.setString('name_$uid', _nameController.text.trim());

    if (mounted) {
      await authProvider.checkLoginStatus();
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const MyBottomBar()),
      );
    }
  }

  void _skip() {
    debugPrint('SmartBachat: Skip clicked at step $_currentStep');
    if (_currentStep < 2) {
      if (_currentStep == 0 && _nameController.text.trim().isEmpty) {
        _nameController.text = 'User';
      }
      debugPrint(
        'SmartBachat: Moving from $_currentStep to ${_currentStep + 1}',
      );
      _animateToNextStep();
    } else {
      debugPrint('SmartBachat: Last step reached, completing setup.');
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top gradient blob
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 50.w,
              height: 30.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            top: 5.h,
            right: -40,
            child: Container(
              width: 30.w,
              height: 20.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.08),
              ),
            ),
          ),
          // Bottom blob
          Positioned(
            bottom: -50,
            right: -30,
            child: Container(
              width: 45.w,
              height: 25.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor.withValues(alpha: 0.08),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top navigation row: Back (left) + Skip (right)
                Padding(
                  padding: EdgeInsets.only(top: 0.5.h, left: 2.w, right: 4.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button — hidden on step 0
                      AnimatedOpacity(
                        opacity: _currentStep > 0 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        child: GestureDetector(
                          onTap: _currentStep > 0 ? _animateToPrevStep : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: AppColors.primaryColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Back',
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Skip button
                      TextButton(
                        onPressed: _skip,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Fixed Logo (always at top, doesn't animate) ──────
                Center(
                  child: SizedBox(
                    height: 17.h,
                    width: 17.h,
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: _currentStep == 0
                            ? _buildNameStep()
                            : _currentStep == 1
                            ? _buildLanguageStep()
                            : _buildCurrencyStep(),
                      ),
                    ),
                  ),
                ),

                // Bottom step indicator & button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 1.5.h,
                  ),
                  child: Column(
                    children: [
                      // Step dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentStep == i ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentStep == i
                                  ? AppColors.primaryColor
                                  : AppColors.primaryColor.withValues(
                                      alpha: 0.25,
                                    ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 1.5.h),
                      // Next / Get Started button
                      SizedBox(
                        width: double.infinity,
                        height: 6.5.h,
                        child: ElevatedButton(
                          onPressed: _currentStep < 2
                              ? _animateToNextStep
                              : _finish,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 4,
                            shadowColor: AppColors.primaryColor.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          child: Text(
                            _currentStep < 2 ? 'Continue →' : 'Get Started 🚀',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 1.5.h),
          Text(
            'What Should We\nCall You?',
            style: TextStyle(
              fontSize: 25.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Enter your name to personalize your experience.',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 4.h),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              filled: true,
              fillColor: AppColors.primaryColor.withValues(alpha: 0.04),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.primaryColor,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 2.h,
              ),
            ),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 1.5.h),
        Text(
          'Choose Your\nLanguage',
          style: TextStyle(
            fontSize: 25.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Select a language that suits you best.',
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        SizedBox(height: 3.h),
        Expanded(
          child: ListView.separated(
            itemCount: SettingsProvider.supportedLanguages.length,
            separatorBuilder: (_, __) => SizedBox(height: 1.2.h),
            itemBuilder: (_, i) {
              final lang = SettingsProvider.supportedLanguages[i];
              final isSelected = lang.code == _selectedLanguageCode;
              return _OptionTile(
                flag: lang.flag,
                title: lang.nativeName,
                subtitle: lang.name,
                isSelected: isSelected,
                onTap: () => setState(() => _selectedLanguageCode = lang.code),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 1.5.h),
        Text(
          'Choose Your\nCurrency',
          style: TextStyle(
            fontSize: 25.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'All amounts will be displayed in this currency.',
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        SizedBox(height: 3.h),
        Expanded(
          child: ListView.separated(
            itemCount: SettingsProvider.supportedCurrencies.length,
            separatorBuilder: (_, __) => SizedBox(height: 1.2.h),
            itemBuilder: (_, i) {
              final curr = SettingsProvider.supportedCurrencies[i];
              final isSelected = curr.code == _selectedCurrencyCode;
              return _OptionTile(
                flag: curr.flag,
                title: '${curr.code}  ${curr.symbol.trim()}',
                subtitle: curr.name,
                isSelected: isSelected,
                onTap: () => setState(() => _selectedCurrencyCode = curr.code),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String flag;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.flag,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 26)),
            SizedBox(width: 3.5.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5.sp,
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedScale(
              scale: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
