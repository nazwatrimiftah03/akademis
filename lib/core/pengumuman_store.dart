import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

/// Sasaran pengumuman.
const sasaranPengumuman = ['Semua', 'Siswa', 'Pengajar'];

class Pengumuman {
  Pengumuman({
    required this.id,
    required this.judul,
    required this.isi,
    required this.untuk,
    required this.waktu,
    this.penting = false,
  });

  /// id dari server. Pengumuman yang belum disimpan memakai 0.
  final int id;
  String judul;
  String isi;
  String untuk; // Semua / Siswa / Pengajar
  DateTime waktu;
  bool penting;

  /// Format untuk cache lokal.
  Map<String, dynamic> toJson() => {
    'id': id,
    'judul': judul,
    'isi': isi,
    'untuk': untuk,
    'waktu': waktu.toIso8601String(),
    'penting': penting,
  };

  /// Kolom yang dikirim ke tabel `pengumuman` di Supabase.
  Map<String, dynamic> toRow() => {
    'judul': judul,
    'isi': isi,
    'untuk': untuk,
    'penting': penting,
  };

  /// Dipakai untuk data dari server maupun dari cache.
  factory Pengumuman.fromJson(Map<String, dynamic> j) => Pengumuman(
    id: (j['id'] as num).toInt(),
    judul: j['judul'] as String,
    isi: j['isi'] as String,
    untuk: j['untuk'] as String,
    waktu: DateTime.parse(j['waktu'] as String).toLocal(),
    penting: (j['penting'] as bool?) ?? false,
  );
}

/// Error dengan pesan yang sudah siap ditampilkan ke pengguna.
class PengumumanGagal implements Exception {
  const PengumumanGagal(this.pesan);

  final String pesan;

  @override
  String toString() => pesan;
}

/// Pengumuman disimpan di Supabase (tabel `pengumuman`). Salinan terakhir
/// disimpan di HP supaya tetap tampil saat offline.
class PengumumanStore {
  static const _cacheKey = 'pengumuman_cache_v2';
  static const _kunciLama = 'pengumuman_v1'; // data contoh versi lokal

  static final ValueNotifier<List<Pengumuman>> daftar =
  ValueNotifier<List<Pengumuman>>(<Pengumuman>[]);

  static SupabaseClient get _client => Supabase.instance.client;

  static bool get _sudahLogin => _client.auth.currentSession != null;

  /// Dipanggil saat aplikasi mulai: tampilkan cache dulu, lalu segarkan
  /// dari server di latar belakang (tidak menahan start aplikasi).
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kunciLama);

    final raw = prefs.getString(_cacheKey);
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List<dynamic>)
            .map((e) => Pengumuman.fromJson(e as Map<String, dynamic>))
            .toList();
        daftar.value = _urut(list);
      } catch (_) {
        // Cache rusak: abaikan, nanti diisi ulang dari server.
      }
    }

    unawaited(segarkan());
  }

  /// Mengambil data terbaru dari server. Kalau gagal (offline, belum
  /// login), data yang sedang tampil dibiarkan.
  static Future<void> segarkan() async {
    if (!_sudahLogin) return;
    try {
      await _muat();
    } catch (_) {
      // Diam saja; tampilan tetap memakai data terakhir.
    }
  }

  static Future<void> _muat() async {
    final rows = await _client
        .from('pengumuman')
        .select()
        .order('waktu', ascending: false);

    daftar.value = _urut(
      rows.map<Pengumuman>((m) => Pengumuman.fromJson(m)).toList(),
    );
    await _simpanCache();
  }

  static List<Pengumuman> _urut(List<Pengumuman> list) {
    final hasil = [...list];
    hasil.sort((a, b) => b.waktu.compareTo(a.waktu));
    return hasil;
  }

  static Future<void> _simpanCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey,
      jsonEncode(daftar.value.map((p) => p.toJson()).toList()),
    );
  }

  /// Menghapus data di memori dan cache (dipanggil saat keluar akun).
  static Future<void> bersihkan() async {
    daftar.value = <Pengumuman>[];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }

  /// Menambah pengumuman baru. Hanya admin yang diizinkan server.
  static Future<void> tambah(Pengumuman p) async {
    await _client.from('pengumuman').insert(p.toRow());
    await _muat();
  }

  /// Mengubah pengumuman yang id-nya sama.
  static Future<void> ubah(Pengumuman p) async {
    final rows = await _client
        .from('pengumuman')
        .update(p.toRow())
        .eq('id', p.id)
        .select();
    if (rows.isEmpty) {
      throw const PengumumanGagal(
        'Perubahan tidak tersimpan. Pastikan akunmu admin yang aktif.',
      );
    }
    await _muat();
  }

  /// Menghapus pengumuman. Item langsung hilang dari daftar (supaya geser
  /// hapus terasa cepat) dan dikembalikan kalau server menolak.
  static Future<void> hapus(int id) async {
    final sebelum = daftar.value;
    daftar.value = [
      for (final x in sebelum)
        if (x.id != id) x,
    ];

    try {
      final rows =
      await _client.from('pengumuman').delete().eq('id', id).select();
      if (rows.isEmpty) {
        throw const PengumumanGagal(
          'Pengumuman tidak terhapus. Pastikan akunmu admin yang aktif.',
        );
      }
      await _simpanCache();
    } catch (_) {
      daftar.value = sebelum;
      rethrow;
    }
  }

  /// Pengumuman yang relevan untuk satu peran. Admin melihat semuanya.
  static List<Pengumuman> untukPeran(String peran) {
    return daftar.value
        .where(
          (p) => peran == 'Admin' || p.untuk == 'Semua' || p.untuk == peran,
    )
        .toList();
  }

  /// Pesan error yang ramah untuk ditampilkan.
  static String pesanError(Object e) {
    if (e is PengumumanGagal) return e.pesan;
    if (e is PostgrestException) {
      if (e.code == '42501') {
        return 'Kamu tidak punya izin. Hanya admin yang bisa mengelola pengumuman.';
      }
      if (e.code == '42P01' || e.code == 'PGRST205') {
        return 'Tabel pengumuman belum dibuat di Supabase. Jalankan file SQL-nya dulu.';
      }
      return 'Gagal: ${e.message}';
    }
    return AuthService.friendlyError(e);
  }
}

const _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

/// "Baru saja", "3 jam lalu", "Kemarin", "4 hari lalu", atau tanggal.
String waktuRelatif(DateTime waktu) {
  final selisih = DateTime.now().difference(waktu);
  if (selisih.inMinutes < 1) return 'Baru saja';
  if (selisih.inMinutes < 60) return '${selisih.inMinutes} menit lalu';
  if (selisih.inHours < 24) return '${selisih.inHours} jam lalu';
  if (selisih.inDays == 1) return 'Kemarin';
  if (selisih.inDays < 7) return '${selisih.inDays} hari lalu';
  return '${waktu.day} ${_bulan[waktu.month - 1]} ${waktu.year}';
}