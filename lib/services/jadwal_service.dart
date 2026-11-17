import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/jadwal.dart';

class JadwalService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<List<Jadwal>> ambilSemua() async {
    final rows = await _client.from('jadwal').select().order('jam');
    return (rows as List)
        .map((e) => Jadwal.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> tambah(Jadwal j) async {
    await _client.from('jadwal').insert(j.toMap());
  }

  Future<void> ubah(int id, Jadwal j) async {
    // .select() supaya kelihatan kalau RLS menolak (hasilnya kosong).
    final rows =
    await _client.from('jadwal').update(j.toMap()).eq('id', id).select();
    if ((rows as List).isEmpty) {
      throw const PostgrestException(
        message: 'Tidak punya izin mengubah jadwal ini',
        code: 'rls',
      );
    }
  }

  Future<void> hapus(int id) async {
    await _client.from('jadwal').delete().eq('id', id);
  }

  /// Nama semua pengajar aktif untuk pilihan di form admin.
  /// Kalau gagal dibaca (misalnya terhalang RLS), kembalikan daftar kosong.
  Future<List<String>> daftarPengajar() async {
    try {
      final rows = await _client
          .from('profiles')
          .select('full_name')
          .eq('role', 'pengajar')
          .eq('aktif', true)
          .order('full_name');
      return (rows as List)
          .map((e) => ((e as Map)['full_name'] as String?)?.trim() ?? '')
          .where((n) => n.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static String friendlyError(Object error) {
    if (error is PostgrestException) {
      final teks = '${error.message} ${error.details ?? ''}'.toLowerCase();
      if (error.code == '23505') {
        if (teks.contains('kelas')) {
          return 'Kelas tersebut sudah punya pelajaran di jam ini.';
        }
        if (teks.contains('guru')) {
          return 'Pengajar tersebut sudah mengajar di jam ini.';
        }
        if (teks.contains('ruang')) {
          return 'Ruang tersebut sudah dipakai di jam ini.';
        }
        return 'Jadwal bentrok dengan jadwal lain.';
      }
      if (error.code == '42P01') {
        return 'Tabel jadwal belum dibuat di Supabase. Jalankan jadwal.sql dulu.';
      }
      if (error.code == '42501' || error.code == 'rls') {
        return 'Kamu tidak punya izin untuk aksi ini.';
      }
    }
    final teks = error.toString();
    if (teks.contains('SocketException') ||
        teks.contains('Failed host lookup') ||
        teks.contains('ClientException')) {
      return 'Tidak ada koneksi internet.';
    }
    return 'Terjadi kesalahan. Coba lagi.';
  }
}