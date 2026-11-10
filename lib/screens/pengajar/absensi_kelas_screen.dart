import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

const _kelas = {
  'X IPA 1': [
    'Ahmad Fauzi',
    'Bunga Lestari',
    'Citra Dewi',
    'Dimas Pratama',
    'Eka Putri',
    'Farhan Maulana',
  ],
  'X IPA 2': [
    'Gita Savitri',
    'Hendra Wijaya',
    'Indah Permata',
    'Joko Santoso',
    'Kirana Sari',
  ],
  'XI IPS 1': [
    'Laras Ayu',
    'Miko Ramadhan',
    'Nadia Putri',
    'Oscar Firmansyah',
    'Putri Anjani',
    'Rizky Hidayat',
  ],
};

const _opsiStatus = ['Hadir', 'Izin', 'Sakit', 'Alpha'];

Color _warna(String status) => switch (status) {
  'Hadir' => const Color(0xFF16A34A),
  'Izin' => const Color(0xFFD97706),
  'Sakit' => const Color(0xFF2563EB),
  _ => const Color(0xFFDC2626),
};

class AbsensiKelasScreen extends StatefulWidget {
  const AbsensiKelasScreen({super.key});

  @override
  State<AbsensiKelasScreen> createState() => _AbsensiKelasScreenState();
}

class _AbsensiKelasScreenState extends State<AbsensiKelasScreen> {
  String _pilih = _kelas.keys.first;

  // Kunci: 'kelas|nama'. Yang tidak ada di sini dianggap Hadir.
  final Map<String, String> _status = {};

  String _statusOf(String nama) => _status['$_pilih|$nama'] ?? 'Hadir';

  int _hitung(String status) {
    return _kelas[_pilih]!.where((n) => _statusOf(n) == status).length;
  }

  void _semuaHadir() {
    setState(() {
      for (final n in _kelas[_pilih]!) {
        _status['$_pilih|$n'] = 'Hadir';
      }
    });
  }

  void _simpan() {
    final ringkasan = _opsiStatus.map((s) => '$s ${_hitung(s)}').join(', ');
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Absensi $_pilih tersimpan: $ringkasan')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = dark ? const Color(0xFF16231F) : Colors.white;
    final siswa = _kelas[_pilih]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi Kelas'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        actions: [
          TextButton(
            onPressed: _semuaHadir,
            child: const Text('Semua hadir'),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _kelas.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final k = _kelas.keys.elementAt(i);
                return ChoiceChip(
                  label: Text(k),
                  selected: _pilih == k,
                  onSelected: (_) => setState(() => _pilih = k),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              children: [
                for (final s in _opsiStatus)
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
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              itemCount: siswa.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final nama = siswa[i];
                final st = _statusOf(nama);
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${i + 1}. $nama',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          for (final s in _opsiStatus)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () => setState(
                                        () => _status['$_pilih|$nama'] = s,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: st == s
                                          ? _warna(s)
                                          : _warna(s).withValues(alpha: 0.10),
                                    ),
                                    child: Text(
                                      s,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color:
                                        st == s ? Colors.white : _warna(s),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: FilledButton(
                onPressed: _simpan,
                child: const Text('Simpan Absensi'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}