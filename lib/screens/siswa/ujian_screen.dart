import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class _Ujian {
  _Ujian(
      this.nama,
      this.mapel,
      this.jadwal,
      this.durasi, {
        this.bisaMulai = false,
        this.nilai,
      });

  final String nama;
  final String mapel;
  final String jadwal;
  final String durasi;
  final bool bisaMulai;
  int? nilai;
}

class UjianSiswaScreen extends StatefulWidget {
  const UjianSiswaScreen({super.key});

  @override
  State<UjianSiswaScreen> createState() => _UjianSiswaScreenState();
}

class _UjianSiswaScreenState extends State<UjianSiswaScreen> {
  final _ujian = <_Ujian>[
    _Ujian('Kuis Turunan', 'Matematika', 'Dibuka sekarang', '5 menit',
        bisaMulai: true),
    _Ujian('UTS Fisika', 'Fisika', 'Sen, 3 Nov • 08.00', '90 menit'),
    _Ujian('UTS Kimia', 'Kimia', 'Sel, 4 Nov • 08.00', '90 menit'),
    _Ujian('Kuis Sejarah', 'Sejarah', '12 Okt', '10 menit', nilai: 88),
    _Ujian('Kuis Biologi', 'Biologi', '5 Okt', '10 menit', nilai: 76),
  ];

  Future<void> _mulai(_Ujian u) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Mulai ${u.nama}?'),
        content: Text('Durasi ${u.durasi}. Jawab semua soal sampai selesai.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Mulai'),
          ),
        ],
      ),
    );
    if (yakin != true || !mounted) return;

    final skor = await Navigator.of(context).push<int>(
      MaterialPageRoute(builder: (_) => const _KerjakanScreen()),
    );
    if (skor == null || !mounted) return;
    setState(() => u.nilai = skor);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = dark ? const Color(0xFF16231F) : Colors.white;

    final akan = _ujian.where((u) => u.nilai == null).toList();
    final selesai = _ujian.where((u) => u.nilai != null).toList();

    Widget judul(String teks) => Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        teks,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ujian'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          judul('Akan datang'),
          if (akan.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Tidak ada ujian dalam waktu dekat',
                style: TextStyle(color: AppColors.muted),
              ),
            ),
          for (final u in akan)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u.mapel,
                          style: const TextStyle(
                            color: AppColors.teal,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          u.nama,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${u.jadwal}  •  ${u.durasi}',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (u.bisaMulai)
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 38),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: () => _mulai(u),
                      child: const Text('Mulai'),
                    )
                  else
                    const Icon(Icons.lock_outline_rounded,
                        color: AppColors.muted),
                ],
              ),
            ),
          const SizedBox(height: 12),
          judul('Selesai'),
          for (final u in selesai)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u.nama,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${u.mapel}  •  ${u.jadwal}',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${u.nilai}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: u.nilai! >= 75
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Soal {
  const _Soal(this.tanya, this.opsi, this.benar);

  final String tanya;
  final List<String> opsi;
  final int benar;
}

const _soal = [
  _Soal('Turunan dari f(x) = x² adalah ...', ['x', '2x', 'x²', '2'], 1),
  _Soal('Turunan dari f(x) = 3x³ adalah ...', ['3x²', '9x²', '9x', '6x²'], 1),
  _Soal('Turunan dari konstanta 5 adalah ...', ['5', '1', '0', 'x'], 2),
];

class _KerjakanScreen extends StatefulWidget {
  const _KerjakanScreen();

  @override
  State<_KerjakanScreen> createState() => _KerjakanScreenState();
}

class _KerjakanScreenState extends State<_KerjakanScreen> {
  int _i = 0;
  final List<int?> _jawab = List<int?>.filled(_soal.length, null);

  bool get _terakhir => _i == _soal.length - 1;

  Future<void> _lanjut() async {
    if (!_terakhir) {
      setState(() => _i++);
      return;
    }

    var benar = 0;
    for (var k = 0; k < _soal.length; k++) {
      if (_jawab[k] == _soal[k].benar) benar++;
    }
    final skor = (benar * 100 / _soal.length).round();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Ujian selesai'),
        content: Text('Benar $benar dari ${_soal.length} soal.\nNilaimu: $skor'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop(skor);
  }

  @override
  Widget build(BuildContext context) {
    final s = _soal[_i];

    return Scaffold(
      appBar: AppBar(
        title: Text('Soal ${_i + 1} dari ${_soal.length}'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_i + 1) / _soal.length,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                s.tanya,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              for (var j = 0; j < s.opsi.length; j++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => setState(() => _jawab[_i] = j),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: _jawab[_i] == j
                            ? AppColors.teal.withValues(alpha: 0.10)
                            : null,
                        border: Border.all(
                          color: _jawab[_i] == j
                              ? AppColors.teal
                              : AppColors.muted.withValues(alpha: 0.4),
                          width: _jawab[_i] == j ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        '${String.fromCharCode(65 + j)}.  ${s.opsi[j]}',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _jawab[_i] == null ? null : _lanjut,
                child: Text(_terakhir ? 'Selesai' : 'Lanjut'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}