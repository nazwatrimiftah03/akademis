import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_theme.dart';
import '../../core/laporan_pdf.dart';
import '../../core/skor_kualitas.dart';

class _Aspek {
  const _Aspek({
    required this.nama,
    required this.rata,
    required this.jumlah,
  });

  final String nama;
  final double rata;
  final int jumlah;
}

class _Komentar {
  const _Komentar({required this.isi, required this.tanggal});

  final String isi;
  final String tanggal;
}

class _LaporanData {
  const _LaporanData({
    required this.aspek,
    required this.jumlahResponden,
    required this.rataKeseluruhan,
    required this.komentar,
    required this.totalKasus,
    required this.berhasil,
    required this.gagal,
    required this.evaluasi,
  });

  final HasilEvaluasi evaluasi;
  final List<_Aspek> aspek;
  final int jumlahResponden;
  final double rataKeseluruhan;
  final List<_Komentar> komentar;
  final int totalKasus;
  final int berhasil;
  final int gagal;
}

String _predikat(double nilai) {
  if (nilai == 0) return 'Belum ada data';
  if (nilai >= 4.5) return 'Sangat baik';
  if (nilai >= 3.5) return 'Baik';
  if (nilai >= 2.5) return 'Cukup';
  if (nilai >= 1.5) return 'Kurang';
  return 'Sangat kurang';
}

Color _warna(double nilai) {
  if (nilai >= 4.0) return const Color(0xFF16A34A);
  if (nilai >= 3.0) return AppColors.teal;
  return const Color(0xFFD97706);
}

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  late Future<_LaporanData> _laporanFuture;
  _LaporanData? _terakhir;

  SupabaseClient get _client => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _laporanFuture = _ambilLaporan();
  }

  Future<void> _muatUlang() async {
    setState(() {
      _laporanFuture = _ambilLaporan();
    });
    await _laporanFuture;
  }

  Future<_LaporanData> _ambilLaporan() async {
    // Ambil respons kuesioner yang benar-benar tersimpan.
    final responsRaw = await _client
        .from('kuesioner_respons')
        .select('id, komentar, created_at')
        .order('created_at', ascending: false);

    final respons = List<Map<String, dynamic>>.from(responsRaw);

    // Ambil daftar pertanyaan beserta karakteristik ISO.
    final pertanyaanRaw = await _client
        .from('kuesioner_pertanyaan')
        .select('id, karakteristik, pertanyaan, urutan')
        .order('urutan');

    final pertanyaan = List<Map<String, dynamic>>.from(pertanyaanRaw);

    // Ambil seluruh jawaban kuesioner.
    final jawabanRaw = await _client
        .from('kuesioner_jawaban')
        .select('respons_id, pertanyaan_id, nilai');

    final jawaban = List<Map<String, dynamic>>.from(jawabanRaw);

    final karakteristikPertanyaan = <int, String>{};
    for (final p in pertanyaan) {
      karakteristikPertanyaan[p['id'] as int] =
          (p['karakteristik'] ?? 'Lainnya').toString();
    }

    // Data mentah per karakteristik untuk skor gabungan.
    // Kunci disamakan (huruf kecil, tanpa spasi tepi) agar kuesioner
    // dan black box tetap tergabung walau penulisannya sedikit beda.
    final mentah = <String, DataKarakteristik>{};
    DataKarakteristik ambilMentah(String nama) =>
        mentah.putIfAbsent(
          nama.trim().toLowerCase(),
              () => DataKarakteristik(nama.trim()),
        );

    final jumlahNilai = <String, int>{};
    final totalNilai = <String, int>{};
    var seluruhNilai = 0;
    var jumlahSeluruhJawaban = 0;

    for (final j in jawaban) {
      final idPertanyaan = j['pertanyaan_id'] as int;
      final nilai = j['nilai'] as int;
      final karakteristik =
      karakteristikPertanyaan[idPertanyaan];

      if (karakteristik == null) continue;

      jumlahNilai[karakteristik] =
          (jumlahNilai[karakteristik] ?? 0) + 1;
      totalNilai[karakteristik] =
          (totalNilai[karakteristik] ?? 0) + nilai;

      ambilMentah(karakteristik).tambahJawaban(nilai);
      seluruhNilai += nilai;
      jumlahSeluruhJawaban++;
    }

    final aspek = <_Aspek>[];
    for (final nama in totalNilai.keys) {
      final jumlah = jumlahNilai[nama] ?? 0;
      aspek.add(
        _Aspek(
          nama: nama,
          rata: jumlah == 0 ? 0 : totalNilai[nama]! / jumlah,
          jumlah: jumlah,
        ),
      );
    }

    aspek.sort((a, b) => a.nama.compareTo(b.nama));

    // Komentar diambil dari respons asli, bukan komentar contoh.
    final komentar = <_Komentar>[];
    for (final r in respons) {
      final isi = (r['komentar'] ?? '').toString().trim();
      if (isi.isEmpty) continue;

      final tanggalRaw = r['created_at']?.toString();
      var tanggal = 'Tanggal tidak tersedia';

      if (tanggalRaw != null) {
        final parsed = DateTime.tryParse(tanggalRaw);
        if (parsed != null) {
          tanggal =
          '${parsed.day.toString().padLeft(2, '0')}/'
              '${parsed.month.toString().padLeft(2, '0')}/'
              '${parsed.year}';
        }
      }

      komentar.add(_Komentar(isi: isi, tanggal: tanggal));
      if (komentar.length == 5) break;
    }

    // Ambil kasus pengujian dan hasil yang tersimpan.
    final kasusRaw = await _client
        .from('bb_kasus')
        .select('id, karakteristik');

    final hasilRaw = await _client
        .from('bb_hasil')
        .select('kasus_id, status');

    final kasus = List<Map<String, dynamic>>.from(kasusRaw);
    final hasil = List<Map<String, dynamic>>.from(hasilRaw);

    final idKasusValid = kasus
        .map((k) => k['id'] as int)
        .toSet();

    final karakteristikKasus = <int, String>{
      for (final k in kasus)
        k['id'] as int: (k['karakteristik'] ?? 'Lainnya').toString(),
    };

    // Pastikan karakteristik yang baru punya kasus uji tetap muncul.
    for (final nama in karakteristikKasus.values) {
      ambilMentah(nama);
    }

    var berhasil = 0;
    var gagal = 0;

    for (final h in hasil) {
      if (!idKasusValid.contains(h['kasus_id'])) continue;

      final status = (h['status'] ?? '').toString().toLowerCase();
      ambilMentah(karakteristikKasus[h['kasus_id']] ?? 'Lainnya')
          .tambahHasil(status);
      if (status == 'berhasil') {
        berhasil++;
      } else if (status == 'gagal') {
        gagal++;
      }
    }

    final hasilAkhir = _LaporanData(
      aspek: aspek,
      jumlahResponden: respons.length,
      rataKeseluruhan: jumlahSeluruhJawaban == 0
          ? 0
          : seluruhNilai / jumlahSeluruhJawaban,
      komentar: komentar,
      totalKasus: kasus.length,
      berhasil: berhasil,
      gagal: gagal,
      evaluasi: hitungEvaluasi(mentah.values),
    );
    _terakhir = hasilAkhir;
    return hasilAkhir;
  }

  Future<void> _cetakPdf() async {
    final d = _terakhir;
    if (d == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan belum selesai dimuat')),
      );
      return;
    }
    try {
      final bytes = await buatLaporanPdf(
        evaluasi: d.evaluasi,
        responden: d.jumlahResponden,
        totalKasus: d.totalKasus,
        berhasil: d.berhasil,
        gagal: d.gagal,
        komentar: d.komentar.map((k) => k.isi).toList(),
      );
      await tampilkanLaporanPdf(bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
    dark ? const Color(0xFF16231F) : Colors.white;

    Widget judul(String teks) => Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        teks,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );

    Widget statTile(String nilai, String label, IconData ikon) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 6,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Icon(ikon, color: AppColors.teal, size: 22),
              const SizedBox(height: 6),
              Text(
                nilai,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: AppColors.teal,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan & Evaluasi'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            onPressed: _cetakPdf,
            tooltip: 'Ekspor PDF',
            icon: const Icon(Icons.picture_as_pdf_rounded),
          ),
          IconButton(
            onPressed: _muatUlang,
            tooltip: 'Muat ulang laporan',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<_LaporanData>(
        future: _laporanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.teal,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 48,
                      color: Color(0xFFD97706),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Laporan belum dapat dimuat',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _muatUlang,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final aspek = data.aspek;
          final rata = data.rataKeseluruhan;

          return RefreshIndicator(
            onRefresh: _muatUlang,
            color: AppColors.teal,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              children: [
                Row(
                  children: [
                    statTile(
                      '${data.jumlahResponden}',
                      'Responden',
                      Icons.people_alt_rounded,
                    ),
                    const SizedBox(width: 10),
                    statTile(
                      '${data.berhasil}',
                      'Uji berhasil',
                      Icons.check_circle_outline_rounded,
                    ),
                    const SizedBox(width: 10),
                    statTile(
                      '${data.gagal}',
                      'Uji gagal',
                      Icons.error_outline_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.teal,
                        AppColors.tealLight,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kualitas sistem akademik',
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${rata.toStringAsFixed(2)} / 5',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_predikat(rata)} • '
                                  '${data.jumlahResponden} responden',
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.insights_rounded,
                        size: 48,
                        color: Colors.white54,
                      ),
                    ],
                  ),
                ),
                judul('Penilaian ISO/IEC 25010'),
                if (aspek.isEmpty)
                  _pesanKosong(
                    cardColor,
                    'Belum ada jawaban kuesioner yang dapat dihitung.',
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        for (final a in aspek)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 9,
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        a.nama,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      a.rata.toStringAsFixed(2),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: _warna(a.rata),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: (a.rata / 5)
                                        .clamp(0.0, 1.0),
                                    minHeight: 8,
                                    backgroundColor:
                                    _warna(a.rata).withValues(
                                      alpha: 0.15,
                                    ),
                                    color: _warna(a.rata),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_predikat(a.rata)} • '
                                      '${a.jumlah} jawaban',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                judul('Hasil Black Box Testing'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text('Total kasus uji'),
                          ),
                          Text(
                            '${data.totalKasus}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Expanded(
                            child: Text('Hasil pengujian tersimpan'),
                          ),
                          Text(
                            '${data.berhasil + data.gagal}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          minHeight: 9,
                          value: data.berhasil + data.gagal == 0
                              ? 0
                              : data.berhasil /
                              (data.berhasil + data.gagal),
                          color: const Color(0xFF16A34A),
                          backgroundColor:
                          const Color(0xFFD97706)
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        data.berhasil + data.gagal == 0
                            ? 'Belum ada hasil pengujian.'
                            : 'Keberhasilan pengujian: '
                            '${(data.berhasil * 100 / (data.berhasil + data.gagal)).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Kasus uji yang belum memiliki hasil '
                            'tidak dihitung sebagai berhasil atau gagal.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                ..._bagianEvaluasi(data.evaluasi, cardColor, judul),
                judul('Komentar terbaru'),
                if (data.komentar.isEmpty)
                  _pesanKosong(
                    cardColor,
                    'Belum ada komentar yang diisi responden.',
                  )
                else
                  for (final k in data.komentar)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            k.tanggal,
                            style: const TextStyle(
                              color: AppColors.teal,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            k.isi,
                            style: const TextStyle(height: 1.4),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _warnaSkor(double? skor) {
    if (skor == null) return AppColors.muted;
    if (skor > 80) return const Color(0xFF16A34A);
    if (skor > 60) return AppColors.teal;
    if (skor > 40) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  String _persen(double? v) =>
      v == null ? '-' : '${v.toStringAsFixed(1)}%';

  /// Skor gabungan kuesioner + black box, lengkap dengan rekomendasi.
  List<Widget> _bagianEvaluasi(
      HasilEvaluasi e,
      Color cardColor,
      Widget Function(String) judul,
      ) {
    final warnaTotal = _warnaSkor(e.skorKeseluruhan);

    return [
      judul('Skor kualitas gabungan'),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: warnaTotal.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Text(
              _persen(e.skorKeseluruhan),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: warnaTotal,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.kategoriKeseluruhan,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: warnaTotal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Kuesioner ${(kBobotKuesioner * 100).round()}% + '
                        'black box ${(kBobotBlackBox * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      judul('Rekomendasi per karakteristik'),
      if (e.karakteristik.isEmpty)
        _pesanKosong(
          cardColor,
          'Belum ada data. Isi kuesioner dan jalankan black box testing '
              'terlebih dahulu.',
        )
      else
        for (final k in e.karakteristik)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(color: _warnaSkor(k.skorAkhir), width: 4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        k.nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                    Text(
                      '${_persen(k.skorAkhir)} · ${k.kategori}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _warnaSkor(k.skorAkhir),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Kuesioner ${_persen(k.skorKuesioner)} '
                      '(${k.jumlahJawaban} jawaban) · '
                      'Black box ${_persen(k.skorBlackBox)} '
                      '(${k.berhasil} berhasil, ${k.gagal} gagal)',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.muted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                for (final r in k.rekomendasi)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.tips_and_updates_rounded,
                            size: 14,
                            color: Color(0xFFD97706),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            r,
                            style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
    ];
  }

  Widget _pesanKosong(Color warna, String pesan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warna,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        pesan,
        style: const TextStyle(
          color: AppColors.muted,
          height: 1.4,
        ),
      ),
    );
  }
}