import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/pertanyaan.dart';
import '../../services/kuesioner_service.dart';

enum _Status { memuat, siapIsi, sudahIsi, terkirim, gagal }

const _ikon = <String, IconData>{
  'Functional Suitability': Icons.fact_check_rounded,
  'Performance Efficiency': Icons.speed_rounded,
  'Compatibility': Icons.devices_rounded,
  'Usability': Icons.touch_app_rounded,
  'Reliability': Icons.verified_user_rounded,
  'Security': Icons.lock_rounded,
  'Maintainability': Icons.build_rounded,
  'Portability': Icons.swap_horiz_rounded,
};

const _penjelasan = <String, String>{
  'Functional Suitability': 'Kelengkapan dan ketepatan fitur',
  'Performance Efficiency': 'Kecepatan aplikasi',
  'Compatibility': 'Kesesuaian dengan perangkat',
  'Usability': 'Kemudahan dan kenyamanan pemakaian',
  'Reliability': 'Kestabilan dan keandalan',
  'Security': 'Keamanan akun dan data',
  'Maintainability': 'Kemudahan perawatan dan perbaikan',
  'Portability': 'Kemudahan dipasang dan dipindahkan',
};

class KuesionerScreen extends StatefulWidget {
  const KuesionerScreen({super.key, required this.staf});

  /// true untuk pengajar (24 pertanyaan), false untuk siswa (18 pertanyaan).
  final bool staf;

  @override
  State<KuesionerScreen> createState() => _KuesionerScreenState();
}

class _KuesionerScreenState extends State<KuesionerScreen> {
  final _service = KuesionerService();
  final _komentarC = TextEditingController();
  final Map<int, int> _nilai = {};

  List<Pertanyaan> _daftar = [];
  _Status _status = _Status.memuat;
  String _pesanGagal = '';
  bool _mengirim = false;

  bool get _lengkap => _daftar.isNotEmpty && _nilai.length == _daftar.length;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  @override
  void dispose() {
    _komentarC.dispose();
    super.dispose();
  }

  Future<void> _muat() async {
    setState(() => _status = _Status.memuat);
    try {
      if (await _service.sudahMengisi()) {
        if (!mounted) return;
        setState(() => _status = _Status.sudahIsi);
        return;
      }
      final data = await _service.ambilPertanyaan(staf: widget.staf);
      if (!mounted) return;
      setState(() {
        _daftar = data;
        _status = _Status.siapIsi;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pesanGagal = KuesionerService.pesanError(e);
        _status = _Status.gagal;
      });
    }
  }

  Future<void> _kirim() async {
    setState(() => _mengirim = true);
    try {
      await _service.kirim(nilai: _nilai, komentar: _komentarC.text.trim());
      if (!mounted) return;
      setState(() => _status = _Status.terkirim);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(KuesionerService.pesanError(e))));
    } finally {
      if (mounted) setState(() => _mengirim = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluasi Kualitas Sistem'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: switch (_status) {
        _Status.memuat => const Center(child: CircularProgressIndicator()),
        _Status.gagal => _pesanTengah(
            Icons.cloud_off_rounded,
            const Color(0xFFD97706),
            'Gagal memuat',
            _pesanGagal,
            aksi: _muat,
          ),
        _Status.sudahIsi => _pesanTengah(
            Icons.check_circle_rounded,
            const Color(0xFF16A34A),
            'Kamu sudah mengisi',
            'Terima kasih! Jawabanmu sudah tercatat dan membantu '
                'penilaian kualitas sistem ini.',
          ),
        _Status.terkirim => _pesanTengah(
            Icons.check_circle_rounded,
            const Color(0xFF16A34A),
            'Terima kasih!',
            'Jawabanmu berhasil dikirim dan tersimpan.',
          ),
        _Status.siapIsi => _form(),
      },
    );
  }

  Widget _pesanTengah(
    IconData ikon,
    Color warna,
    String judul,
    String isi, {
    VoidCallback? aksi,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ikon, size: 88, color: warna),
            const SizedBox(height: 20),
            Text(
              judul,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              isi,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, height: 1.5),
            ),
            if (aksi != null) ...[
              const SizedBox(height: 24),
              FilledButton(onPressed: aksi, child: const Text('Coba lagi')),
            ],
          ],
        ),
      ),
    );
  }

  Widget _form() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = dark ? const Color(0xFF16231F) : Colors.white;

    final kelompok = <String, List<Pertanyaan>>{};
    for (final p in _daftar) {
      kelompok.putIfAbsent(p.karakteristik, () => []).add(p);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        Text(
          'Nilai kualitas aplikasi Akademis',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        const Text(
          'Pilih angka 1 sampai 5. 1 = sangat tidak setuju, '
          '5 = sangat setuju. Jawaban hanya bisa dikirim satu kali.',
          style: TextStyle(color: AppColors.muted, height: 1.5),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _nilai.length / _daftar.length,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${_nilai.length} dari ${_daftar.length} pertanyaan terjawab',
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        for (final e in kelompok.entries) ...[
          const SizedBox(height: 18),
          _kartu(e.key, e.value, cardColor),
        ],
        const SizedBox(height: 18),
        TextField(
          controller: _komentarC,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Saran atau komentar (opsional)',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _lengkap && !_mengirim ? _kirim : null,
          child: _mengirim
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(_lengkap ? 'Kirim jawaban' : 'Lengkapi semua pertanyaan'),
        ),
      ],
    );
  }

  Widget _kartu(String judul, List<Pertanyaan> soal, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _ikon[judul] ?? Icons.star_rounded,
                  color: AppColors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      judul,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      _penjelasan[judul] ?? '',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          for (final p in soal) ...[
            const SizedBox(height: 18),
            Text(p.teks, style: const TextStyle(height: 1.4)),
            const SizedBox(height: 10),
            _skala(p.id),
            const SizedBox(height: 4),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sangat tidak setuju',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
                Text(
                  'Sangat setuju',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _skala(int id) {
    final dipilih = _nilai[id];
    final garis = Theme.of(context).colorScheme.outlineVariant;

    return Row(
      children: [
        for (var n = 1; n <= 5; n++)
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _nilai[id] = n),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: dipilih == n ? AppColors.teal : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: dipilih == n ? AppColors.teal : garis,
                  ),
                ),
                child: Text(
                  '$n',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: dipilih == n ? Colors.white : null,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
