import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserId = 'userId';
  static const String _keyUserEmail = 'userEmail';

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static late final SharedPreferences _prefs;

  // Initialize shared preferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save user data after successful login
  static Future<void> saveUserData(User user) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, user.uid);
    await _prefs.setString(_keyUserEmail, user.email ?? '');
  }

  // Clear user data on logout
  static Future<void> clearUserData() async {
    await _prefs.clear();
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Get saved user ID
  static String? getUserId() {
    return _prefs.getString(_keyUserId);
  }

  // Get saved user email
  static String? getUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }
}
