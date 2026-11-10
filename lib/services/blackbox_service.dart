
   import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/kasus_uji.dart';
import 'auth_service.dart';

class BlackBoxService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<List<KasusUji>> ambilKasus() async {
    final rows = await _client.from('bb_kasus').select().order('urutan');
    return rows.map<KasusUji>((m) => KasusUji.fromMap(m)).toList();
  }

  Future<Map<int, HasilUji>> ambilHasilSaya() async {
    final user = _client.auth.currentUser;
    if (user == null) return {};
    final rows =
        await _client.from('bb_hasil').select().eq('penguji_id', user.id);
    return {
      for (final m in rows) (m['kasus_id'] as int): HasilUji.fromMap(m),
    };
  }

  Future<void> simpan({
    required int kasusId,
    required String status,
    required String catatan,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthException('Sesi berakhir, masuk lagi.');
    await _client.from('bb_hasil').upsert({
      'kasus_id': kasusId,
      'penguji_id': user.id,
      'status': status,
      'catatan': catatan,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'kasus_id,penguji_id');
  }

  static String pesanError(Object e) {
    if (e is PostgrestException) return 'Gagal: ${e.message}';
    return AuthService.friendlyError(e);
  }
}
