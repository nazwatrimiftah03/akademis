import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class _Orang {
  _Orang(this.nama, this.info, this.status);

  final String nama;
  final String info;
  String status; // 'Aktif' atau 'Menunggu'
}

class DataPenggunaScreen extends StatefulWidget {
  const DataPenggunaScreen({super.key, required this.pengajar});

  /// true = daftar pengajar, false = daftar siswa.
  final bool pengajar;

  @override
  State<DataPenggunaScreen> createState() => _DataPenggunaScreenState();
}

class _DataPenggunaScreenState extends State<DataPenggunaScreen> {
  final _cariC = TextEditingController();
  String _kata = '';

  late final List<_Orang> _orang = widget.pengajar
      ? [
    _Orang('Bu Rina Marlina', 'Matematika', 'Aktif'),
    _Orang('Pak Andi Saputra', 'Fisika', 'Aktif'),
    _Orang('Bu Maya Anggraini', 'Bahasa Inggris', 'Aktif'),
    _Orang('Pak Hadi Prasetyo', 'Kimia', 'Menunggu'),
    _Orang('Bu Wati Handayani', 'Biologi', 'Menunggu'),
  ]
      : [
    _Orang('Ahmad Fauzi', 'X IPA 1  •  NIS 1001', 'Aktif'),
    _Orang('Bunga Lestari', 'X IPA 1  •  NIS 1002', 'Aktif'),
    _Orang('Citra Dewi', 'X IPA 1  •  NIS 1003', 'Aktif'),
    _Orang('Gita Savitri', 'X IPA 2  •  NIS 1004', 'Aktif'),
    _Orang('Hendra Wijaya', 'X IPA 2  •  NIS 1005', 'Aktif'),
    _Orang('Laras Ayu', 'XI IPS 1  •  NIS 1006', 'Aktif'),
    _Orang('Miko Ramadhan', 'XI IPS 1  •  NIS 1007', 'Aktif'),
    _Orang('Nadia Putri', 'XI IPS 1  •  NIS 1008', 'Aktif'),
  ];

  @override
  void dispose() {
    _cariC.dispose();
    super.dispose();
  }

  void _setujui(_Orang o) {
    setState(() => o.status = 'Aktif');
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('${o.nama} disetujui')));
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = dark ? const Color(0xFF16231F) : Colors.white;

    final daftar = _orang
        .where((o) => o.nama.toLowerCase().contains(_kata.toLowerCase()))
        .toList();
    final menunggu = _orang.where((o) => o.status == 'Menunggu').length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pengajar ? 'Data Pengajar' : 'Data Siswa'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: TextField(
              controller: _cariC,
              onChanged: (v) => setState(() => _kata = v.trim()),
              decoration: InputDecoration(
                hintText: 'Cari nama...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _kata.isEmpty
                    ? null
                    : IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _cariC.clear();
                    setState(() => _kata = '');
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
            child: Row(
              children: [
                Text(
                  '${daftar.length} ${widget.pengajar ? 'pengajar' : 'siswa'}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                const Spacer(),
                if (widget.pengajar && menunggu > 0)
                  Text(
                    '$menunggu menunggu persetujuan',
                    style: const TextStyle(
                      color: Color(0xFFD97706),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: daftar.isEmpty
                ? const Center(
              child: Text(
                'Tidak ada hasil',
                style: TextStyle(color: AppColors.muted),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              itemCount: daftar.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final o = daftar[i];
                final aktif = o.status == 'Aktif';
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                        AppColors.teal.withValues(alpha: 0.14),
                        child: Text(
                          o.nama.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.teal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              o.nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              o.info,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (aktif)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A)
                                .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Aktif',
                            style: TextStyle(
                              color: Color(0xFF16A34A),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 36),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                            ),
                          ),
                          onPressed: () => _setujui(o),
                          child: const Text('Setujui'),
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