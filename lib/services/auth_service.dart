import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_data.dart';
import 'supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final String _userKey = 'current_user';
  final String _isLoggedInKey = 'is_logged_in';
  final String _rememberMeKey = 'remember_me';
  
  SupabaseClient get _supabase => SupabaseService.client;


  Future<bool> isLoggedIn() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        // Update last login di profil
        await _updateLastLogin();
        return true;
      }
      return false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }
  
  Future<void> _updateLastLogin() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        await _supabase
            .from('user_profiles')
            .update({'last_login': DateTime.now().toIso8601String()})
            .eq('id', userId);
      }
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  Future<bool> isRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  Future<UserData?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      
      // Ambil data profil dari database
      try {
        final response = await _supabase
            .from('user_profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle(); // Gunakan maybeSingle karena mungkin belum ada
        
        if (response != null) {
          return UserData(
            id: response['id'],
            name: response['name'] ?? user.email ?? 'User',
            email: user.email ?? '',
            photoUrl: response['photo_url'],
            createdAt: DateTime.parse(response['created_at']),
            lastLogin: response['last_login'] != null 
                ? DateTime.parse(response['last_login']) 
                : null,
            preferences: response['preferences'] != null 
                ? Map<String, dynamic>.from(response['preferences']) 
                : null,
          );
        }
        
        // Jika profil belum ada, coba buat sekarang
        print('Profile not found for user ${user.id}, creating now...');
        await _ensureUserProfile(user);
        
        // Coba ambil lagi
        final response2 = await _supabase
            .from('user_profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        
        if (response2 != null) {
          return UserData(
            id: response2['id'],
            name: response2['name'] ?? user.email ?? 'User',
            email: user.email ?? '',
            photoUrl: response2['photo_url'],
            createdAt: DateTime.parse(response2['created_at']),
            lastLogin: response2['last_login'] != null 
                ? DateTime.parse(response2['last_login']) 
                : null,
            preferences: response2['preferences'] != null 
                ? Map<String, dynamic>.from(response2['preferences']) 
                : null,
          );
        }
        
        // Fallback: return user data dari auth saja
        return UserData(
          id: user.id,
          name: user.userMetadata?['name'] ?? user.email?.split('@')[0] ?? 'User',
          email: user.email ?? '',
          createdAt: DateTime.parse(user.createdAt),
          lastLogin: DateTime.now(),
        );
      } catch (e) {
        print('Error getting profile, using auth data: $e');
        // Fallback: return user data dari auth saja
        return UserData(
          id: user.id,
          name: user.userMetadata?['name'] ?? user.email?.split('@')[0] ?? 'User',
          email: user.email ?? '',
          createdAt: DateTime.parse(user.createdAt),
          lastLogin: DateTime.now(),
        );
      }
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    try {
      print('Attempting login for: $email');
      
      // Login dengan Supabase Auth
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      print('Login response received');
      
      if (response.user != null) {
        print('User logged in: ${response.user!.id}');
        
        // Simpan preferensi remember me
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_rememberMeKey, rememberMe);
        
        // Buat atau update profil user
        await _ensureUserProfile(response.user!);
        
        // Update last login
        await _updateLastLogin();
        
        return true;
      }
      
      print('Login failed: user is null');
      return false;
    } catch (e) {
      print('Login error: $e');
      print('Error type: ${e.runtimeType}');
      rethrow; // Re-throw agar bisa ditangkap di UI untuk error message yang lebih jelas
    }
  }
  
  Future<void> _ensureUserProfile(User user) async {
    try {
      // Cek apakah profil sudah ada (mungkin sudah dibuat oleh trigger)
      final existing = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      
      if (existing == null) {
        // Coba buat profil baru
        // Catatan: Jika trigger sudah bekerja, ini mungkin tidak diperlukan
        final name = user.userMetadata?['name'] ?? 
                    user.email?.split('@')[0] ?? 
                    'User';
        
        print('Creating user profile for: $name (${user.id})');
        
        try {
          final result = await _supabase.from('user_profiles').insert({
            'id': user.id,
            'name': name,
            'photo_url': null,
            'preferences': {},
            'created_at': DateTime.now().toIso8601String(),
            'last_login': DateTime.now().toIso8601String(),
          }).select();
          
          print('User profile created: $result');
        } catch (insertError) {
          print('Insert failed, checking if profile exists now: $insertError');
          // Mungkin trigger sudah membuatnya, cek lagi
          final checkAgain = await _supabase
              .from('user_profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle();
          
          if (checkAgain == null) {
            print('Profile still does not exist after insert attempt');
            // Profile masih belum ada, tapi kita skip error agar registrasi tetap berhasil
            // Trigger akan membuatnya nanti atau saat user login pertama kali
          } else {
            print('Profile exists now (probably created by trigger)');
          }
        }
      } else {
        print('User profile already exists');
      }
    } catch (e) {
      print('Error ensuring user profile: $e');
      print('Error details: ${e.toString()}');
      // Jangan rethrow, biarkan registrasi tetap berhasil
      // Trigger di database akan handle pembuatan profil
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      print('Starting registration for: $email');
      
      // Register dengan Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
        },
      );
      
      print('Auth signup response: ${response.user?.id}');
      
      if (response.user != null) {
        print('User created, now creating profile...');
        
        // Buat profil user
        // Catatan: Trigger di database akan auto-create profil
        // Tapi kita coba juga create manual sebagai backup
        await _ensureUserProfile(response.user!);
        
        // Tunggu sebentar untuk memastikan trigger sudah jalan (jika ada)
        await Future.delayed(const Duration(milliseconds: 500));
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_rememberMeKey, false);
        
        return true;
      }
      
      print('Registration failed: user is null');
      return false;
    } catch (e) {
      print('Register error: $e');
      print('Error type: ${e.runtimeType}');
      rethrow; // Re-throw agar bisa ditampilkan di UI
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.setBool(_isLoggedInKey, false);
      await prefs.setBool(_rememberMeKey, false);
    } catch (e) {
      print('Logout error: $e');
    }
  }

  Future<void> updateUser(UserData userData) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      
      await _supabase
          .from('user_profiles')
          .update({
            'name': userData.name,
            'photo_url': userData.photoUrl,
            'preferences': userData.preferences ?? {},
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      // Supabase memerlukan password lama untuk update
      // Kita perlu verify password dulu, lalu update
      final user = _supabase.auth.currentUser;
      if (user == null) return false;
      
      // Update password dengan Supabase
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      
      return true;
    } catch (e) {
      print('Change password error: $e');
      return false;
    }
  }
}