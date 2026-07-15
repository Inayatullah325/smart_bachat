import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/core/constant_colors.dart';
import 'package:smart_bachat/l10n/app_localizations.dart';
import 'package:smart_bachat/providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMsg;

  bool _isEmailVerified = false;
  String? _verifiedUid;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  String _localString(String key) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final translations = {
      'new_password': {
        'en': 'New Password',
        'ur': 'نیا پاس ورڈ',
        'ar': 'كلمة المرور الجديدة',
        'hi': 'नया पासवर्ड',
        'es': 'Nueva contraseña',
        'fr': 'Nouveau mot de passe',
        'zh': '新密码',
      },
      'confirm_password': {
        'en': 'Confirm Password',
        'ur': 'پاس ورڈ کی تصدیق کریں',
        'ar': 'تأكيد كلمة المرور',
        'hi': 'पासवर्ड की पुष्टि करें',
        'es': 'Confirmar contraseña',
        'fr': 'Confirmer le mot de passe',
        'zh': '确认密码',
      },
      'passwords_dont_match': {
        'en': 'Passwords do not match',
        'ur': 'پاس ورڈ مطابقت نہیں رکھتے',
        'ar': 'كلمات المرور غير متطابقة',
        'hi': 'पासवर्ड मेल नहीं खाते',
        'es': 'Las contraseñas no coinciden',
        'fr': 'Les mots de passe ne correspondent pas',
        'zh': '密码不匹配',
      },
      'password_length_error': {
        'en': 'Password must be at least 6 characters long',
        'ur': 'پاس ورڈ کم از کم 6 حروف کا ہونا چاہیے',
        'ar': 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل',
        'hi': 'पासवर्ड कम से कम 6 अक्षरों का होना चाहिए',
        'es': 'La contraseña debe tener al menos 6 caracteres',
        'fr': 'Le mot de passe doit comporter au moins 6 caractères',
        'zh': '密码长度必须至少为 6 个字符',
      },
      'password_updated': {
        'en': 'Password updated successfully!',
        'ur': 'پاس ورڈ کامیابی سے اپ ڈیٹ ہو گیا!',
        'ar': 'تم تحديث كلمة المرور بنجاح!',
        'hi': 'पासवर्ड सफलतापूर्वक अपडेट किया गया!',
        'es': '¡Contraseña actualizada con éxito!',
        'fr': 'Mot de passe mis à jour avec succès !',
        'zh': '密码更新成功！',
      },
      'verify_email': {
        'en': 'Verify Email',
        'ur': 'ای میل کی تصدیق کریں',
        'ar': 'التحقق من البريد الإلكتروني',
        'hi': 'ईमेल सत्यापित करें',
        'es': 'Verificar correo electrónico',
        'fr': 'Vérifier l\'e-mail',
        'zh': '验证电子邮件',
      },
      'enter_password_error': {
        'en': 'Please enter a password',
        'ur': 'براہ کرم پاس ورڈ درج کریں',
        'ar': 'الرجاء إدخال كلمة المرور',
        'hi': 'कृपया पासवर्ड दर्ज करें',
        'es': 'Por favor, ingrese una contraseña',
        'fr': 'Veuillez saisir un mot de passe',
        'zh': '请输入密码',
      },
      'confirm_password_error': {
        'en': 'Please confirm your password',
        'ur': 'براہ کرم اپنے پاس ورڈ کی تصدیق کریں',
        'ar': 'الرجاء تأكيد كلمة المرور الخاصة بك',
        'hi': 'कृपया अपने पासवर्ड की पुष्टि करें',
        'es': 'Por favor, confirme su contraseña',
        'fr': 'Veuillez confirmer votre mot de passe',
        'zh': '请确认您的密码',
      },
      'enter_new_pass_instruction': {
        'en': 'Please enter and confirm your new password below.',
        'ur': 'براہ کرم نیچے apna نیا پاس ورڈ درج کریں اور اس کی تصدیق کریں۔',
        'ar': 'الرجاء إدخال وتأكيد كلمة المرور الجديدة أدناه.',
        'hi': 'कृपया नीचे अपना नया पासवर्ड दर्ज करें और पुष्टि करें।',
        'es':
            'Por favor, ingrese y confirme su nueva contraseña a continuación.',
        'fr':
            'Veuillez saisir et confirmer votre nouveau mot de passe ci-dessous.',
        'zh': '请在下方输入并确认您的新密码。',
      },
      'update_password_btn': {
        'en': 'Update Password',
        'ur': 'پاس ورڈ تبدیل کریں',
        'ar': 'تحديث كلمة المرور',
        'hi': 'पासवर्ड अपडेट करें',
        'es': 'Actualizar contraseña',
        'fr': 'Mettre à jour le mot de passe',
        'zh': '更新密码',
      },
    };

    return translations[key]?[languageCode] ?? translations[key]?['en'] ?? key;
  }

  Future<void> _handleResetFlow() async {
    if (_isEmailVerified) {
      await _updatePassword();
    } else {
      await _verifyEmail();
    }
  }

  Future<void> _verifyEmail() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    // Simulate a short delay for UX
    await Future.delayed(const Duration(milliseconds: 800));

    final emailInput = _emailController.text.trim();
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final uid = await authProvider.verifyEmail(
      emailInput,
      onError: (err) {
        if (mounted) {
          setState(() {
            _errorMsg = err;
          });
        }
      },
    );

    if (!mounted) return;

    if (uid == null) {
      setState(() {
        _isLoading = false;
        _errorMsg = l10n.noAccountFound;
      });
      return;
    }

    setState(() {
      _isLoading = false;
      _isEmailVerified = true;
      _verifiedUid = uid;
    });
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (_verifiedUid == null) {
      setState(() {
        _isLoading = false;
        _errorMsg = "Verification error. Please restart.";
      });
      return;
    }

    final newPassword = _passwordController.text;
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.updatePassword(_verifiedUid!, newPassword);

    setState(() => _isLoading = false);

    if (mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 3.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryColor, AppColors.buttonsColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(
                    20,
                  ).copyWith(bottomLeft: Radius.zero, bottomRight: Radius.zero),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Success!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              Padding(
                padding: EdgeInsets.all(5.w),
                child: Column(
                  children: [
                    Text(
                      _localString('password_updated'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 3.h),

                    // Back to Login button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx); // close dialog
                          Navigator.pop(context); // go back to login
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          elevation: 3,
                        ),
                        child: Text(
                          l10n.goToLogin,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.primaryColor,
          ),
          onPressed: () {
            if (_isEmailVerified) {
              setState(() {
                _isEmailVerified = false;
                _passwordController.clear();
                _confirmPasswordController.clear();
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),

                    // Icon header
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryColor.withValues(alpha: 0.1),
                              AppColors.buttonsColor.withValues(alpha: 0.15),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isEmailVerified
                              ? Icons.vpn_key_rounded
                              : Icons.lock_reset_rounded,
                          size: 56,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Title
                    Center(
                      child: Text(
                        _isEmailVerified
                            ? _localString('new_password')
                            : l10n.forgot_password,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                    SizedBox(height: 1.h),

                    Center(
                      child: Text(
                        _isEmailVerified
                            ? _localString('enter_new_pass_instruction')
                            : l10n.forgotPasswordInstruction,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ),

                    SizedBox(height: 5.h),

                    if (!_isEmailVerified) ...[
                      // Email Field
                      Text(
                        l10n.emailAddress,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleResetFlow(),
                        decoration: InputDecoration(
                          hintText: l10n.emailHintText,
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13.sp,
                          ),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppColors.primaryColor,
                          ),
                          filled: true,
                          fillColor: AppColors.primaryColor.withValues(alpha: 0.04),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: AppColors.primaryColor,
                              width: 1.8,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: AppColors.expenseColor,
                              width: 1.5,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: AppColors.expenseColor,
                              width: 1.8,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return l10n.pleaseEnterEmail;
                          }
                          final emailRegex = RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          );
                          if (!emailRegex.hasMatch(v.trim())) {
                            return l10n.pleaseEnterValidEmail;
                          }
                          return null;
                        },
                      ),
                    ] else ...[
                      // New Password Field
                      Text(
                        _localString('new_password'),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: '••••••',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13.sp,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppColors.primaryColor,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: AppColors.primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: AppColors.primaryColor.withValues(alpha: 0.04),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: AppColors.primaryColor,
                              width: 1.8,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: AppColors.expenseColor,
                              width: 1.5,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: AppColors.expenseColor,
                              width: 1.8,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return _localString('enter_password_error');
                          }
                          if (v.length < 6) {
                            return _localString('password_length_error');
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 3.h),

                      // Confirm Password Field
                      Text(
                        _localString('confirm_password'),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleResetFlow(),
                        decoration: InputDecoration(
                          hintText: '••••••',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13.sp,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_reset_rounded,
                            color: AppColors.primaryColor,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: AppColors.primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: AppColors.primaryColor.withValues(alpha: 0.04),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: AppColors.primaryColor,
                              width: 1.8,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: AppColors.expenseColor,
                              width: 1.5,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: AppColors.expenseColor,
                              width: 1.8,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return _localString('confirm_password_error');
                          }
                          if (v != _passwordController.text) {
                            return _localString('passwords_dont_match');
                          }
                          return null;
                        },
                      ),
                    ],

                    // Error message
                    if (_errorMsg != null) ...[
                      SizedBox(height: 1.5.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.expenseColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.expenseColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.expenseColor,
                              size: 18,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                _errorMsg!,
                                style: TextStyle(
                                  color: AppColors.expenseColor,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 4.h),

                    // Process Button
                    SizedBox(
                      width: double.infinity,
                      height: 6.5.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleResetFlow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          disabledBackgroundColor: AppColors.primaryColor
                              .withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                _isEmailVerified
                                    ? _localString('update_password_btn')
                                    : _localString('verify_email'),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Back to login
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 13.sp),
                            children: [
                              TextSpan(
                                text: l10n.rememberPasswordQuestion,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              TextSpan(
                                text: l10n.login,
                                style: const TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
