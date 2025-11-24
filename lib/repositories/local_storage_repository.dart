import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/error_handler.dart';

/// Repository for managing local storage operations using SharedPreferences
class LocalStorageRepository {
  // Storage keys constants
  static const String USER_ID = 'user_id';
  static const String USER_EMAIL = 'user_email';
  static const String USER_ROLE = 'user_role';
  static const String USER_NAME = 'user_name';

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences instance
  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save a string value to local storage
  Future<void> saveString(String key, String value) async {
    try {
      await _ensureInitialized();
      await _prefs!.setString(key, value);
    } catch (e, stackTrace) {
      ErrorHandler.logError('LocalStorageRepository.saveString', e, stackTrace);
      rethrow;
    }
  }

  /// Get a string value from local storage
  Future<String?> getString(String key) async {
    try {
      await _ensureInitialized();
      return _prefs!.getString(key);
    } catch (e, stackTrace) {
      ErrorHandler.logError('LocalStorageRepository.getString', e, stackTrace);
      return null;
    }
  }

  /// Save an object (as JSON) to local storage
  Future<void> saveObject(String key, Map<String, dynamic> object) async {
    try {
      await _ensureInitialized();
      final jsonString = json.encode(object);
      await _prefs!.setString(key, jsonString);
    } catch (e, stackTrace) {
      ErrorHandler.logError('LocalStorageRepository.saveObject', e, stackTrace);
      rethrow;
    }
  }

  /// Get an object (from JSON) from local storage
  Future<Map<String, dynamic>?> getObject(String key) async {
    try {
      await _ensureInitialized();
      final jsonString = _prefs!.getString(key);
      if (jsonString == null) return null;

      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e, stackTrace) {
      ErrorHandler.logError('LocalStorageRepository.getObject', e, stackTrace);
      return null;
    }
  }

  /// Remove a value from local storage
  Future<void> remove(String key) async {
    try {
      await _ensureInitialized();
      await _prefs!.remove(key);
    } catch (e, stackTrace) {
      ErrorHandler.logError('LocalStorageRepository.remove', e, stackTrace);
      // Don't rethrow - best effort removal
    }
  }

  /// Clear all values from local storage
  Future<void> clear() async {
    try {
      await _ensureInitialized();
      await _prefs!.clear();
    } catch (e, stackTrace) {
      ErrorHandler.logError('LocalStorageRepository.clear', e, stackTrace);
      // Don't rethrow - best effort clear
    }
  }
}
