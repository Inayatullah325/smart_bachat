import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized language and currency configuration — single source of truth (MVVM Model layer)
class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final bool isRTL;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    this.isRTL = false,
  });
}

class AppCurrency {
  final String code;
  final String symbol;
  final String name;
  final String flag;

  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
  });
}

class SettingsProvider with ChangeNotifier {
  Locale _locale = const Locale('en');
  String _currencyCode = 'PKR';
  String _currencySymbol = 'Rs. ';
  bool _isSetupCompleted = false;

  Locale get locale => _locale;
  String get currencyCode => _currencyCode;
  String get currencySymbol => _currencySymbol;
  bool get isSetupCompleted => _isSetupCompleted;

  /// All supported languages
  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸',
    ),
    AppLanguage(
      code: 'ur',
      name: 'Urdu',
      nativeName: 'اردو',
      flag: '🇵🇰',
      isRTL: true,
    ),
    AppLanguage(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
      flag: '🇸🇦',
      isRTL: true,
    ),
    AppLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिंदी', flag: '🇮🇳'),
    AppLanguage(
      code: 'es',
      name: 'Spanish',
      nativeName: 'Español',
      flag: '🇪🇸',
    ),
    AppLanguage(
      code: 'fr',
      name: 'French',
      nativeName: 'Français',
      flag: '🇫🇷',
    ),
    AppLanguage(code: 'zh', name: 'Chinese', nativeName: '中文', flag: '🇨🇳'),
  ];

  /// All supported currencies
  static const List<AppCurrency> supportedCurrencies = [
    AppCurrency(
      code: 'PKR',
      symbol: 'Rs. ',
      name: 'Pakistani Rupee',
      flag: '🇵🇰',
    ),
    AppCurrency(code: 'USD', symbol: '\$ ', name: 'US Dollar', flag: '🇺🇸'),
    AppCurrency(code: 'EUR', symbol: '€ ', name: 'Euro', flag: '🇪🇺'),
    AppCurrency(code: 'GBP', symbol: '£ ', name: 'British Pound', flag: '🇬🇧'),
    AppCurrency(code: 'SAR', symbol: '﷼ ', name: 'Saudi Riyal', flag: '🇸🇦'),
    AppCurrency(code: 'AED', symbol: 'د.إ ', name: 'UAE Dirham', flag: '🇦🇪'),
    AppCurrency(code: 'INR', symbol: '₹ ', name: 'Indian Rupee', flag: '🇮🇳'),
    AppCurrency(
      code: 'BDT',
      symbol: '৳ ',
      name: 'Bangladeshi Taka',
      flag: '🇧🇩',
    ),
    AppCurrency(code: 'CNY', symbol: '¥ ', name: 'Chinese Yuan', flag: '🇨🇳'),
    AppCurrency(code: 'JPY', symbol: '¥ ', name: 'Japanese Yen', flag: '🇯🇵'),
    AppCurrency(
      code: 'KWD',
      symbol: 'KD ',
      name: 'Kuwaiti Dinar',
      flag: '🇰🇼',
    ),
    AppCurrency(code: 'OMR', symbol: 'ﷻ ', name: 'Omani Rial', flag: '🇴🇲'),
    AppCurrency(code: 'QAR', symbol: 'QR ', name: 'Qatari Riyal', flag: '🇶🇦'),
    AppCurrency(
      code: 'BHD',
      symbol: 'BD ',
      name: 'Bahraini Dinar',
      flag: '🇧🇭',
    ),
    AppCurrency(
      code: 'MYR',
      symbol: 'RM ',
      name: 'Malaysian Ringgit',
      flag: '🇲🇾',
    ),
    AppCurrency(code: 'TRY', symbol: '₺ ', name: 'Turkish Lira', flag: '🇹🇷'),
    AppCurrency(
      code: 'CAD',
      symbol: 'C\$ ',
      name: 'Canadian Dollar',
      flag: '🇨🇦',
    ),
    AppCurrency(
      code: 'AUD',
      symbol: 'A\$ ',
      name: 'Australian Dollar',
      flag: '🇦🇺',
    ),
    AppCurrency(code: 'CHF', symbol: 'Fr. ', name: 'Swiss Franc', flag: '🇨🇭'),
    AppCurrency(
      code: 'SGD',
      symbol: 'S\$ ',
      name: 'Singapore Dollar',
      flag: '🇸🇬',
    ),
  ];

  /// Get current language object
  AppLanguage get currentLanguage => supportedLanguages.firstWhere(
    (l) => l.code == _locale.languageCode,
    orElse: () => supportedLanguages.first,
  );

  /// Get current currency object
  AppCurrency get currentCurrency => supportedCurrencies.firstWhere(
    (c) => c.code == _currencyCode,
    orElse: () => supportedCurrencies.first,
  );

  SettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? 'en';
    _locale = Locale(langCode);
    _currencyCode = prefs.getString('currency_code') ?? 'PKR';
    _currencySymbol = prefs.getString('currency_symbol') ?? 'Rs. ';
    _isSetupCompleted = prefs.getBool('is_setup_completed') ?? false;
    notifyListeners();
  }

  Future<void> setLocale(Locale newLocale) async {
    _locale = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', newLocale.languageCode);
    notifyListeners();
  }

  Future<void> setCurrency(String code, String symbol) async {
    _currencyCode = code;
    _currencySymbol = symbol;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency_code', code);
    await prefs.setString('currency_symbol', symbol);
    notifyListeners();
  }

  Future<void> completeSetup() async {
    _isSetupCompleted = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_setup_completed', true);
    notifyListeners();
  }

  Future<void> resetSetupStatus() async {
    _isSetupCompleted = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_setup_completed');
    notifyListeners();
  }
}
