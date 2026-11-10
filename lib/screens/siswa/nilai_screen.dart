import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class _Nilai {
  const _Nilai(this.mapel, this.tugas, this.uts, this.uas);

  final String mapel;
  final int tugas;
  final int uts;
  final int uas;

  /// Bobot: tugas 30%, UTS 30%, UAS 40%.
  double get akhir => tugas * 0.3 + uts * 0.3 + uas * 0.4;
}

const _daftar = [
  _Nilai('Matematika', 82, 78, 85),
  _Nilai('Bahasa Indonesia', 90, 88, 92),
  _Nilai('Bahasa Inggris', 85, 80, 84),
  _Nilai('Fisika', 75, 70, 72),
  _Nilai('Kimia', 68, 65, 70),
  _Nilai('Biologi', 88, 90, 86),
  _Nilai('Sejarah', 92, 85, 90),
  _Nilai('Informatika', 95, 92, 96),
];

String _predikat(double n) {
  if (n >= 85) return 'A';
  if (n >= 75) return 'B';
  if (n >= 65) return 'C';
  return 'D';
}

Color _warna(double n) {
  if (n >= 85) return const Color(0xFF16A34A);
  if (n >= 75) return AppColors.teal;
  if (n >= 65) return const Color(0xFFD97706);
  return const Color(0xFFDC2626);
}

class NilaiSiswaScreen extends StatelessWidget {
  const NilaiSiswaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = dark ? const Color(0xFF16231F) : Colors.white;

    final rata =
        _daftar.map((n) => n.akhir).reduce((a, b) => a + b) / _daftar.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nilai'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.teal, AppColors.tealLight],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rata-rata nilai akhir',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rata.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _predikat(rata),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Bobot: Tugas 30%, UTS 30%, UAS 40%',
              style: TextStyle(color: AppColors.muted, fontSize: 12.5),
            ),
          ),
          const SizedBox(height: 8),
          for (final n in _daftar)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.mapel,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        n.akhir.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _warna(n.akhir),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _warna(n.akhir).withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _predikat(n.akhir),
                          style: TextStyle(
                            color: _warna(n.akhir),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: n.akhir / 100,
                      minHeight: 8,
                      backgroundColor: _warna(n.akhir).withValues(alpha: 0.15),
                      color: _warna(n.akhir),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Mini(label: 'Tugas', nilai: n.tugas),
                      _Mini(label: 'UTS', nilai: n.uts),
                      _Mini(label: 'UAS', nilai: n.uas),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.label, required this.nilai});

  final String label;
  final int nilai;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$nilai',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}