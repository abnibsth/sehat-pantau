import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_data.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final String _userKey = 'current_user';
  final String _isLoggedInKey = 'is_logged_in';
  final String _rememberMeKey = 'remember_me';

  // Dummy users untuk demo
  static final List<Map<String, dynamic>> _dummyUsers = [
    {
      'id': '1',
      'name': 'John Doe',
      'email': 'john@example.com',
      'password': '123456',
      'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'password': '123456',
      'createdAt': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
    },
    {
      'id': '3',
      'name': 'Admin',
      'email': 'admin@sehat.com',
      'password': 'admin123',
      'createdAt': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
    },
  ];

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<bool> isRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  Future<UserData?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    
    if (userString != null) {
      final userJson = jsonDecode(userString);
      return UserData.fromJson(userJson);
    }
    
    return null;
  }

  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    try {
      // Cari user berdasarkan email
      final user = _dummyUsers.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
        orElse: () => {},
      );

      if (user.isEmpty) {
        return false; // Login gagal
      }

      // Buat UserData object
      final userData = UserData(
        id: user['id'] as String,
        name: user['name'] as String,
        email: user['email'] as String,
        createdAt: DateTime.parse(user['createdAt'] as String),
        lastLogin: DateTime.now(),
      );

      // Simpan ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(userData.toJson()));
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setBool(_rememberMeKey, rememberMe);

      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      // Cek apakah email sudah ada
      final existingUser = _dummyUsers.any((user) => user['email'] == email);
      if (existingUser) {
        return false; // Email sudah terdaftar
      }

      // Buat user baru (dalam real app, ini akan disimpan ke database)
      final newUser = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'email': email,
        'password': password,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Simpan user baru
      final userData = UserData(
        id: newUser['id'] as String,
        name: newUser['name'] as String,
        email: newUser['email'] as String,
        createdAt: DateTime.parse(newUser['createdAt'] as String),
        lastLogin: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(userData.toJson()));
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setBool(_rememberMeKey, false);

      return true;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.setBool(_rememberMeKey, false);
  }

  Future<void> updateUser(UserData userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData.toJson()));
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) return false;

      // Cek password lama
      final user = _dummyUsers.firstWhere(
        (user) => user['email'] == currentUser.email && user['password'] == oldPassword,
        orElse: () => {},
      );

      if (user.isEmpty) {
        return false; // Password lama salah
      }

      // Update password (dalam real app, ini akan update ke database)
      user['password'] = newPassword;

      return true;
    } catch (e) {
      print('Change password error: $e');
      return false;
    }
  }
}