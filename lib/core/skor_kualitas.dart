/// Perhitungan skor kualitas gabungan (kuesioner + black box testing)
/// per karakteristik ISO/IEC 25010, beserta rekomendasi otomatis.
///
/// Murni Dart (tanpa Flutter/Supabase) supaya mudah diuji dan dijelaskan
/// di bab metodologi skripsi.
library;

/// Bobot tiap sumber data. Kalau salah satu sumber kosong untuk sebuah
/// karakteristik, sumber yang ada otomatis dipakai 100%.
const double kBobotKuesioner = 0.5;
const double kBobotBlackBox = 0.5;

/// Selisih skor kuesioner vs black box yang dianggap tidak konsisten.
const double kBatasSelisih = 20;

/// Interpretasi skala Likert 5 interval (persentase).
String kategoriSkor(double persen) {
  if (persen > 80) return 'Sangat baik';
  if (persen > 60) return 'Baik';
  if (persen > 40) return 'Cukup';
  if (persen > 20) return 'Kurang';
  return 'Sangat kurang';
}

/// Masukan mentah per karakteristik.
class DataKarakteristik {
  DataKarakteristik(this.nama);

  final String nama;
  int jumlahJawaban = 0;
  int totalNilai = 0; // jumlah nilai Likert 1-5
  int berhasil = 0;
  int gagal = 0;

  void tambahJawaban(int nilai) {
    jumlahJawaban++;
    totalNilai += nilai;
  }

  void tambahHasil(String status) {
    final s = status.toLowerCase();
    if (s == 'berhasil') berhasil++;
    if (s == 'gagal') gagal++;
  }
}

class SkorKarakteristik {
  const SkorKarakteristik({
    required this.nama,
    required this.skorKuesioner,
    required this.skorBlackBox,
    required this.skorAkhir,
    required this.jumlahJawaban,
    required this.berhasil,
    required this.gagal,
    required this.rekomendasi,
  });

  final String nama;

  /// 0-100, null kalau belum ada jawaban kuesioner.
  final double? skorKuesioner;

  /// 0-100, null kalau belum ada kasus uji yang dinilai.
  final double? skorBlackBox;

  /// 0-100, null kalau kedua sumber kosong.
  final double? skorAkhir;

  final int jumlahJawaban;
  final int berhasil;
  final int gagal;
  final List<String> rekomendasi;

  String get kategori =>
      skorAkhir == null ? 'Belum ada data' : kategoriSkor(skorAkhir!);
}

class HasilEvaluasi {
  const HasilEvaluasi({
    required this.karakteristik,
    required this.skorKeseluruhan,
  });

  /// Diurutkan dari skor terendah (prioritas perbaikan) ke tertinggi.
  /// Karakteristik tanpa data ada di paling akhir.
  final List<SkorKarakteristik> karakteristik;

  /// Rata-rata skor akhir seluruh karakteristik yang punya data.
  final double? skorKeseluruhan;

  String get kategoriKeseluruhan => skorKeseluruhan == null
      ? 'Belum ada data'
      : kategoriSkor(skorKeseluruhan!);

  List<SkorKarakteristik> get prioritas => karakteristik
      .where((k) => k.skorAkhir != null && k.skorAkhir! <= 60)
      .toList();
}

/// Hitung hasil evaluasi dari data mentah.
HasilEvaluasi hitungEvaluasi(Iterable<DataKarakteristik> data) {
  final hasil = <SkorKarakteristik>[];

  for (final d in data) {
    final adaKuesioner = d.jumlahJawaban > 0;
    final dinilai = d.berhasil + d.gagal;
    final adaBlackBox = dinilai > 0;

    final double? sk =
    adaKuesioner ? (d.totalNilai / d.jumlahJawaban) / 5 * 100 : null;
    final double? sb = adaBlackBox ? d.berhasil / dinilai * 100 : null;

    double? akhir;
    if (sk != null && sb != null) {
      akhir = sk * kBobotKuesioner + sb * kBobotBlackBox;
    } else {
      akhir = sk ?? sb;
    }

    hasil.add(
      SkorKarakteristik(
        nama: d.nama,
        skorKuesioner: sk,
        skorBlackBox: sb,
        skorAkhir: akhir,
        jumlahJawaban: d.jumlahJawaban,
        berhasil: d.berhasil,
        gagal: d.gagal,
        rekomendasi: _susunRekomendasi(d.nama, sk, sb, akhir, d.gagal),
      ),
    );
  }

  hasil.sort((a, b) {
    if (a.skorAkhir == null && b.skorAkhir == null) {
      return a.nama.compareTo(b.nama);
    }
    if (a.skorAkhir == null) return 1;
    if (b.skorAkhir == null) return -1;
    return a.skorAkhir!.compareTo(b.skorAkhir!);
  });

  final berdata = hasil.where((k) => k.skorAkhir != null).toList();
  final keseluruhan = berdata.isEmpty
      ? null
      : berdata.map((k) => k.skorAkhir!).reduce((a, b) => a + b) /
      berdata.length;

  return HasilEvaluasi(karakteristik: hasil, skorKeseluruhan: keseluruhan);
}

List<String> _susunRekomendasi(
    String nama,
    double? sk,
    double? sb,
    double? akhir,
    int gagal,
    ) {
  if (akhir == null) {
    return [
      'Belum ada data untuk $nama. Isi kuesioner dan jalankan black box '
          'testing terlebih dahulu.',
    ];
  }

  final out = <String>[];

  if (akhir > 80) {
    out.add('Kualitas $nama sudah sangat baik. Pertahankan dan lakukan '
        'pemantauan berkala.');
  } else if (akhir > 60) {
    out.add('Kualitas $nama baik, tetapi masih ada ruang perbaikan.');
    out.add(_saranKhusus(nama));
  } else {
    out.add('$nama perlu diprioritaskan untuk perbaikan '
        '(skor ${akhir.toStringAsFixed(1)}%).');
    out.add(_saranKhusus(nama));
  }

  if (gagal > 0) {
    out.add('Terdapat $gagal kasus uji yang gagal. Tinjau catatan pengujian, '
        'perbaiki, lalu uji ulang.');
  }

  if (sk != null && sb != null && (sk - sb).abs() >= kBatasSelisih) {
    out.add(sk > sb
        ? 'Persepsi pengguna lebih baik daripada hasil pengujian. Ada cacat '
        'teknis yang belum terasa oleh pengguna.'
        : 'Hasil pengujian lebih baik daripada persepsi pengguna. Periksa '
        'kenyamanan penggunaan dan kejelasan fitur.');
  }

  return out;
}

/// Saran spesifik berdasarkan kata kunci nama karakteristik
/// (mendukung penamaan Indonesia maupun Inggris).
String _saranKhusus(String nama) {
  final n = nama.toLowerCase();

  bool ada(List<String> kata) => kata.any(n.contains);

  if (ada(['fungsional', 'functional'])) {
    return 'Lengkapi fitur yang belum sesuai kebutuhan sekolah dan pastikan '
        'hasil setiap fungsi (nilai, absensi, jadwal) benar.';
  }
  if (ada(['kinerja', 'performa', 'performance', 'efisiensi'])) {
    return 'Percepat waktu muat data, batasi jumlah data per permintaan, '
        'dan optimalkan query.';
  }
  if (ada(['kompatibilitas', 'compatibility'])) {
    return 'Uji pada berbagai versi Android dan ukuran layar, serta pastikan '
        'pertukaran data antarmodul konsisten.';
  }
  if (ada(['kebergunaan', 'usability', 'interaksi', 'interaction'])) {
    return 'Sederhanakan alur, perjelas label dan pesan kesalahan, serta '
        'rapikan tata letak layar yang membingungkan.';
  }
  if (ada(['keandalan', 'reliability', 'kehandalan'])) {
    return 'Tambahkan penanganan error dan koneksi terputus, serta pastikan '
        'aplikasi tidak berhenti mendadak.';
  }
  if (ada(['keamanan', 'security'])) {
    return 'Perketat hak akses per peran, validasi input, dan kebijakan RLS '
        'pada basis data.';
  }
  if (ada(['pemeliharaan', 'maintainability', 'perawatan'])) {
    return 'Rapikan struktur kode, pisahkan logika dari tampilan, dan '
        'tambahkan dokumentasi serta pengujian otomatis.';
  }
  if (ada(['portabilitas', 'portability'])) {
    return 'Pastikan aplikasi dapat dipasang dan berjalan konsisten di '
        'berbagai perangkat dan versi sistem operasi.';
  }
  return 'Tinjau pertanyaan kuesioner dan kasus uji terkait, lalu lakukan '
      'perbaikan fitur yang relevan.';
}