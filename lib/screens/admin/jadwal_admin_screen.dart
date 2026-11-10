import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

// ---------------------------------------------------------------------------
// Data & helper
// ---------------------------------------------------------------------------

const _hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

const _kelasList = ['X IPA 1', 'X IPA 2', 'XI IPS 1', 'XI IPS 2', 'XII IPA 1'];

/// Mata pelajaran beserta pengajar bawaannya.
const _guruMapel = {
  'Matematika': 'Bu Rina',
  'Bahasa Indonesia': 'Pak Dedi',
  'Fisika': 'Pak Andi',
  'Bahasa Inggris': 'Bu Maya',
  'Kimia': 'Pak Hadi',
  'Sejarah': 'Bu Lina',
  'Biologi': 'Bu Wati',
  'Informatika': 'Pak Rudi',
};

const _ruangList = [
  'R. 101',
  'R. 102',
  'R. 201',
  'R. 202',
  'Lab Fisika',
  'Lab Kimia',
  'Lab Biologi',
  'Lab Komputer',
];

String _formatJam(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';

TimeOfDay _parseJam(String jam) {
  final bagian = jam.split('.');
  return TimeOfDay(
    hour: int.tryParse(bagian.first) ?? 7,
    minute: bagian.length > 1 ? (int.tryParse(bagian[1]) ?? 0) : 0,
  );
}

class _Sesi {
  _Sesi({
    required this.id,
    required this.hari,
    required this.jam,
    required this.mapel,
    required this.kelas,
    required this.guru,
    required this.ruang,
  });

  final int id;
  String hari;
  String jam; // format "07.00"
  String mapel;
  String kelas;
  String guru;
  String ruang;
}

List<_Sesi> _contoh() {
  var n = 0;
  _Sesi s(
      String hari,
      String jam,
      String mapel,
      String kelas,
      String guru,
      String ruang,
      ) {
    n++;
    return _Sesi(
      id: n,
      hari: hari,
      jam: jam,
      mapel: mapel,
      kelas: kelas,
      guru: guru,
      ruang: ruang,
    );
  }

  return [
    s('Senin', '07.00', 'Matematika', 'X IPA 1', 'Bu Rina', 'R. 101'),
    s('Senin', '07.00', 'Bahasa Indonesia', 'X IPA 2', 'Pak Dedi', 'R. 102'),
    s('Senin', '08.30', 'Matematika', 'X IPA 2', 'Bu Rina', 'R. 102'),
    s('Senin', '08.30', 'Fisika', 'X IPA 1', 'Pak Andi', 'Lab Fisika'),
    s('Senin', '10.15', 'Matematika', 'XI IPS 1', 'Bu Rina', 'R. 201'),
    s('Selasa', '07.00', 'Bahasa Inggris', 'X IPA 1', 'Bu Maya', 'R. 101'),
    s('Selasa', '08.30', 'Kimia', 'X IPA 1', 'Pak Hadi', 'Lab Kimia'),
    s('Selasa', '10.15', 'Sejarah', 'XI IPS 1', 'Bu Lina', 'R. 201'),
    s('Rabu', '07.00', 'Biologi', 'X IPA 2', 'Bu Wati', 'Lab Biologi'),
    s('Rabu', '08.30', 'Informatika', 'XII IPA 1', 'Pak Rudi', 'Lab Komputer'),
    s('Kamis', '07.00', 'Fisika', 'X IPA 2', 'Pak Andi', 'Lab Fisika'),
    s('Kamis', '08.30', 'Bahasa Inggris', 'XI IPS 2', 'Bu Maya', 'R. 202'),
    s('Jumat', '07.00', 'Bahasa Indonesia', 'X IPA 1', 'Pak Dedi', 'R. 101'),
  ];
}

// ---------------------------------------------------------------------------
// Layar jadwal
// ---------------------------------------------------------------------------

class JadwalAdminScreen extends StatefulWidget {
  const JadwalAdminScreen({super.key});

  @override
  State<JadwalAdminScreen> createState() => _JadwalAdminScreenState();
}

class _JadwalAdminScreenState extends State<JadwalAdminScreen> {
  int _nextId = 100;
  String _filterKelas = 'Semua';
  final List<_Sesi> _data = _contoh();

  /// Mengembalikan alasan bentrok, atau null kalau aman.
  String? _cekBentrok(_Sesi baru) {
    for (final s in _data) {
      if (s.id == baru.id) continue;
      if (s.hari != baru.hari || s.jam != baru.jam) continue;

      if (s.kelas == baru.kelas) {
        return 'Kelas ${s.kelas} sudah ada pelajaran ${s.mapel} pada jam ini';
      }
      if (s.guru == baru.guru) {
        return '${s.guru} sudah mengajar di ${s.kelas} pada jam ini';
      }
      if (s.ruang == baru.ruang) {
        return 'Ruang ${s.ruang} sedang dipakai ${s.kelas} pada jam ini';
      }
    }
    return null;
  }

  void _toast(String teks, {SnackBarAction? aksi}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks), action: aksi));
  }

  Future<_Sesi?> _bukaForm({_Sesi? awal, required String hari}) {
    return showModalBottomSheet<_Sesi>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FormSesi(
        awal: awal,
        hariAwal: hari,
        idBaru: _nextId,
        cekBentrok: _cekBentrok,
      ),
    );
  }

  Future<void> _tambah(String hari) async {
    final sesi = await _bukaForm(hari: hari);
    if (sesi == null || !mounted) return;
    setState(() {
      _nextId++;
      _data.add(sesi);
    });
    _toast('${sesi.mapel} ${sesi.kelas} ditambahkan ke hari ${sesi.hari}');
  }

  Future<void> _ubah(_Sesi s) async {
    final hasil = await _bukaForm(awal: s, hari: s.hari);
    if (hasil == null || !mounted) return;
    setState(() {
      s.hari = hasil.hari;
      s.jam = hasil.jam;
      s.mapel = hasil.mapel;
      s.kelas = hasil.kelas;
      s.guru = hasil.guru;
      s.ruang = hasil.ruang;
    });
    _toast('Jadwal diperbarui');
  }

  void _hapus(_Sesi s) {
    setState(() => _data.remove(s));
    _toast(
      '${s.mapel} ${s.kelas} dihapus',
      aksi: SnackBarAction(
        label: 'Urungkan',
        onPressed: () {
          if (!mounted) return;
          setState(() => _data.add(s));
        },
      ),
    );
  }

  List<_Sesi> _untukHari(String hari) {
    final hasil = _data
        .where(
          (s) =>
      s.hari == hari &&
          (_filterKelas == 'Semua' || s.kelas == _filterKelas),
    )
        .toList();
    hasil.sort((a, b) => a.jam.compareTo(b.jam));
    return hasil;
  }

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
            tabs: [
              for (final h in _hari) Tab(text: '$h (${_untukHari(h).length})'),
            ],
          ),
        ),
        floatingActionButton: Builder(
          builder: (ctx) => FloatingActionButton.extended(
            onPressed: () => _tambah(_hari[DefaultTabController.of(ctx).index]),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah jadwal'),
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                itemCount: _kelasList.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final k = i == 0 ? 'Semua' : _kelasList[i - 1];
                  return ChoiceChip(
                    label: Text(k),
                    selected: _filterKelas == k,
                    onSelected: (_) => setState(() => _filterKelas = k),
                  );
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  for (final h in _hari)
                    _DaftarHari(
                      items: _untukHari(h),
                      onUbah: _ubah,
                      onHapus: _hapus,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DaftarHari extends StatelessWidget {
  const _DaftarHari({
    required this.items,
    required this.onUbah,
    required this.onHapus,
  });

  final List<_Sesi> items;
  final void Function(_Sesi) onUbah;
  final void Function(_Sesi) onHapus;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada jadwal',
          style: TextStyle(color: AppColors.muted),
        ),
      );
    }

    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = dark ? const Color(0xFF16231F) : Colors.white;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Ketuk untuk ubah, geser ke kiri untuk hapus',
            style: TextStyle(color: AppColors.muted, fontSize: 12.5),
          ),
        ),
        for (final s in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Dismissible(
              key: ValueKey(s.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                ),
              ),
              onDismissed: (_) => onHapus(s),
              child: Material(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onUbah(s),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
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
                                s.mapel,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Kelas ${s.kelas}  •  ${s.guru}',
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                s.ruang,
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: AppColors.muted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Form tambah / ubah jadwal
// ---------------------------------------------------------------------------

class _FormSesi extends StatefulWidget {
  const _FormSesi({
    required this.awal,
    required this.hariAwal,
    required this.idBaru,
    required this.cekBentrok,
  });

  final _Sesi? awal;
  final String hariAwal;
  final int idBaru;
  final String? Function(_Sesi) cekBentrok;

  @override
  State<_FormSesi> createState() => _FormSesiState();
}

class _FormSesiState extends State<_FormSesi> {
  late String _hariPilih;
  late String _kelas;
  late String _mapel;
  late String _guru;
  late String _ruang;
  late TimeOfDay _jam;
  String? _error;

  @override
  void initState() {
    super.initState();
    final a = widget.awal;
    _hariPilih = a?.hari ?? widget.hariAwal;
    _kelas = a?.kelas ?? _kelasList.first;
    _mapel = a?.mapel ?? _guruMapel.keys.first;
    _guru = a?.guru ?? (_guruMapel[_mapel] ?? _guruMapel.values.first);
    _ruang = a?.ruang ?? _ruangList.first;
    _jam = a == null ? const TimeOfDay(hour: 7, minute: 0) : _parseJam(a.jam);
  }

  Future<void> _pilihJam() async {
    final hasil = await showTimePicker(context: context, initialTime: _jam);
    if (hasil == null || !mounted) return;
    setState(() {
      _jam = hasil;
      _error = null;
    });
  }

  void _simpan() {
    final sesi = _Sesi(
      id: widget.awal?.id ?? widget.idBaru,
      hari: _hariPilih,
      jam: _formatJam(_jam),
      mapel: _mapel,
      kelas: _kelas,
      guru: _guru,
      ruang: _ruang,
    );

    final bentrok = widget.cekBentrok(sesi);
    if (bentrok != null) {
      setState(() => _error = bentrok);
      return;
    }
    Navigator.of(context).pop(sesi);
  }

  Widget _judul(String teks) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 8),
    child: Text(teks, style: const TextStyle(fontWeight: FontWeight.w600)),
  );

  Widget _pilihan({
    required List<String> daftar,
    required String terpilih,
    required void Function(String) onPilih,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final d in daftar)
          ChoiceChip(
            label: Text(d),
            selected: terpilih == d,
            onSelected: (_) => setState(() {
              onPilih(d);
              _error = null;
            }),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final edit = widget.awal != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              edit ? 'Ubah jadwal' : 'Tambah jadwal',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            _judul('Hari'),
            _pilihan(
              daftar: _hari,
              terpilih: _hariPilih,
              onPilih: (v) => _hariPilih = v,
            ),
            _judul('Jam mulai'),
            OutlinedButton.icon(
              onPressed: _pilihJam,
              icon: const Icon(Icons.schedule_rounded),
              label: Text(_formatJam(_jam)),
            ),
            _judul('Kelas'),
            _pilihan(
              daftar: _kelasList,
              terpilih: _kelas,
              onPilih: (v) => _kelas = v,
            ),
            _judul('Mata pelajaran'),
            _pilihan(
              daftar: _guruMapel.keys.toList(),
              terpilih: _mapel,
              onPilih: (v) {
                _mapel = v;
                _guru = _guruMapel[v] ?? _guru;
              },
            ),
            _judul('Pengajar'),
            _pilihan(
              daftar: _guruMapel.values.toList(),
              terpilih: _guru,
              onPilih: (v) => _guru = v,
            ),
            _judul('Ruang'),
            _pilihan(
              daftar: _ruangList,
              terpilih: _ruang,
              onPilih: (v) => _ruang = v,
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Jadwal bentrok: $_error',
                        style: const TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _simpan,
              child: Text(edit ? 'Simpan perubahan' : 'Simpan jadwal'),
            ),
          ],
        ),
      ),
    );
  }
}