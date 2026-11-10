import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

// Jumlah siswa per kelas (data contoh).
const _ukuranKelas = {
  'X IPA 1': 32,
  'X IPA 2': 30,
  'XI IPS 1': 34,
};

const _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String _format(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

class _TugasGuru {
  _TugasGuru(this.judul, this.kelas, this.tenggat, this.terkumpul);

  final String judul;
  final String kelas;
  final String tenggat;
  final int terkumpul;

  int get total => _ukuranKelas[kelas] ?? 0;
}

class TugasGuruScreen extends StatefulWidget {
  const TugasGuruScreen({super.key});

  @override
  State<TugasGuruScreen> createState() => _TugasGuruScreenState();
}

class _TugasGuruScreenState extends State<TugasGuruScreen> {
  final _tugas = <_TugasGuru>[
    _TugasGuru('Latihan Soal Turunan', 'X IPA 1', '28 Okt 2026', 24),
    _TugasGuru('Ulangan Harian Limit', 'X IPA 2', '30 Okt 2026', 18),
    _TugasGuru('Soal Statistika', 'XI IPS 1', '25 Okt 2026', 34),
  ];

  Future<void> _buat() async {
    final hasil = await showModalBottomSheet<(String, String, String)>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _FormTugas(),
    );
    if (hasil == null || !mounted) return;

    setState(() {
      _tugas.insert(0, _TugasGuru(hasil.$1, hasil.$2, hasil.$3, 0));
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Tugas "${hasil.$1}" dibuat untuk ${hasil.$2}')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = dark ? const Color(0xFF16231F) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _buat,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Buat tugas'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
        itemCount: _tugas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final t = _tugas[i];
          final lengkap = t.terkumpul >= t.total;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kelas ${t.kelas}',
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.judul,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tenggat ${t.tenggat}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: t.total == 0 ? 0 : t.terkumpul / t.total,
                    minHeight: 8,
                    backgroundColor: AppColors.teal.withValues(alpha: 0.15),
                    color: lengkap ? const Color(0xFF16A34A) : AppColors.teal,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${t.terkumpul} dari ${t.total} siswa mengumpulkan',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FormTugas extends StatefulWidget {
  const _FormTugas();

  @override
  State<_FormTugas> createState() => _FormTugasState();
}

class _FormTugasState extends State<_FormTugas> {
  final _judulC = TextEditingController();
  String _kelas = _ukuranKelas.keys.first;
  DateTime? _tanggal;
  String? _error;

  @override
  void dispose() {
    _judulC.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final now = DateTime.now();
    final hariIni = DateTime(now.year, now.month, now.day);
    final d = await showDatePicker(
      context: context,
      initialDate: _tanggal ?? hariIni.add(const Duration(days: 3)),
      firstDate: hariIni,
      lastDate: hariIni.add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _tanggal = d);
  }

  void _simpan() {
    final judul = _judulC.text.trim();
    if (judul.length < 3) {
      setState(() => _error = 'Judul minimal 3 karakter');
      return;
    }
    if (_tanggal == null) {
      setState(() => _error = 'Pilih tanggal tenggat dulu');
      return;
    }
    Navigator.of(context).pop((judul, _kelas, _format(_tanggal!)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Buat tugas baru',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _judulC,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Judul tugas'),
            ),
            const SizedBox(height: 16),
            const Text('Untuk kelas', style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final k in _ukuranKelas.keys)
                  ChoiceChip(
                    label: Text(k),
                    selected: _kelas == k,
                    onSelected: (_) => setState(() => _kelas = k),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pilihTanggal,
              icon: const Icon(Icons.event_rounded),
              label: Text(
                _tanggal == null
                    ? 'Pilih tanggal tenggat'
                    : 'Tenggat: ${_format(_tanggal!)}',
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _simpan, child: const Text('Buat tugas')),
          ],
        ),
      ),
    );
  }
}