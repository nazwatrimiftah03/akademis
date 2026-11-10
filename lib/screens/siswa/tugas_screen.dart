import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class _Tugas {
  _Tugas(this.judul, this.mapel, this.tenggat, {this.selesai = false});

  final String judul;
  final String mapel;
  final String tenggat;
  bool selesai;
}

class TugasSiswaScreen extends StatefulWidget {
  const TugasSiswaScreen({super.key});

  @override
  State<TugasSiswaScreen> createState() => _TugasSiswaScreenState();
}

class _TugasSiswaScreenState extends State<TugasSiswaScreen> {
  final _tugas = <_Tugas>[
    _Tugas('Latihan Soal Turunan', 'Matematika', 'Besok, 23.59'),
    _Tugas('Esai Peristiwa Proklamasi', 'Sejarah', 'Kam, 30 Okt'),
    _Tugas('Laporan Praktikum Titrasi', 'Kimia', 'Jum, 31 Okt'),
    _Tugas('Presentasi Ekosistem', 'Biologi', 'Sen, 3 Nov'),
    _Tugas('Cerpen Bertema Pendidikan', 'Bahasa Indonesia', 'Kemarin',
        selesai: true),
    _Tugas('Soal Hukum Newton', 'Fisika', '20 Okt', selesai: true),
  ];

  bool _tampilSelesai = false;

  void _kumpulkan(_Tugas t) {
    setState(() => t.selesai = true);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('"${t.judul}" berhasil dikumpulkan')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = dark ? const Color(0xFF16231F) : Colors.white;

    final belum = _tugas.where((t) => !t.selesai).length;
    final selesai = _tugas.length - belum;
    final daftar = _tugas.where((t) => t.selesai == _tampilSelesai).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: false, label: Text('Belum ($belum)')),
                  ButtonSegment(value: true, label: Text('Selesai ($selesai)')),
                ],
                selected: {_tampilSelesai},
                onSelectionChanged: (s) =>
                    setState(() => _tampilSelesai = s.first),
              ),
            ),
          ),
          Expanded(
            child: daftar.isEmpty
                ? Center(
              child: Text(
                _tampilSelesai
                    ? 'Belum ada tugas yang selesai'
                    : 'Semua tugas sudah dikumpulkan 🎉',
                style: const TextStyle(color: AppColors.muted),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              itemCount: daftar.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final t = daftar[i];
                return Container(
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
                              t.mapel,
                              style: const TextStyle(
                                color: AppColors.teal,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t.judul,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.schedule_rounded,
                                  size: 14,
                                  color: AppColors.muted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  t.tenggat,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (t.selesai)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF16A34A),
                          size: 30,
                        )
                      else
                        FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 38),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                            ),
                          ),
                          onPressed: () => _kumpulkan(t),
                          child: const Text('Kumpulkan'),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}