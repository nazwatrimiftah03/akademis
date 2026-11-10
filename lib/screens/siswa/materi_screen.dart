import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class _Materi {
  const _Materi(this.judul, this.mapel, this.jenis, this.tanggal);

  final String judul;
  final String mapel;
  final String jenis; // PDF, Video, Slide
  final String tanggal;
}

const _data = [
  _Materi('Turunan Fungsi Aljabar', 'Matematika', 'PDF', '22 Okt'),
  _Materi('Limit dan Kekontinuan', 'Matematika', 'Video', '15 Okt'),
  _Materi('Hukum Newton', 'Fisika', 'Slide', '21 Okt'),
  _Materi('Gerak Parabola', 'Fisika', 'Video', '14 Okt'),
  _Materi('Titrasi Asam Basa', 'Kimia', 'PDF', '20 Okt'),
  _Materi('Struktur Teks Cerpen', 'Bahasa Indonesia', 'PDF', '19 Okt'),
  _Materi('Sistem Pencernaan', 'Biologi', 'Slide', '18 Okt'),
  _Materi('Proklamasi Kemerdekaan', 'Sejarah', 'Video', '17 Okt'),
];

IconData _ikon(String jenis) => switch (jenis) {
  'Video' => Icons.play_circle_rounded,
  'Slide' => Icons.slideshow_rounded,
  _ => Icons.picture_as_pdf_rounded,
};

class MateriSiswaScreen extends StatefulWidget {
  const MateriSiswaScreen({super.key});

  @override
  State<MateriSiswaScreen> createState() => _MateriSiswaScreenState();
}

class _MateriSiswaScreenState extends State<MateriSiswaScreen> {
  String _filter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = dark ? const Color(0xFF16231F) : Colors.white;

    final pilihan = ['Semua', ..._data.map((m) => m.mapel).toSet()];
    final daftar =
    _data.where((m) => _filter == 'Semua' || m.mapel == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materi'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: pilihan.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final p = pilihan[i];
                return ChoiceChip(
                  label: Text(p),
                  selected: _filter == p,
                  onSelected: (_) => setState(() => _filter = p),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: daftar.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final m = daftar[i];
                return Material(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              'Membuka "${m.judul}" (versi contoh)',
                            ),
                          ),
                        );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.teal.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              _ikon(m.jenis),
                              color: AppColors.teal,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.judul,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${m.mapel}  •  ${m.jenis}  •  ${m.tanggal}',
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.muted,
                          ),
                        ],
                      ),
                    ),
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