import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static SupabaseClient get client => Supabase.instance.client;

  // Helper untuk mendapatkan user ID saat ini
  String? get currentUserId => client.auth.currentUser?.id;

  // Helper untuk memastikan user sudah login
  void ensureAuthenticated() {
    if (currentUserId == null) {
      throw Exception('User belum login');
    }
  }

  // Helper untuk error handling
  Future<T> handleDatabaseOperation<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

