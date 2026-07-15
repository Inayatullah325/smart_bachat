import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/core/constant_colors.dart';
import 'package:smart_bachat/providers/settings_provider.dart';
import 'package:smart_bachat/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late String _selectedLanguageCode;
  late String _selectedCurrencyCode;
  bool _languageExpanded = false;
  bool _currencyExpanded = false;

  late AnimationController _saveController;

  @override
  void initState() {
    super.initState();
    final sp = Provider.of<SettingsProvider>(context, listen: false);
    _selectedLanguageCode = sp.locale.languageCode;
    _selectedCurrencyCode = sp.currencyCode;

    _saveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _saveController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final sp = Provider.of<SettingsProvider>(context, listen: false);
    final selCurr = SettingsProvider.supportedCurrencies.firstWhere(
      (c) => c.code == _selectedCurrencyCode,
    );
    await sp.setLocale(Locale(_selectedLanguageCode));
    await sp.setCurrency(selCurr.code, selCurr.symbol);

    if (mounted) {
      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.incomeColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 2.w),
              Text(
                _selectedLanguageCode == 'ur'
                    ? 'سیٹنگز کامیابی سے محفوظ ہوگئیں!'
                    : _selectedLanguageCode == 'ar'
                    ? 'تم حفظ الإعدادات بنجاح!'
                    : 'Settings saved successfully!',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  AppLanguage get _selectedLanguage => SettingsProvider.supportedLanguages
      .firstWhere((l) => l.code == _selectedLanguageCode);

  AppCurrency get _selectedCurrency => SettingsProvider.supportedCurrencies
      .firstWhere((c) => c.code == _selectedCurrencyCode);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n?.settings ?? 'Settings',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        // Gradient AppBar via FlexibleSpace
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF27AAE1), Color(0xFF1E7FBF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Header info card
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(4.w),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF27AAE1), Color(0xFF1E7FBF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildInfoChip(
                  _selectedLanguage.flag,
                  _selectedLanguage.nativeName,
                  'Language',
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white30,
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                ),
                _buildInfoChip(
                  _selectedCurrency.flag,
                  _selectedCurrency.code,
                  'Currency',
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              children: [
                // ─── Language Section ────────────────────────
                _buildSectionLabel(
                  icon: Icons.language_rounded,
                  label: l10n?.selectLanguage ?? 'Select Language',
                  color: AppColors.primaryColor,
                ),
                SizedBox(height: 1.h),
                // Current selection tile (tap to expand)
                _buildSelectionTile(
                  flag: _selectedLanguage.flag,
                  title: _selectedLanguage.nativeName,
                  subtitle: _selectedLanguage.name,
                  isExpanded: _languageExpanded,
                  onTap: () => setState(() {
                    _languageExpanded = !_languageExpanded;
                    _currencyExpanded = false;
                  }),
                  accentColor: AppColors.primaryColor,
                ),
                // Expanded language list
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _languageExpanded
                      ? _buildOptionList(
                          items: SettingsProvider.supportedLanguages
                              .map(
                                (l) => _ItemData(
                                  flag: l.flag,
                                  title: l.nativeName,
                                  subtitle: l.name,
                                  code: l.code,
                                ),
                              )
                              .toList(),
                          selectedCode: _selectedLanguageCode,
                          accentColor: AppColors.primaryColor,
                          onSelect: (code) => setState(() {
                            _selectedLanguageCode = code;
                            _languageExpanded = false;
                          }),
                        )
                      : const SizedBox.shrink(),
                ),

                SizedBox(height: 2.5.h),

                // ─── Currency Section ────────────────────────
                _buildSectionLabel(
                  icon: Icons.monetization_on_rounded,
                  label: l10n?.selectCurrency ?? 'Select Currency',
                  color: AppColors.incomeColor,
                ),
                SizedBox(height: 1.h),
                _buildSelectionTile(
                  flag: _selectedCurrency.flag,
                  title:
                      '${_selectedCurrency.code}  ${_selectedCurrency.symbol.trim()}',
                  subtitle: _selectedCurrency.name,
                  isExpanded: _currencyExpanded,
                  onTap: () => setState(() {
                    _currencyExpanded = !_currencyExpanded;
                    _languageExpanded = false;
                  }),
                  accentColor: AppColors.incomeColor,
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _currencyExpanded
                      ? _buildOptionList(
                          items: SettingsProvider.supportedCurrencies
                              .map(
                                (c) => _ItemData(
                                  flag: c.flag,
                                  title: '${c.code}  ${c.symbol.trim()}',
                                  subtitle: c.name,
                                  code: c.code,
                                ),
                              )
                              .toList(),
                          selectedCode: _selectedCurrencyCode,
                          accentColor: AppColors.incomeColor,
                          onSelect: (code) => setState(() {
                            _selectedCurrencyCode = code;
                            _currencyExpanded = false;
                          }),
                        )
                      : const SizedBox.shrink(),
                ),

                SizedBox(height: 3.h),
              ],
            ),
          ),

          // Save button fixed at bottom
          Container(
            padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 3.5.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 6.5.h,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 3,
                  shadowColor: AppColors.primaryColor.withValues(alpha: 0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.save_rounded, size: 20),
                    SizedBox(width: 2.w),
                    Text(
                      l10n?.save ?? 'Save Changes',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String flag, String title, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white60,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.4.h),
          Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 18)),
              SizedBox(width: 1.5.w),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        SizedBox(width: 2.5.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 15.5.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionTile({
    required String flag,
    required String title,
    required String subtitle,
    required bool isExpanded,
    required VoidCallback onTap,
    required Color accentColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded ? accentColor : Colors.grey.shade200,
            width: isExpanded ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                      color: accentColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: accentColor,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionList({
    required List<_ItemData> items,
    required String selectedCode,
    required Color accentColor,
    required void Function(String) onSelect,
  }) {
    return Container(
      margin: EdgeInsets.only(top: 1.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: List.generate(items.length, (i) {
            final item = items[i];
            final isSelected = item.code == selectedCode;
            return Column(
              children: [
                InkWell(
                  onTap: () => onSelect(item.code),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.5.h,
                    ),
                    color: isSelected
                        ? accentColor.withValues(alpha: 0.07)
                        : Colors.transparent,
                    child: Row(
                      children: [
                        Text(item.flag, style: const TextStyle(fontSize: 22)),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 14.5.sp,
                                  color: isSelected
                                      ? accentColor
                                      : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                item.subtitle,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (i < items.length - 1)
                  Divider(height: 1, color: Colors.grey.shade100, indent: 4.w),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _ItemData {
  final String flag;
  final String title;
  final String subtitle;
  final String code;
  const _ItemData({
    required this.flag,
    required this.title,
    required this.subtitle,
    required this.code,
  });
}
