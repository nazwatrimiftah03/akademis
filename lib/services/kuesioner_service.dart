import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pertanyaan.dart';
import 'auth_service.dart';

class KuesionerService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<bool> sudahMengisi() async {
    final user = _client.auth.currentUser;
    if (user == null) return false;
    final row = await _client
        .from('kuesioner_respons')
        .select('id')
        .eq('user_id', user.id)
        .maybeSingle();
    return row != null;
  }

  Future<List<Pertanyaan>> ambilPertanyaan({required bool staf}) async {
    final rows = await _client
        .from('kuesioner_pertanyaan')
        .select()
        .order('urutan');
    return rows
        .map<Pertanyaan>((m) => Pertanyaan.fromMap(m))
        .where((p) => staf || p.untuk == 'semua')
        .toList();
  }

  Future<void> kirim({
    required Map<int, int> nilai,
    required String komentar,
  }) async {
    await _client.rpc('kirim_kuesioner', params: {
      'p_komentar': komentar,
      'p_jawaban': [
        for (final e in nilai.entries)
          {'pertanyaan_id': e.key, 'nilai': e.value},
      ],
    });
  }

  static String pesanError(Object e) {
    if (e is PostgrestException) {
      if (e.code == '23505') {
        return 'Kamu sudah pernah mengisi kuesioner ini.';
      }
      return 'Gagal: ${e.message}';
    }
    return AuthService.friendlyError(e);
  }
}
