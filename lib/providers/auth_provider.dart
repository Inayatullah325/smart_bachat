import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_bachat/database_handler/database_handler.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _loggedInUID;
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  String _imagePath = '';
  bool _isLoading = false;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  bool get isLoggedIn => _isLoggedIn;
  String? get loggedInUID => _loggedInUID;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get imagePath => _imagePath;
  bool get isLoading => _isLoading;

  final DatabaseHandler _db = DatabaseHandler();

  Future<void> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (_isLoggedIn) {
      _loggedInUID = prefs.getString('loggedInUID');

      // Migrate legacy user if loggedInUID is null but isLoggedIn is true
      if (_loggedInUID == null) {
        String email = prefs.getString('registeredEmail') ?? 'default';
        String uid = DateTime.now().microsecondsSinceEpoch.toString();
        _loggedInUID = uid;
        await prefs.setString('loggedInUID', uid);
        await prefs.setString('uid_$email', uid);
        await prefs.setString('email_$uid', email);

        String? name = prefs.getString('name_$email');
        if (name != null) await prefs.setString('name_$uid', name);

        String? image = prefs.getString('image_$email');
        if (image != null) await prefs.setString('image_$uid', image);

        String? password = prefs.getString('password_$email');
        if (password != null) await prefs.setString('password_$uid', password);

        // Migrate SQLite records
        await _db.updateUserEmailInDatabase(email, uid);
      }

      // Load user details
      _userEmail = prefs.getString('email_$_loggedInUID') ?? 'user@email.com';
      _userName = prefs.getString('name_$_loggedInUID') ?? 'User Name';
      _imagePath = prefs.getString('image_$_loggedInUID') ?? '';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadUserData() async {
    if (_loggedInUID == null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('email_$_loggedInUID') ?? 'user@email.com';
    _userName = prefs.getString('name_$_loggedInUID') ?? 'User Name';
    _imagePath = prefs.getString('image_$_loggedInUID') ?? '';
    notifyListeners();
  }

  Future<bool> login(
    String email,
    String password, {
    required Function(String) onError,
  }) async {
    _isLoading = true;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid_$email');
    String? savedPassword = uid != null
        ? prefs.getString('password_$uid')
        : null;

    if (uid == null) {
      // Check legacy user migration
      String? legacyPassword = prefs.getString('password_$email');
      if (legacyPassword != null && legacyPassword == password) {
        uid = DateTime.now().microsecondsSinceEpoch.toString();
        await prefs.setString('uid_$email', uid);
        await prefs.setString('email_$uid', email);
        await prefs.setString('password_$uid', password);

        String? legacyName = prefs.getString('name_$email');
        if (legacyName != null) await prefs.setString('name_$uid', legacyName);

        String? legacyImage = prefs.getString('image_$email');
        if (legacyImage != null)
          await prefs.setString('image_$uid', legacyImage);

        await _db.updateUserEmailInDatabase(email, uid);
        savedPassword = password;
      }
    }

    if (savedPassword != null && savedPassword == password && uid != null) {
      _isLoggedIn = true;
      _loggedInUID = uid;
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('loggedInUID', uid);
      await prefs.setString('registeredEmail', email);

      await loadUserData();

      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      onError("Invalid email or password!");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(
    String name,
    String email,
    String password, {
    required Function(String) onError,
  }) async {
    _isLoading = true;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? existingUid = prefs.getString('uid_$email');

    if (existingUid != null) {
      onError("Email is already registered! Please login.");
      _isLoading = false;
      notifyListeners();
      return false;
    }

    String uid = DateTime.now().microsecondsSinceEpoch.toString();
    await prefs.setString('uid_$email', uid);
    await prefs.setString('email_$uid', email);
    await prefs.setString('name_$uid', name);
    await prefs.setString('password_$uid', password);
    await prefs.setString('image_$uid', '');

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> saveUserData(
    String newName,
    String newEmail,
    String newImagePath, {
    required Function(String) onError,
  }) async {
    if (_loggedInUID == null) return false;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = _loggedInUID!;
    String originalEmail = prefs.getString('email_$uid') ?? 'user@email.com';

    // Check if new email is already registered under another account
    String? existingUid = prefs.getString('uid_$newEmail');
    if (existingUid != null && existingUid != uid) {
      onError("This email is already in use by another account!");
      return false;
    }

    if (newEmail != originalEmail) {
      await prefs.remove('uid_$originalEmail');
      await prefs.setString('uid_$newEmail', uid);
      await prefs.setString('email_$uid', newEmail);
      await prefs.setString('registeredEmail', newEmail);
    }

    await prefs.setString('name_$uid', newName);
    await prefs.setString('image_$uid', newImagePath);

    await loadUserData();
    return true;
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('loggedInUID');
    _isLoggedIn = false;
    _loggedInUID = null;
    _userName = 'User Name';
    _userEmail = 'user@email.com';
    _imagePath = '';
    notifyListeners();
  }

  Future<String?> verifyEmail(
    String emailInput, {
    required Function(String) onError,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Try exact match first
    String? uid = prefs.getString('uid_$emailInput');
    String? legacyEmailMatches;

    // Fallback: case-insensitive scan
    if (uid == null) {
      final allKeys = prefs.getKeys();
      for (final key in allKeys) {
        if (key.startsWith('uid_') &&
            key.toLowerCase() == 'uid_${emailInput.toLowerCase()}') {
          uid = prefs.getString(key);
          break;
        } else if (key.startsWith('password_') &&
            !key.startsWith('password_uid_') &&
            key.toLowerCase() == 'password_${emailInput.toLowerCase()}') {
          legacyEmailMatches = key.substring(9); // remove 'password_'
        }
      }
    }

    if (uid == null && legacyEmailMatches == null) {
      return null;
    }

    // Perform on-the-fly migration if it's a legacy account
    if (uid == null && legacyEmailMatches != null) {
      uid = DateTime.now().microsecondsSinceEpoch.toString();
      await prefs.setString('uid_$legacyEmailMatches', uid);
      await prefs.setString('email_$uid', legacyEmailMatches);

      final oldPass = prefs.getString('password_$legacyEmailMatches');
      if (oldPass != null) {
        await prefs.setString('password_$uid', oldPass);
      }

      String? legacyName = prefs.getString('name_$legacyEmailMatches');
      if (legacyName != null) await prefs.setString('name_$uid', legacyName);

      String? legacyImage = prefs.getString('image_$legacyEmailMatches');
      if (legacyImage != null) await prefs.setString('image_$uid', legacyImage);

      await _db.updateUserEmailInDatabase(legacyEmailMatches, uid);
    }

    return uid;
  }

  Future<bool> updatePassword(String uid, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('password_$uid', newPassword);
    return true;
  }
}
