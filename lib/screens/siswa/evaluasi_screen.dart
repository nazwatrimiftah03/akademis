import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class _Aspek {
  const _Aspek(this.nama, this.keterangan, this.ikon);

  final String nama;
  final String keterangan;
  final IconData ikon;
}

const _aspek = [
  _Aspek('Kemudahan penggunaan', 'Aplikasi mudah dipahami dan dipakai',
      Icons.touch_app_rounded),
  _Aspek('Tampilan', 'Desain rapi dan nyaman dilihat', Icons.palette_rounded),
  _Aspek('Kecepatan', 'Halaman terbuka dengan cepat', Icons.speed_rounded),
  _Aspek('Kelengkapan fitur', 'Fitur sesuai kebutuhan belajar',
      Icons.apps_rounded),
  _Aspek('Keandalan', 'Aplikasi stabil dan jarang error',
      Icons.verified_user_rounded),
];

const _label = [
  '',
  'Sangat kurang',
  'Kurang',
  'Cukup',
  'Baik',
  'Sangat baik',
];

class EvaluasiSiswaScreen extends StatefulWidget {
  const EvaluasiSiswaScreen({super.key});

  @override
  State<EvaluasiSiswaScreen> createState() => _EvaluasiSiswaScreenState();
}

class _EvaluasiSiswaScreenState extends State<EvaluasiSiswaScreen> {
  final List<int> _nilai = List<int>.filled(_aspek.length, 0);
  final _komentarC = TextEditingController();
  bool _terkirim = false;

  bool get _lengkap => _nilai.every((n) => n > 0);

  double get _rata => _nilai.reduce((a, b) => a + b) / _nilai.length;

  @override
  void dispose() {
    _komentarC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = dark ? const Color(0xFF16231F) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluasi Sistem'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: _terkirim ? _buildTerkirim() : _buildForm(cardColor),
    );
  }

  Widget _buildTerkirim() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 88,
              color: Color(0xFF16A34A),
            ),
            const SizedBox(height: 20),
            const Text(
              'Terima kasih!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Rata-rata penilaianmu: ${_rata.toStringAsFixed(1)} dari 5.\n'
                  'Masukanmu membantu sekolah meningkatkan sistem ini.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, height: 1.5),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(Color cardColor) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        const Text(
          'Bagaimana pengalamanmu memakai Akademis? Beri bintang untuk '
              'setiap aspek.',
          style: TextStyle(color: AppColors.muted, height: 1.5),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < _aspek.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_aspek[i].ikon, color: AppColors.teal, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _aspek[i].nama,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Text(
                    _aspek[i].keterangan,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (var b = 1; b <= 5; b++)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setState(() => _nilai[i] = b),
                        icon: Icon(
                          b <= _nilai[i]
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 34,
                          color: b <= _nilai[i]
                              ? const Color(0xFFF59E0B)
                              : AppColors.muted,
                        ),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _label[_nilai[i]],
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: 4),
        TextField(
          controller: _komentarC,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Saran atau komentar (opsional)',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _lengkap ? () => setState(() => _terkirim = true) : null,
          child: const Text('Kirim Evaluasi'),
        ),
        if (!_lengkap)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Beri bintang untuk semua aspek dulu.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 12.5),
            ),
          ),
      ],
    );
  }
}