import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class _Pelajaran {
  const _Pelajaran(this.jam, this.mapel, this.guru, this.ruang);

  final String jam;
  final String mapel;
  final String guru;
  final String ruang;
}

const _hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

const Map<String, List<_Pelajaran>> _data = {
  'Senin': [
    _Pelajaran('07.00', 'Matematika', 'Bu Rina', 'R. 101'),
    _Pelajaran('08.30', 'Bahasa Indonesia', 'Pak Dedi', 'R. 101'),
    _Pelajaran('10.15', 'Fisika', 'Pak Andi', 'Lab Fisika'),
    _Pelajaran('12.45', 'Pendidikan Agama', 'Bu Siti', 'R. 101'),
  ],
  'Selasa': [
    _Pelajaran('07.00', 'Bahasa Inggris', 'Bu Maya', 'R. 101'),
    _Pelajaran('08.30', 'Kimia', 'Pak Hadi', 'Lab Kimia'),
    _Pelajaran('10.15', 'Sejarah', 'Bu Lina', 'R. 101'),
  ],
  'Rabu': [
    _Pelajaran('07.00', 'Matematika', 'Bu Rina', 'R. 101'),
    _Pelajaran('08.30', 'Biologi', 'Bu Wati', 'Lab Biologi'),
    _Pelajaran('10.15', 'Penjaskes', 'Pak Eko', 'Lapangan'),
  ],
  'Kamis': [
    _Pelajaran('07.00', 'Fisika', 'Pak Andi', 'Lab Fisika'),
    _Pelajaran('08.30', 'Bahasa Inggris', 'Bu Maya', 'R. 101'),
    _Pelajaran('10.15', 'Seni Budaya', 'Bu Dewi', 'R. Seni'),
    _Pelajaran('12.45', 'Informatika', 'Pak Rudi', 'Lab Komputer'),
  ],
  'Jumat': [
    _Pelajaran('07.00', 'Bahasa Indonesia', 'Pak Dedi', 'R. 101'),
    _Pelajaran('08.30', 'Kimia', 'Pak Hadi', 'Lab Kimia'),
  ],
  'Sabtu': [
    _Pelajaran('07.00', 'Pramuka', 'Pak Eko', 'Lapangan'),
  ],
};

class JadwalSiswaScreen extends StatelessWidget {
  const JadwalSiswaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday; // 1 = Senin ... 7 = Minggu
    final initial = (today >= 1 && today <= 6) ? today - 1 : 0;

    return DefaultTabController(
      length: _hari.length,
      initialIndex: initial,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Jadwal Pelajaran'),
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [for (final h in _hari) Tab(text: h)],
          ),
        ),
        body: TabBarView(
          children: [
            for (final h in _hari) _DayList(items: _data[h] ?? const []),
          ],
        ),
      ),
    );
  }
}

class _DayList extends StatelessWidget {
  const _DayList({required this.items});

  final List<_Pelajaran> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada pelajaran',
          style: TextStyle(color: AppColors.muted),
        ),
      );
    }

    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = dark ? const Color(0xFF16231F) : Colors.white;

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final p = items[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  p.jam,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.mapel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${p.guru}  •  ${p.ruang}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}