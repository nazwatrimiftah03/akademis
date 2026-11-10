import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class _Catatan {
  const _Catatan(this.tanggal, this.mapel, this.status);

  final String tanggal;
  final String mapel;
  final String status; // Hadir, Izin, Sakit, Alpha
}

const _riwayat = [
  _Catatan('Sen, 20 Okt', 'Matematika', 'Hadir'),
  _Catatan('Sen, 20 Okt', 'Bahasa Indonesia', 'Hadir'),
  _Catatan('Sel, 21 Okt', 'Bahasa Inggris', 'Hadir'),
  _Catatan('Sel, 21 Okt', 'Kimia', 'Sakit'),
  _Catatan('Rab, 22 Okt', 'Matematika', 'Hadir'),
  _Catatan('Rab, 22 Okt', 'Biologi', 'Hadir'),
  _Catatan('Kam, 23 Okt', 'Fisika', 'Izin'),
  _Catatan('Kam, 23 Okt', 'Informatika', 'Hadir'),
  _Catatan('Jum, 24 Okt', 'Bahasa Indonesia', 'Alpha'),
  _Catatan('Jum, 24 Okt', 'Kimia', 'Hadir'),
];

Color _warna(String status) => switch (status) {
  'Hadir' => const Color(0xFF16A34A),
  'Izin' => const Color(0xFFD97706),
  'Sakit' => const Color(0xFF2563EB),
  _ => const Color(0xFFDC2626),
};

class AbsensiSiswaScreen extends StatelessWidget {
  const AbsensiSiswaScreen({super.key});

  int _hitung(String status) =>
      _riwayat.where((c) => c.status == status).length;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = dark ? const Color(0xFF16231F) : Colors.white;

    final total = _riwayat.length;
    final hadir = _hitung('Hadir');
    final persen = (hadir * 100 / total).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 84,
                      height: 84,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 84,
                            height: 84,
                            child: CircularProgressIndicator(
                              value: hadir / total,
                              strokeWidth: 9,
                              backgroundColor:
                              AppColors.teal.withValues(alpha: 0.15),
                              color: AppColors.teal,
                            ),
                          ),
                          Text(
                            '$persen%',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kehadiran',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hadir $hadir dari $total pertemuan',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    for (final s in const ['Hadir', 'Izin', 'Sakit', 'Alpha'])
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${_hitung(s)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: _warna(s),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Riwayat',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          for (final c in _riwayat.reversed)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.mapel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          c.tanggal,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _warna(c.status).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      c.status,
                      style: TextStyle(
                        color: _warna(c.status),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
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