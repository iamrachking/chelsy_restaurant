import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:chelsy_restaurant/core/constants/app_constants.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Token Management
  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.keyToken, token);
    AppLogger.debug('Token saved');
  }

  String? getToken() {
    return _prefs.getString(AppConstants.keyToken);
  }

  Future<void> removeToken() async {
    await _prefs.remove(AppConstants.keyToken);
    AppLogger.debug('Token removed');
  }

  // User Data
  Future<void> saveUser(Map<String, dynamic> userData) async {
    await _prefs.setString(AppConstants.keyUser, jsonEncode(userData));
    AppLogger.debug('User data saved');
  }

  Map<String, dynamic>? getUser() {
    final userString = _prefs.getString(AppConstants.keyUser);
    if (userString != null) {
      return jsonDecode(userString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> removeUser() async {
    await _prefs.remove(AppConstants.keyUser);
    AppLogger.debug('User data removed');
  }

  // FCM Token
  Future<void> saveFcmToken(String token) async {
    await _prefs.setString(AppConstants.keyFcmToken, token);
    AppLogger.debug('FCM token saved');
  }

  String? getFcmToken() {
    return _prefs.getString(AppConstants.keyFcmToken);
  }

  Future<void> removeFcmToken() async {
    await _prefs.remove(AppConstants.keyFcmToken);
    AppLogger.debug('FCM token removed');
  }

  // Login Status
  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(AppConstants.keyIsLoggedIn, value);
  }

  bool isLoggedIn() {
    return _prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  // Language
  Future<void> saveLanguage(String language) async {
    await _prefs.setString(AppConstants.keyLanguage, language);
  }

  String getLanguage() {
    return _prefs.getString(AppConstants.keyLanguage) ?? 'fr';
  }

  // Theme
  Future<void> saveTheme(String theme) async {
    await _prefs.setString(AppConstants.keyTheme, theme);
  }

  String getTheme() {
    return _prefs.getString(AppConstants.keyTheme) ?? 'light';
  }

  // Onboarding
  Future<void> setOnboardingSeen(bool value) async {
    await _prefs.setBool(AppConstants.keyHasSeenOnboarding, value);
  }

  bool hasSeenOnboarding() {
    return _prefs.getBool(AppConstants.keyHasSeenOnboarding) ?? false;
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
    AppLogger.debug('All storage cleared');
  }
}

