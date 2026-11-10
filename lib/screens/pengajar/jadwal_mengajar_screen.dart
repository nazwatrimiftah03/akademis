import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class _Sesi {
  const _Sesi(this.jam, this.kelas, this.mapel, this.ruang);

  final String jam;
  final String kelas;
  final String mapel;
  final String ruang;
}

const _hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

const Map<String, List<_Sesi>> _data = {
  'Senin': [
    _Sesi('07.00', 'X IPA 1', 'Matematika', 'R. 101'),
    _Sesi('08.30', 'X IPA 2', 'Matematika', 'R. 102'),
    _Sesi('10.15', 'XI IPS 1', 'Matematika', 'R. 201'),
  ],
  'Selasa': [
    _Sesi('08.30', 'X IPA 1', 'Matematika', 'R. 101'),
    _Sesi('12.45', 'XI IPS 1', 'Matematika', 'R. 201'),
  ],
  'Rabu': [
    _Sesi('07.00', 'X IPA 2', 'Matematika', 'R. 102'),
    _Sesi('10.15', 'X IPA 1', 'Matematika', 'R. 101'),
  ],
  'Kamis': [
    _Sesi('07.00', 'XI IPS 1', 'Matematika', 'R. 201'),
    _Sesi('08.30', 'X IPA 2', 'Matematika', 'R. 102'),
    _Sesi('10.15', 'X IPA 1', 'Matematika', 'R. 101'),
  ],
  'Jumat': [
    _Sesi('07.00', 'X IPA 1', 'Matematika', 'R. 101'),
  ],
  'Sabtu': [],
};

class JadwalMengajarScreen extends StatelessWidget {
  const JadwalMengajarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday; // 1 = Senin ... 7 = Minggu
    final initial = (today >= 1 && today <= 6) ? today - 1 : 0;

    return DefaultTabController(
      length: _hari.length,
      initialIndex: initial,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Jadwal Mengajar'),
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              for (final h in _hari) Tab(text: '$h (${_data[h]?.length ?? 0})'),
            ],
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

  final List<_Sesi> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada jadwal mengajar',
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
        final s = items[i];
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
                  s.jam,
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
                      'Kelas ${s.kelas}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${s.mapel}  •  ${s.ruang}',
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