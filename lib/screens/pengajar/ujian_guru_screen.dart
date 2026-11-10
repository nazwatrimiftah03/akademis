import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

// ---------------------------------------------------------------------------
// Data & helper
// ---------------------------------------------------------------------------

const _kelasGuru = ['X IPA 1', 'X IPA 2', 'XI IPS 1'];
const _jenisList = ['Kuis', 'UTS', 'UAS'];
const _hurufOpsi = ['A', 'B', 'C', 'D'];
const _kkm = 75;

const _hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
const _bulan = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

String _tanggal(DateTime d) =>
    '${_hari[d.weekday - 1]}, ${d.day} ${_bulan[d.month - 1]} ${d.year}';

String _jam(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}.${d.minute.toString().padLeft(2, '0')}';

Color _warnaJenis(String jenis) => switch (jenis) {
  'UTS' => const Color(0xFFF59E0B),
  'UAS' => const Color(0xFFE11D48),
  _ => const Color(0xFF2563EB),
};

Color _kartu(BuildContext context) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return dark ? const Color(0xFF16231F) : Colors.white;
}

enum _Status { terjadwal, berlangsung, selesai }

class _Soal {
  _Soal(this.tanya, this.opsi, this.kunci);

  final String tanya;
  final List<String> opsi; // selalu 4 pilihan
  final int kunci; // indeks jawaban benar (0-3)
}

class _Ujian {
  _Ujian({
    required this.id,
    required this.judul,
    required this.jenis,
    required this.kelas,
    required this.mulai,
    required this.durasi,
    required this.soal,
    this.nilai = const [],
  });

  final int id;
  String judul;
  String jenis;
  String kelas;
  DateTime mulai;
  int durasi; // menit
  final List<_Soal> soal;

  /// Nilai siswa, hanya terisi untuk ujian yang sudah selesai.
  final List<int> nilai;

  DateTime get selesai => mulai.add(Duration(minutes: durasi));

  _Status get status {
    final now = DateTime.now();
    if (now.isBefore(mulai)) return _Status.terjadwal;
    if (now.isBefore(selesai)) return _Status.berlangsung;
    return _Status.selesai;
  }

  double get rata =>
      nilai.isEmpty ? 0 : nilai.fold(0, (a, b) => a + b) / nilai.length;
  int get tertinggi =>
      nilai.isEmpty ? 0 : nilai.reduce((a, b) => a > b ? a : b);
  int get terendah => nilai.isEmpty ? 0 : nilai.reduce((a, b) => a < b ? a : b);
  int get lulus => nilai.where((n) => n >= _kkm).length;
}

class _IsiUjian {
  const _IsiUjian(this.judul, this.jenis, this.kelas, this.mulai, this.durasi);

  final String judul;
  final String jenis;
  final String kelas;
  final DateTime mulai;
  final int durasi;
}

class _Rentang {
  const _Rentang(this.label, this.dari, this.sampai);

  final String label;
  final int dari;
  final int sampai;
}

const _rentangNilai = [
  _Rentang('< 60', 0, 59),
  _Rentang('60 - 69', 60, 69),
  _Rentang('70 - 79', 70, 79),
  _Rentang('80 - 89', 80, 89),
  _Rentang('90 - 100', 90, 100),
];

String _hitungMundur(DateTime mulai) {
  final d = mulai.difference(DateTime.now());
  if (d.inDays >= 1) return '${d.inDays} hari lagi';
  if (d.inHours >= 1) return '${d.inHours} jam lagi';
  final menit = d.inMinutes < 1 ? 1 : d.inMinutes;
  return '$menit menit lagi';
}

List<_Ujian> _contoh() {
  final now = DateTime.now();
  DateTime pada(int hariKe, int jam, int menit) {
    final d = now.add(Duration(days: hariKe));
    return DateTime(d.year, d.month, d.day, jam, menit);
  }

  return [
    _Ujian(
      id: 1,
      judul: 'Kuis Turunan',
      jenis: 'Kuis',
      kelas: 'X IPA 1',
      mulai: pada(1, 8, 0),
      durasi: 20,
      soal: [
        _Soal('Turunan dari f(x) = x kuadrat adalah?', [
          'x',
          '2x',
          'x kuadrat',
          '2',
        ], 1),
        _Soal('Turunan dari f(x) = 3x pangkat 3 adalah?', [
          '9x kuadrat',
          '3x kuadrat',
          '9x pangkat 3',
          'x kuadrat',
        ], 0),
        _Soal('Jika f(x) = 5x + 2, maka f\'(x) adalah?', [
          '2',
          '5x',
          '5',
          '7',
        ], 2),
        _Soal('Turunan dari konstanta 7 adalah?', [
          '7',
          '1',
          '0',
          'tidak ada',
        ], 2),
      ],
    ),
    _Ujian(
      id: 2,
      judul: 'UTS Matematika',
      jenis: 'UTS',
      kelas: 'X IPA 2',
      mulai: pada(5, 8, 0),
      durasi: 90,
      soal: [
        _Soal('Nilai limit x menuju 2 dari (x kuadrat - 4)/(x - 2) adalah?', [
          '0',
          '2',
          '4',
          'tidak ada',
        ], 2),
        _Soal('Hasil dari 2 pangkat 3 dikali 2 pangkat 2 adalah?', [
          '2 pangkat 5',
          '2 pangkat 6',
          '4 pangkat 5',
          '4 pangkat 6',
        ], 0),
        _Soal('Nilai sin 30 derajat adalah?', [
          '1/2',
          'akar 3 per 2',
          '1',
          '0',
        ], 0),
      ],
    ),
    _Ujian(
      id: 3,
      judul: 'Kuis Limit',
      jenis: 'Kuis',
      kelas: 'XI IPS 1',
      mulai: pada(9, 10, 15),
      durasi: 15,
      soal: [],
    ),
    _Ujian(
      id: 4,
      judul: 'Kuis Aljabar',
      jenis: 'Kuis',
      kelas: 'X IPA 1',
      mulai: pada(-6, 8, 0),
      durasi: 15,
      soal: [
        _Soal('Hasil dari 3(x + 2) adalah?', [
          '3x + 2',
          '3x + 6',
          'x + 6',
          '3x + 5',
        ], 1),
        _Soal('Jika x + 4 = 9, maka x adalah?', ['3', '4', '5', '13'], 2),
      ],
      nilai: const [
        88,
        92,
        75,
        60,
        81,
        95,
        70,
        78,
        85,
        66,
        90,
        72,
        84,
        79,
        58,
        93,
        87,
        76,
        69,
        82,
        91,
        74,
        80,
        63,
        89,
        77,
        86,
        71,
        94,
        83,
        68,
        97,
      ],
    ),
    _Ujian(
      id: 5,
      judul: 'Ulangan Statistika',
      jenis: 'UTS',
      kelas: 'XI IPS 1',
      mulai: pada(-14, 10, 15),
      durasi: 45,
      soal: [
        _Soal('Rata-rata dari 4, 6, 8 adalah?', ['5', '6', '7', '8'], 1),
        _Soal('Nilai yang paling sering muncul disebut?', [
          'mean',
          'median',
          'modus',
          'jangkauan',
        ], 2),
        _Soal('Nilai tengah data terurut disebut?', [
          'mean',
          'median',
          'modus',
          'kuartil',
        ], 1),
      ],
      nilai: const [
        78,
        85,
        72,
        90,
        66,
        81,
        74,
        88,
        69,
        93,
        77,
        84,
        71,
        80,
        62,
        86,
        75,
        91,
        68,
        83,
        79,
        73,
        87,
        64,
        82,
        76,
        89,
        70,
        95,
        67,
        85,
        78,
        72,
        81,
      ],
    ),
  ];
}

// ---------------------------------------------------------------------------
// Layar 1: daftar ujian
// ---------------------------------------------------------------------------

class UjianGuruScreen extends StatefulWidget {
  const UjianGuruScreen({super.key});

  @override
  State<UjianGuruScreen> createState() => _UjianGuruScreenState();
}

class _UjianGuruScreenState extends State<UjianGuruScreen> {
  int _nextId = 10;
  final List<_Ujian> _data = _contoh();

  void _toast(String teks, {SnackBarAction? aksi}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks), action: aksi));
  }

  Future<_IsiUjian?> _bukaForm({_Ujian? awal}) {
    return showModalBottomSheet<_IsiUjian>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FormUjian(awal: awal),
    );
  }

  Future<void> _tambah() async {
    final isi = await _bukaForm();
    if (isi == null || !mounted) return;

    setState(() {
      _data.add(
        _Ujian(
          id: _nextId++,
          judul: isi.judul,
          jenis: isi.jenis,
          kelas: isi.kelas,
          mulai: isi.mulai,
          durasi: isi.durasi,
          soal: [],
        ),
      );
    });
    _toast('"${isi.judul}" dijadwalkan. Tambahkan soal di halaman detail.');
  }

  Future<void> _ubah(_Ujian u) async {
    final isi = await _bukaForm(awal: u);
    if (isi == null || !mounted) return;

    setState(() {
      u.judul = isi.judul;
      u.jenis = isi.jenis;
      u.kelas = isi.kelas;
      u.mulai = isi.mulai;
      u.durasi = isi.durasi;
    });
    _toast('Perubahan disimpan');
  }

  void _hapus(_Ujian u) {
    final index = _data.indexOf(u);
    if (index < 0) return;
    setState(() => _data.removeAt(index));
    _toast(
      '"${u.judul}" dihapus',
      aksi: SnackBarAction(
        label: 'Urungkan',
        onPressed: () {
          if (!mounted) return;
          setState(() {
            final pos = index > _data.length ? _data.length : index;
            _data.insert(pos, u);
          });
        },
      ),
    );
  }

  void _bukaDetail(_Ujian u) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _DetailUjian(
          ujian: u,
          onChanged: () {
            if (mounted) setState(() {});
          },
          onUbah: _ubah,
          onHapus: _hapus,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final terjadwal = _data.where((u) => u.status != _Status.selesai).toList()
      ..sort((a, b) => a.mulai.compareTo(b.mulai));
    final selesai = _data.where((u) => u.status == _Status.selesai).toList()
      ..sort((a, b) => b.mulai.compareTo(a.mulai));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ujian'),
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Terjadwal (${terjadwal.length})'),
              Tab(text: 'Selesai (${selesai.length})'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _tambah,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Buat ujian'),
        ),
        body: TabBarView(
          children: [
            _daftar(
              terjadwal,
              kosong: 'Belum ada ujian terjadwal',
              denganHero: true,
              bisaGeser: true,
            ),
            _daftar(
              selesai,
              kosong: 'Belum ada ujian yang selesai',
              denganHero: false,
              bisaGeser: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _daftar(
      List<_Ujian> items, {
        required String kosong,
        required bool denganHero,
        required bool bisaGeser,
      }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        if (denganHero) ...[
          _Hero(berikutnya: items.isEmpty ? null : items.first),
          const SizedBox(height: 18),
        ],
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              children: [
                const Icon(
                  Icons.event_busy_rounded,
                  size: 56,
                  color: AppColors.muted,
                ),
                const SizedBox(height: 12),
                Text(kosong, style: const TextStyle(color: AppColors.muted)),
              ],
            ),
          )
        else
          for (final u in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: bisaGeser && u.status == _Status.terjadwal
                  ? Dismissible(
                key: ValueKey(u.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (_) => _hapus(u),
                child: _KartuUjian(ujian: u, onTap: () => _bukaDetail(u)),
              )
                  : _KartuUjian(ujian: u, onTap: () => _bukaDetail(u)),
            ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.berikutnya});

  final _Ujian? berikutnya;

  @override
  Widget build(BuildContext context) {
    final u = berikutnya;
    final sedang = u != null && u.status == _Status.berlangsung;

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.teal, AppColors.tealLight],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
            ),
            Positioned(
              right: 36,
              bottom: -40,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            if (u == null)
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ujian berikutnya',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Belum ada jadwal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sedang ? 'Sedang berlangsung' : 'Ujian berikutnya',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    u.judul,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${u.kelas}  •  ${_tanggal(u.mulai)}  •  ${_jam(u.mulai)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          sedang ? 'Sedang jalan' : _hitungMundur(u.mulai),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
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
    );
  }
}

class _KartuUjian extends StatelessWidget {
  const _KartuUjian({required this.ujian, required this.onTap});

  final _Ujian ujian;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final u = ujian;
    final warna = _warnaJenis(u.jenis);

    return Material(
      color: _kartu(context),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 54,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: warna.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      '${u.mulai.day}',
                      style: TextStyle(
                        color: warna,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _bulan[u.mulai.month - 1],
                      style: TextStyle(
                        color: warna,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            u.judul,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _LabelJenis(jenis: u.jenis),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${u.kelas}  •  ${_jam(u.mulai)}  •  ${u.durasi} menit',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _InfoBawah(ujian: u),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabelJenis extends StatelessWidget {
  const _LabelJenis({required this.jenis});

  final String jenis;

  @override
  Widget build(BuildContext context) {
    final warna = _warnaJenis(jenis);
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        jenis,
        style: TextStyle(
          color: warna,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoBawah extends StatelessWidget {
  const _InfoBawah({required this.ujian});

  final _Ujian ujian;

  @override
  Widget build(BuildContext context) {
    final u = ujian;

    if (u.status == _Status.selesai) {
      return Text(
        'Rata-rata ${u.rata.toStringAsFixed(1)}  •  ${u.lulus}/${u.nilai.length} lulus',
        style: const TextStyle(
          color: AppColors.teal,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    if (u.status == _Status.berlangsung) {
      return const Text(
        'Sedang berlangsung',
        style: TextStyle(
          color: Color(0xFF16A34A),
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    if (u.soal.isEmpty) {
      return const Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 15, color: Color(0xFFF59E0B)),
          SizedBox(width: 4),
          Text(
            'Belum ada soal',
            style: TextStyle(
              color: Color(0xFFF59E0B),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      '${u.soal.length} soal  •  ${_hitungMundur(u.mulai)}',
      style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
    );
  }
}

// ---------------------------------------------------------------------------
// Layar 2: detail ujian (soal & hasil)
// ---------------------------------------------------------------------------

class _DetailUjian extends StatefulWidget {
  const _DetailUjian({
    required this.ujian,
    required this.onChanged,
    required this.onUbah,
    required this.onHapus,
  });

  final _Ujian ujian;
  final VoidCallback onChanged;
  final Future<void> Function(_Ujian) onUbah;
  final void Function(_Ujian) onHapus;

  @override
  State<_DetailUjian> createState() => _DetailUjianState();
}

class _DetailUjianState extends State<_DetailUjian> {
  late bool _lihatHasil = widget.ujian.status == _Status.selesai;

  Future<void> _tambahSoal() async {
    final soal = await showModalBottomSheet<_Soal>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _FormSoal(),
    );
    if (soal == null || !mounted) return;
    setState(() => widget.ujian.soal.add(soal));
    widget.onChanged();
  }

  void _hapusSoal(int index) {
    setState(() => widget.ujian.soal.removeAt(index));
    widget.onChanged();
  }

  Future<void> _konfirmasiHapus() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus "${widget.ujian.judul}"?'),
        content: const Text('Ujian dan seluruh soalnya akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (yakin != true || !mounted) return;
    widget.onHapus(widget.ujian);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.ujian;
    final status = u.status;
    final warna = _warnaJenis(u.jenis);
    final bisaUbah = status == _Status.terjadwal;
    final punyaHasil = status == _Status.selesai;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail ujian'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        actions: [
          if (bisaUbah)
            IconButton(
              tooltip: 'Ubah jadwal',
              icon: const Icon(Icons.edit_rounded),
              onPressed: () async {
                await widget.onUbah(u);
                if (mounted) setState(() {});
              },
            ),
          if (status != _Status.berlangsung)
            IconButton(
              tooltip: 'Hapus',
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFDC2626),
              ),
              onPressed: _konfirmasiHapus,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          // Lapisan 1: kartu ringkasan.
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [warna, warna.withValues(alpha: 0.7)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        u.jenis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(switch (status) {
                      _Status.terjadwal => 'Terjadwal',
                      _Status.berlangsung => 'Sedang berlangsung',
                      _Status.selesai => 'Selesai',
                    }, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  u.judul,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                _BarisInfo(Icons.class_rounded, 'Kelas ${u.kelas}'),
                const SizedBox(height: 6),
                _BarisInfo(Icons.event_rounded, _tanggal(u.mulai)),
                const SizedBox(height: 6),
                _BarisInfo(
                  Icons.schedule_rounded,
                  '${_jam(u.mulai)} - ${_jam(u.selesai)}  (${u.durasi} menit)',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Lapisan 2: pilihan tampilan (hanya kalau sudah ada hasil).
          if (punyaHasil) ...[
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: true,
                    icon: Icon(Icons.bar_chart_rounded),
                    label: Text('Hasil'),
                  ),
                  ButtonSegment(
                    value: false,
                    icon: Icon(Icons.list_alt_rounded),
                    label: Text('Soal'),
                  ),
                ],
                selected: {_lihatHasil},
                onSelectionChanged: (s) =>
                    setState(() => _lihatHasil = s.first),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Lapisan 3: isi.
          if (punyaHasil && _lihatHasil)
            _PanelHasil(ujian: u)
          else
            _PanelSoal(
              ujian: u,
              bisaUbah: bisaUbah,
              onTambah: _tambahSoal,
              onHapus: _hapusSoal,
            ),
        ],
      ),
    );
  }
}

class _BarisInfo extends StatelessWidget {
  const _BarisInfo(this.ikon, this.teks);

  final IconData ikon;
  final String teks;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(ikon, size: 18, color: Colors.white70),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            teks,
            style: const TextStyle(color: Colors.white, fontSize: 13.5),
          ),
        ),
      ],
    );
  }
}

class _PanelSoal extends StatelessWidget {
  const _PanelSoal({
    required this.ujian,
    required this.bisaUbah,
    required this.onTambah,
    required this.onHapus,
  });

  final _Ujian ujian;
  final bool bisaUbah;
  final VoidCallback onTambah;
  final void Function(int) onHapus;

  @override
  Widget build(BuildContext context) {
    final soal = ujian.soal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Daftar soal (${soal.length})',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (bisaUbah)
              TextButton.icon(
                onPressed: onTambah,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Tambah soal'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (soal.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _kartu(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                Icon(Icons.edit_note_rounded, size: 48, color: AppColors.muted),
                SizedBox(height: 8),
                Text(
                  'Belum ada soal',
                  style: TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          )
        else
          for (var i = 0; i < soal.length; i++)
            _KartuSoal(
              nomor: i + 1,
              soal: soal[i],
              onHapus: bisaUbah ? () => onHapus(i) : null,
            ),
      ],
    );
  }
}

class _KartuSoal extends StatelessWidget {
  const _KartuSoal({required this.nomor, required this.soal, this.onHapus});

  final int nomor;
  final _Soal soal;
  final VoidCallback? onHapus;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kartu(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.teal,
                child: Text(
                  '$nomor',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  soal.tanya,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              if (onHapus != null)
                InkWell(
                  onTap: onHapus,
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.muted,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < soal.opsi.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    i == soal.kunci
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 18,
                    color: i == soal.kunci
                        ? const Color(0xFF16A34A)
                        : AppColors.muted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_hurufOpsi[i]}. ${soal.opsi[i]}',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: i == soal.kunci
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: i == soal.kunci ? const Color(0xFF16A34A) : null,
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

class _PanelHasil extends StatelessWidget {
  const _PanelHasil({required this.ujian});

  final _Ujian ujian;

  @override
  Widget build(BuildContext context) {
    final u = ujian;
    final jumlah = u.nilai.length;
    final persenLulus = jumlah == 0 ? 0.0 : u.lulus / jumlah;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _KotakAngka(
                u.rata.toStringAsFixed(1),
                'Rata-rata',
                AppColors.teal,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _KotakAngka(
                '${u.tertinggi}',
                'Tertinggi',
                const Color(0xFF16A34A),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _KotakAngka(
                '${u.terendah}',
                'Terendah',
                const Color(0xFFE11D48),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _kartu(context),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Ketuntasan (KKM $_kkm)',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    '${u.lulus}/$jumlah siswa',
                    style: const TextStyle(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: persenLulus,
                  minHeight: 9,
                  backgroundColor: const Color(0xFFE11D48)
                      .withValues(alpha: 0.25),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${jumlah - u.lulus} siswa perlu remedial',
                style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _kartu(context),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sebaran nilai',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              for (final r in _rentangNilai)
                _BarisSebaran(
                  label: r.label,
                  jumlah: u.nilai
                      .where((n) => n >= r.dari && n <= r.sampai)
                      .length,
                  total: jumlah,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KotakAngka extends StatelessWidget {
  const _KotakAngka(this.angka, this.label, this.warna);

  final String angka;
  final String label;
  final Color warna;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            angka,
            style: TextStyle(
              color: warna,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
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

class _BarisSebaran extends StatelessWidget {
  const _BarisSebaran({
    required this.label,
    required this.jumlah,
    required this.total,
  });

  final String label;
  final int jumlah;
  final int total;

  @override
  Widget build(BuildContext context) {
    final nilai = total == 0 ? 0.0 : jumlah / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(label, style: const TextStyle(fontSize: 12.5)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: nilai,
                minHeight: 12,
                backgroundColor: AppColors.teal.withValues(alpha: 0.10),
              ),
            ),
          ),
          SizedBox(
            width: 34,
            child: Text(
              '$jumlah',
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Layar 3: form jadwal ujian (bottom sheet)
// ---------------------------------------------------------------------------

class _FormUjian extends StatefulWidget {
  const _FormUjian({this.awal});

  final _Ujian? awal;

  @override
  State<_FormUjian> createState() => _FormUjianState();
}

class _FormUjianState extends State<_FormUjian> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulC;
  late String _jenis;
  late String _kelas;
  late DateTime _tanggalUjian;
  late TimeOfDay _waktu;
  late double _durasi;
  String? _error;

  @override
  void initState() {
    super.initState();
    final a = widget.awal;
    final besok = DateTime.now().add(const Duration(days: 1));
    _judulC = TextEditingController(text: a?.judul ?? '');
    _jenis = a?.jenis ?? 'Kuis';
    _kelas = a?.kelas ?? _kelasGuru.first;
    _tanggalUjian = a == null
        ? DateTime(besok.year, besok.month, besok.day)
        : DateTime(a.mulai.year, a.mulai.month, a.mulai.day);
    _waktu = a == null
        ? const TimeOfDay(hour: 8, minute: 0)
        : TimeOfDay(hour: a.mulai.hour, minute: a.mulai.minute);
    final d = (a?.durasi ?? 30).toDouble();
    _durasi = d < 10 ? 10 : (d > 180 ? 180 : d);
  }

  @override
  void dispose() {
    _judulC.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final sekarang = DateTime.now();
    final batasAwal = DateTime(sekarang.year, sekarang.month, sekarang.day);
    final awal = _tanggalUjian.isBefore(batasAwal) ? batasAwal : _tanggalUjian;

    final hasil = await showDatePicker(
      context: context,
      initialDate: awal,
      firstDate: batasAwal,
      lastDate: batasAwal.add(const Duration(days: 365)),
    );
    if (hasil == null || !mounted) return;
    setState(() {
      _tanggalUjian = hasil;
      _error = null;
    });
  }

  Future<void> _pilihWaktu() async {
    final hasil = await showTimePicker(context: context, initialTime: _waktu);
    if (hasil == null || !mounted) return;
    setState(() {
      _waktu = hasil;
      _error = null;
    });
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final mulai = DateTime(
      _tanggalUjian.year,
      _tanggalUjian.month,
      _tanggalUjian.day,
      _waktu.hour,
      _waktu.minute,
    );
    if (!mulai.isAfter(DateTime.now())) {
      setState(() => _error = 'Waktu ujian harus di masa depan');
      return;
    }

    Navigator.of(context).pop(
      _IsiUjian(_judulC.text.trim(), _jenis, _kelas, mulai, _durasi.round()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final edit = widget.awal != null;
    final tampilWaktu =
        '${_waktu.hour.toString().padLeft(2, '0')}.${_waktu.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                edit ? 'Ubah jadwal ujian' : 'Buat ujian baru',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _judulC,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nama ujian',
                  prefixIcon: Icon(Icons.quiz_rounded),
                ),
                validator: (v) => (v == null || v.trim().length < 3)
                    ? 'Nama minimal 3 karakter'
                    : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Jenis',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: [
                    for (final j in _jenisList)
                      ButtonSegment(value: j, label: Text(j)),
                  ],
                  selected: {_jenis},
                  onSelectionChanged: (s) => setState(() => _jenis = s.first),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kelas',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final k in _kelasGuru)
                    ChoiceChip(
                      label: Text(k),
                      selected: _kelas == k,
                      onSelected: (_) => setState(() => _kelas = k),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pilihTanggal,
                      icon: const Icon(Icons.event_rounded),
                      label: Text(
                        '${_tanggalUjian.day} ${_bulan[_tanggalUjian.month - 1]} ${_tanggalUjian.year}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pilihWaktu,
                      icon: const Icon(Icons.schedule_rounded),
                      label: Text(tampilWaktu),
                    ),
                  ),
                ],
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 12.5,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Durasi',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '${_durasi.round()} menit',
                    style: const TextStyle(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _durasi,
                min: 10,
                max: 180,
                divisions: 34,
                label: '${_durasi.round()} menit',
                onChanged: (v) => setState(() => _durasi = v),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _simpan,
                child: Text(edit ? 'Simpan perubahan' : 'Jadwalkan ujian'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Layar 4: form soal pilihan ganda (bottom sheet)
// ---------------------------------------------------------------------------

class _FormSoal extends StatefulWidget {
  const _FormSoal();

  @override
  State<_FormSoal> createState() => _FormSoalState();
}

class _FormSoalState extends State<_FormSoal> {
  final _formKey = GlobalKey<FormState>();
  final _tanyaC = TextEditingController();
  final List<TextEditingController> _opsiC = List.generate(
    4,
        (_) => TextEditingController(),
  );
  int _kunci = 0;

  @override
  void dispose() {
    _tanyaC.dispose();
    for (final c in _opsiC) {
      c.dispose();
    }
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      _Soal(_tanyaC.text.trim(), [
        for (final c in _opsiC) c.text.trim(),
      ], _kunci),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tambah soal',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tanyaC,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Pertanyaan',
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.trim().length < 5)
                    ? 'Pertanyaan minimal 5 karakter'
                    : null,
              ),
              const SizedBox(height: 14),
              for (var i = 0; i < 4; i++) ...[
                TextFormField(
                  controller: _opsiC[i],
                  decoration: InputDecoration(
                    labelText: 'Pilihan ${_hurufOpsi[i]}',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Pilihan ${_hurufOpsi[i]} wajib diisi'
                      : null,
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 6),
              const Text(
                'Kunci jawaban',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (var i = 0; i < 4; i++)
                    ChoiceChip(
                      label: Text(_hurufOpsi[i]),
                      selected: _kunci == i,
                      onSelected: (_) => setState(() => _kunci = i),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _simpan,
                child: const Text('Simpan soal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}