import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/jadwal.dart';
import '../../services/jadwal_service.dart';

// ---------------------------------------------------------------------------
// Data pilihan & helper
// ---------------------------------------------------------------------------

const _hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

const _kelasBawaan = ['X IPA 1', 'X IPA 2', 'XI IPS 1', 'XI IPS 2', 'XII IPA 1'];

/// Mata pelajaran beserta pengajar bawaannya (dipakai kalau belum ada
/// pengajar terdaftar di tabel profiles).
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

// ---------------------------------------------------------------------------
// Layar jadwal
// ---------------------------------------------------------------------------

class JadwalAdminScreen extends StatefulWidget {
  const JadwalAdminScreen({super.key});

  @override
  State<JadwalAdminScreen> createState() => _JadwalAdminScreenState();
}

class _JadwalAdminScreenState extends State<JadwalAdminScreen> {
  final _service = JadwalService();

  String _filterKelas = 'Semua';
  List<Jadwal> _data = [];
  List<String> _guruList = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  /// Pilihan kelas = kelas bawaan + kelas yang sudah ada di jadwal.
  List<String> get _kelasList {
    final semua = <String>{..._kelasBawaan, ..._data.map((j) => j.kelas)};
    return semua.toList();
  }

  /// Pilihan pengajar: dari tabel profiles, atau daftar bawaan kalau kosong.
  List<String> get _pilihanGuru {
    if (_guruList.isNotEmpty) return _guruList;
    return _guruMapel.values.toSet().toList();
  }

  Future<void> _muat({bool diam = false}) async {
    if (!diam) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final jadwal = await _service.ambilSemua();
      final guru = await _service.daftarPengajar();
      if (!mounted) return;
      setState(() {
        _data = jadwal;
        _guruList = guru;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = JadwalService.friendlyError(e);
      });
    }
  }

  /// Mengembalikan alasan bentrok, atau null kalau aman.
  String? _cekBentrok(Jadwal baru) {
    for (final s in _data) {
      if (baru.id != null && s.id == baru.id) continue;
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

  Future<Jadwal?> _bukaForm({Jadwal? awal, required String hari}) {
    return showModalBottomSheet<Jadwal>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FormSesi(
        awal: awal,
        hariAwal: hari,
        kelasList: _kelasList,
        guruList: _pilihanGuru,
        cekBentrok: _cekBentrok,
      ),
    );
  }

  Future<void> _tambah(String hari) async {
    final sesi = await _bukaForm(hari: hari);
    if (sesi == null || !mounted) return;
    try {
      await _service.tambah(sesi);
      await _muat(diam: true);
      _toast('${sesi.mapel} ${sesi.kelas} ditambahkan ke hari ${sesi.hari}');
    } catch (e) {
      if (!mounted) return;
      _toast(JadwalService.friendlyError(e));
    }
  }

  Future<void> _ubah(Jadwal s) async {
    final hasil = await _bukaForm(awal: s, hari: s.hari);
    if (hasil == null || !mounted || s.id == null) return;
    try {
      await _service.ubah(s.id!, hasil);
      await _muat(diam: true);
      _toast('Jadwal diperbarui');
    } catch (e) {
      if (!mounted) return;
      _toast(JadwalService.friendlyError(e));
    }
  }

  Future<void> _hapus(Jadwal s) async {
    final id = s.id;
    if (id == null) return;

    // Hilangkan dari layar dulu (Dismissible wajib langsung hilang).
    setState(() => _data = _data.where((j) => j.id != id).toList());

    try {
      await _service.hapus(id);
    } catch (e) {
      if (!mounted) return;
      await _muat(diam: true);
      _toast(JadwalService.friendlyError(e));
      return;
    }
    if (!mounted) return;

    _toast(
      '${s.mapel} ${s.kelas} dihapus',
      aksi: SnackBarAction(
        label: 'Urungkan',
        onPressed: () async {
          try {
            await _service.tambah(s);
            await _muat(diam: true);
          } catch (e) {
            if (!mounted) return;
            _toast(JadwalService.friendlyError(e));
          }
        },
      ),
    );
  }

  List<Jadwal> _untukHari(String hari) {
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
        floatingActionButton: (_loading || _error != null)
            ? null
            : Builder(
          builder: (ctx) => FloatingActionButton.extended(
            onPressed: () =>
                _tambah(_hari[DefaultTabController.of(ctx).index]),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah jadwal'),
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _muat,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final kelas = _kelasList;
    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            itemCount: kelas.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final k = i == 0 ? 'Semua' : kelas[i - 1];
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
                  onRefresh: () => _muat(diam: true),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DaftarHari extends StatelessWidget {
  const _DaftarHari({
    required this.items,
    required this.onUbah,
    required this.onHapus,
    required this.onRefresh,
  });

  final List<Jadwal> items;
  final void Function(Jadwal) onUbah;
  final void Function(Jadwal) onHapus;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(
              child: Text(
                'Belum ada jadwal',
                style: TextStyle(color: AppColors.muted),
              ),
            ),
          ],
        ),
      );
    }

    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = dark ? const Color(0xFF16231F) : Colors.white;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
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
      ),
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
    required this.kelasList,
    required this.guruList,
    required this.cekBentrok,
  });

  final Jadwal? awal;
  final String hariAwal;
  final List<String> kelasList;
  final List<String> guruList;
  final String? Function(Jadwal) cekBentrok;

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
  late List<String> _guruPilihan;
  late List<String> _mapelPilihan;
  String? _error;

  @override
  void initState() {
    super.initState();
    final a = widget.awal;

    // Pastikan nilai lama tetap muncul sebagai pilihan saat mengubah jadwal.
    _guruPilihan = [...widget.guruList];
    if (a != null && !_guruPilihan.contains(a.guru)) _guruPilihan.add(a.guru);
    _mapelPilihan = _guruMapel.keys.toList();
    if (a != null && !_mapelPilihan.contains(a.mapel)) _mapelPilihan.add(a.mapel);

    _hariPilih = a?.hari ?? widget.hariAwal;
    _kelas = a?.kelas ?? widget.kelasList.first;
    _mapel = a?.mapel ?? _mapelPilihan.first;
    _guru = a?.guru ??
        (_guruPilihan.contains(_guruMapel[_mapel])
            ? _guruMapel[_mapel]!
            : _guruPilihan.first);
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
    final sesi = Jadwal(
      id: widget.awal?.id,
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
              daftar: widget.kelasList,
              terpilih: _kelas,
              onPilih: (v) => _kelas = v,
            ),
            _judul('Mata pelajaran'),
            _pilihan(
              daftar: _mapelPilihan,
              terpilih: _mapel,
              onPilih: (v) {
                _mapel = v;
                final bawaan = _guruMapel[v];
                if (bawaan != null && _guruPilihan.contains(bawaan)) {
                  _guru = bawaan;
                }
              },
            ),
            _judul('Pengajar'),
            _pilihan(
              daftar: _guruPilihan,
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