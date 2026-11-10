import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

// ---------------------------------------------------------------------------
// Data & helper
// ---------------------------------------------------------------------------

const _mapelGuru = 'Matematika';

const _kelasGuru = ['X IPA 1', 'X IPA 2', 'XI IPS 1'];

// Jumlah siswa per kelas (data contoh).
const _ukuranKelas = {'X IPA 1': 32, 'X IPA 2': 30, 'XI IPS 1': 34};

const _jenisList = ['PDF', 'Video', 'Slide'];

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

String _format(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

IconData _ikon(String jenis) => switch (jenis) {
  'Video' => Icons.play_circle_rounded,
  'Slide' => Icons.slideshow_rounded,
  _ => Icons.picture_as_pdf_rounded,
};

Color _warna(String jenis) => switch (jenis) {
  'Video' => const Color(0xFFE11D48),
  'Slide' => const Color(0xFFF59E0B),
  _ => const Color(0xFF2563EB),
};

Color _kartu(BuildContext context) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return dark ? const Color(0xFF16231F) : Colors.white;
}

class _Materi {
  _Materi({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.jenis,
    required this.tanggal,
    required this.terbit,
    required this.dibaca,
  });

  final int id;
  String judul;
  String deskripsi;
  String jenis;
  DateTime tanggal;
  bool terbit;

  /// Jumlah siswa yang sudah membuka materi, per kelas.
  Map<String, int> dibaca;

  List<String> get kelas =>
      _kelasGuru.where((k) => dibaca.containsKey(k)).toList();

  int get totalDibaca => dibaca.values.fold(0, (a, b) => a + b);

  int get target => kelas.fold(0, (a, k) => a + (_ukuranKelas[k] ?? 0));

  double get progres => target == 0 ? 0 : totalDibaca / target;
}

/// Isi form tambah / ubah materi.
class _Isi {
  const _Isi(this.judul, this.deskripsi, this.jenis, this.kelas, this.terbit);

  final String judul;
  final String deskripsi;
  final String jenis;
  final Set<String> kelas;
  final bool terbit;
}

// ---------------------------------------------------------------------------
// Layar 1: daftar materi
// ---------------------------------------------------------------------------

class MateriGuruScreen extends StatefulWidget {
  const MateriGuruScreen({super.key});

  @override
  State<MateriGuruScreen> createState() => _MateriGuruScreenState();
}

class _MateriGuruScreenState extends State<MateriGuruScreen> {
  int _nextId = 6;
  String _cari = '';
  String _filterKelas = 'Semua';
  String _filterJenis = 'Semua';

  final List<_Materi> _data = [
    _Materi(
      id: 1,
      judul: 'Turunan Fungsi Aljabar',
      deskripsi:
      'Pengantar konsep turunan, aturan pangkat, dan contoh soal latihan.',
      jenis: 'PDF',
      tanggal: DateTime(2026, 10, 22),
      terbit: true,
      dibaca: {'X IPA 1': 28, 'X IPA 2': 21},
    ),
    _Materi(
      id: 2,
      judul: 'Limit dan Kekontinuan',
      deskripsi: 'Rekaman penjelasan limit fungsi dan cara menentukannya.',
      jenis: 'Video',
      tanggal: DateTime(2026, 10, 15),
      terbit: true,
      dibaca: {'X IPA 1': 30, 'X IPA 2': 25, 'XI IPS 1': 12},
    ),
    _Materi(
      id: 3,
      judul: 'Statistika Dasar',
      deskripsi: 'Slide ukuran pemusatan dan penyebaran data.',
      jenis: 'Slide',
      tanggal: DateTime(2026, 10, 20),
      terbit: true,
      dibaca: {'XI IPS 1': 29},
    ),
    _Materi(
      id: 4,
      judul: 'Integral Tak Tentu',
      deskripsi: 'Materi persiapan untuk bab berikutnya. Belum diterbitkan.',
      jenis: 'PDF',
      tanggal: DateTime(2026, 10, 24),
      terbit: false,
      dibaca: {'X IPA 1': 0},
    ),
    _Materi(
      id: 5,
      judul: 'Peluang dan Kombinatorika',
      deskripsi: 'Video latihan soal peluang kejadian majemuk.',
      jenis: 'Video',
      tanggal: DateTime(2026, 10, 12),
      terbit: true,
      dibaca: {'X IPA 2': 18, 'XI IPS 1': 22},
    ),
  ];

  List<_Materi> get _tersaring {
    final q = _cari.trim().toLowerCase();
    final hasil = _data.where((m) {
      if (_filterKelas != 'Semua' && !m.kelas.contains(_filterKelas)) {
        return false;
      }
      if (_filterJenis != 'Semua' && m.jenis != _filterJenis) return false;
      if (q.isNotEmpty && !m.judul.toLowerCase().contains(q)) return false;
      return true;
    }).toList();
    hasil.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return hasil;
  }

  void _toast(String teks, {SnackBarAction? aksi}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks), action: aksi));
  }

  Future<_Isi?> _bukaForm({_Materi? awal}) {
    return showModalBottomSheet<_Isi>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FormMateri(awal: awal),
    );
  }

  Future<void> _tambah() async {
    final isi = await _bukaForm();
    if (isi == null || !mounted) return;

    setState(() {
      _data.add(
        _Materi(
          id: _nextId++,
          judul: isi.judul,
          deskripsi: isi.deskripsi,
          jenis: isi.jenis,
          tanggal: DateTime.now(),
          terbit: isi.terbit,
          dibaca: {for (final k in isi.kelas) k: 0},
        ),
      );
    });
    _toast(
      isi.terbit
          ? 'Materi "${isi.judul}" diterbitkan'
          : 'Materi "${isi.judul}" disimpan sebagai draft',
    );
  }

  Future<void> _ubah(_Materi m) async {
    final isi = await _bukaForm(awal: m);
    if (isi == null || !mounted) return;

    setState(() {
      m.judul = isi.judul;
      m.deskripsi = isi.deskripsi;
      m.jenis = isi.jenis;
      m.terbit = isi.terbit;
      m.dibaca.removeWhere((k, _) => !isi.kelas.contains(k));
      for (final k in isi.kelas) {
        m.dibaca.putIfAbsent(k, () => 0);
      }
    });
    _toast('Perubahan disimpan');
  }

  void _hapus(_Materi m) {
    final index = _data.indexOf(m);
    if (index < 0) return;
    setState(() => _data.removeAt(index));
    _toast(
      'Materi "${m.judul}" dihapus',
      aksi: SnackBarAction(
        label: 'Urungkan',
        onPressed: () {
          if (!mounted) return;
          setState(() {
            final pos = index > _data.length ? _data.length : index;
            _data.insert(pos, m);
          });
        },
      ),
    );
  }

  void _bukaDetail(_Materi m) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _DetailMateri(
          materi: m,
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
    final daftar = _tersaring;
    final terbit = _data.where((m) => m.terbit).length;
    final draft = _data.length - terbit;
    final dibuka = _data.where((m) => m.terbit && m.target > 0).toList();
    final rata = dibuka.isEmpty
        ? 0
        : (dibuka.map((m) => m.progres).reduce((a, b) => a + b) /
        dibuka.length *
        100)
        .round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materi'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambah,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah materi'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        children: [
          _Hero(total: _data.length, terbit: terbit, draft: draft, rata: rata),
          const SizedBox(height: 18),
          TextField(
            onChanged: (v) => setState(() => _cari = v),
            decoration: const InputDecoration(
              hintText: 'Cari judul materi',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 12),
          _BarisChip(
            pilihan: const ['Semua', ..._kelasGuru],
            terpilih: _filterKelas,
            onPilih: (v) => setState(() => _filterKelas = v),
          ),
          const SizedBox(height: 6),
          _BarisChip(
            pilihan: const ['Semua', ..._jenisList],
            terpilih: _filterJenis,
            onPilih: (v) => setState(() => _filterJenis = v),
          ),
          const SizedBox(height: 14),
          if (daftar.isEmpty)
            const _Kosong()
          else
            for (final m in daftar)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: ValueKey(m.id),
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
                  onDismissed: (_) => _hapus(m),
                  child: _KartuMateri(materi: m, onTap: () => _bukaDetail(m)),
                ),
              ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.total,
    required this.terbit,
    required this.draft,
    required this.rata,
  });

  final int total;
  final int terbit;
  final int draft;
  final int rata;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
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
            // Lapisan dekorasi di belakang.
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
              right: 40,
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
            // Lapisan isi.
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bank materi',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 2),
                Text(
                  '$total materi $_mapelGuru',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _StatKecil('$terbit', 'Terbit')),
                    const SizedBox(width: 10),
                    Expanded(child: _StatKecil('$draft', 'Draft')),
                    const SizedBox(width: 10),
                    Expanded(child: _StatKecil('$rata%', 'Rata dibaca')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatKecil extends StatelessWidget {
  const _StatKecil(this.angka, this.label);

  final String angka;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            angka,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

class _BarisChip extends StatelessWidget {
  const _BarisChip({
    required this.pilihan,
    required this.terpilih,
    required this.onPilih,
  });

  final List<String> pilihan;
  final String terpilih;
  final ValueChanged<String> onPilih;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pilihan.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final p = pilihan[i];
          return ChoiceChip(
            label: Text(p),
            selected: terpilih == p,
            onSelected: (_) => onPilih(p),
          );
        },
      ),
    );
  }
}

class _Kosong extends StatelessWidget {
  const _Kosong();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.folder_open_rounded, size: 56, color: AppColors.muted),
          SizedBox(height: 12),
          Text(
            'Belum ada materi yang cocok',
            style: TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _KartuMateri extends StatelessWidget {
  const _KartuMateri({required this.materi, required this.onTap});

  final _Materi materi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final warna = _warna(materi.jenis);

    return Material(
      color: _kartu(context),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: warna.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_ikon(materi.jenis), color: warna, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          materi.judul,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${materi.jenis}  •  ${_format(materi.tanggal)}',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _LabelStatus(terbit: materi.terbit),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final k in materi.kelas)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        k,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.teal,
                        ),
                      ),
                    ),
                ],
              ),
              if (materi.terbit) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: materi.progres.clamp(0.0, 1.0),
                    minHeight: 7,
                    backgroundColor: AppColors.teal.withValues(alpha: 0.12),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${materi.totalDibaca} dari ${materi.target} siswa sudah membuka',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LabelStatus extends StatelessWidget {
  const _LabelStatus({required this.terbit});

  final bool terbit;

  @override
  Widget build(BuildContext context) {
    final warna = terbit ? AppColors.teal : AppColors.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        terbit ? 'Terbit' : 'Draft',
        style: TextStyle(
          color: warna,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Layar 2: detail materi
// ---------------------------------------------------------------------------

class _DetailMateri extends StatefulWidget {
  const _DetailMateri({
    required this.materi,
    required this.onChanged,
    required this.onUbah,
    required this.onHapus,
  });

  final _Materi materi;
  final VoidCallback onChanged;
  final Future<void> Function(_Materi) onUbah;
  final void Function(_Materi) onHapus;

  @override
  State<_DetailMateri> createState() => _DetailMateriState();
}

class _DetailMateriState extends State<_DetailMateri> {
  Future<void> _konfirmasiHapus() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus "${widget.materi.judul}"?'),
        content: const Text('Materi akan hilang dari daftar siswa.'),
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
    widget.onHapus(widget.materi);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.materi;
    final warna = _warna(m.jenis);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail materi'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: 'Ubah',
            icon: const Icon(Icons.edit_rounded),
            onPressed: () async {
              await widget.onUbah(m);
              if (mounted) setState(() {});
            },
          ),
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
          // Lapisan 1: kartu judul.
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
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(_ikon(m.jenis), color: Colors.white, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.judul,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${m.jenis}  •  $_mapelGuru  •  ${_format(m.tanggal)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Lapisan 2: status terbit.
          Container(
            decoration: BoxDecoration(
              color: _kartu(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18),
              title: const Text(
                'Terbitkan ke siswa',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                m.terbit
                    ? 'Siswa di kelas terpilih bisa membuka materi ini.'
                    : 'Masih draft. Siswa belum bisa melihat.',
                style: const TextStyle(fontSize: 12.5),
              ),
              value: m.terbit,
              onChanged: (v) {
                setState(() => m.terbit = v);
                widget.onChanged();
              },
            ),
          ),
          const SizedBox(height: 16),

          // Lapisan 3: deskripsi.
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
                  'Deskripsi',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  m.deskripsi.isEmpty ? 'Belum ada deskripsi.' : m.deskripsi,
                  style: const TextStyle(color: AppColors.muted, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Lapisan 4: progres dibaca per kelas.
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
                        'Dibuka siswa',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      '${m.totalDibaca}/${m.target}',
                      style: const TextStyle(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                for (final k in m.kelas) ...[
                  _BarisProgres(
                    kelas: k,
                    dibaca: m.dibaca[k] ?? 0,
                    total: _ukuranKelas[k] ?? 0,
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text('Membuka "${m.judul}" (versi contoh)'),
                  ),
                );
            },
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Buka file'),
          ),
        ],
      ),
    );
  }
}

class _BarisProgres extends StatelessWidget {
  const _BarisProgres({
    required this.kelas,
    required this.dibaca,
    required this.total,
  });

  final String kelas;
  final int dibaca;
  final int total;

  @override
  Widget build(BuildContext context) {
    final nilai = total == 0 ? 0.0 : (dibaca / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(kelas, style: const TextStyle(fontSize: 13.5)),
            ),
            Text(
              '$dibaca / $total',
              style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: nilai,
            minHeight: 7,
            backgroundColor: AppColors.teal.withValues(alpha: 0.12),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Layar 3: form tambah / ubah (bottom sheet)
// ---------------------------------------------------------------------------

class _FormMateri extends StatefulWidget {
  const _FormMateri({this.awal});

  final _Materi? awal;

  @override
  State<_FormMateri> createState() => _FormMateriState();
}

class _FormMateriState extends State<_FormMateri> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulC;
  late final TextEditingController _deskC;
  late String _jenis;
  late Set<String> _kelas;
  late bool _terbit;
  bool _kelasKosong = false;

  @override
  void initState() {
    super.initState();
    final a = widget.awal;
    _judulC = TextEditingController(text: a?.judul ?? '');
    _deskC = TextEditingController(text: a?.deskripsi ?? '');
    _jenis = a?.jenis ?? 'PDF';
    _kelas = a == null ? <String>{} : a.kelas.toSet();
    _terbit = a?.terbit ?? true;
  }

  @override
  void dispose() {
    _judulC.dispose();
    _deskC.dispose();
    super.dispose();
  }

  void _simpan() {
    final formOk = _formKey.currentState!.validate();
    final kelasOk = _kelas.isNotEmpty;
    setState(() => _kelasKosong = !kelasOk);
    if (!formOk || !kelasOk) return;

    Navigator.of(context).pop(
      _Isi(_judulC.text.trim(), _deskC.text.trim(), _jenis, _kelas, _terbit),
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                edit ? 'Ubah materi' : 'Tambah materi',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _judulC,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Judul materi',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (v) => (v == null || v.trim().length < 3)
                    ? 'Judul minimal 3 karakter'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _deskC,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (opsional)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Jenis file',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: [
                    for (final j in _jenisList)
                      ButtonSegment(
                        value: j,
                        icon: Icon(_ikon(j)),
                        label: Text(j),
                      ),
                  ],
                  selected: {_jenis},
                  onSelectionChanged: (s) => setState(() => _jenis = s.first),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Untuk kelas',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final k in _kelasGuru)
                    FilterChip(
                      label: Text(k),
                      selected: _kelas.contains(k),
                      onSelected: (v) => setState(() {
                        if (v) {
                          _kelas.add(k);
                        } else {
                          _kelas.remove(k);
                        }
                        _kelasKosong = false;
                      }),
                    ),
                ],
              ),
              if (_kelasKosong)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Pilih minimal satu kelas',
                    style: TextStyle(color: Color(0xFFDC2626), fontSize: 12.5),
                  ),
                ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Terbitkan sekarang'),
                subtitle: const Text('Matikan untuk menyimpan sebagai draft'),
                value: _terbit,
                onChanged: (v) => setState(() => _terbit = v),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _simpan,
                child: Text(edit ? 'Simpan perubahan' : 'Simpan materi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}