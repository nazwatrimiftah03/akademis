import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_profile.dart';

class AuthService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'role': role},
    );
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<void> updateNama(String nama) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client
        .from('profiles')
        .update({'full_name': nama})
        .eq('id', user.id);
  }

  Future<AppProfile?> fetchProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (row == null) return null;
    return AppProfile.fromMap(row);
  }

  /// Mengubah error teknis menjadi pesan yang mudah dipahami.
  static String friendlyError(Object error) {
    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('invalid login credentials')) {
        return 'Email atau kata sandi salah.';
      }
      if (msg.contains('already registered') ||
          msg.contains('already been registered')) {
        return 'Email ini sudah terdaftar. Silakan masuk.';
      }
      if (msg.contains('email not confirmed')) {
        return 'Email belum dikonfirmasi. Cek kotak masuk emailmu.';
      }
      if (msg.contains('rate limit')) {
        return 'Terlalu banyak percobaan. Coba lagi beberapa saat lagi.';
      }
      if (msg.contains('password')) {
        return 'Kata sandi tidak memenuhi syarat (minimal 6 karakter).';
      }
      return error.message;
    }

    final text = error.toString();
    if (text.contains('SocketException') ||
        text.contains('Failed host lookup') ||
        text.contains('ClientException')) {
      return 'Tidak ada koneksi internet.';
    }
    return 'Terjadi kesalahan. Coba lagi.';
  }
}