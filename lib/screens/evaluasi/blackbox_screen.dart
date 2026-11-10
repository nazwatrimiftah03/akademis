import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/kasus_uji.dart';
import '../../services/blackbox_service.dart';

const _hijau = Color(0xFF16A34A);
const _merah = Color(0xFFDC2626);

enum _Filter { semua, belum, berhasil, gagal }

class BlackBoxScreen extends StatefulWidget {
  const BlackBoxScreen({super.key});

  @override
  State<BlackBoxScreen> createState() => _BlackBoxScreenState();
}

class _BlackBoxScreenState extends State<BlackBoxScreen> {
  final _service = BlackBoxService();

  List<KasusUji> _kasus = [];
  Map<int, HasilUji> _hasil = {};
  bool _memuat = true;
  String? _error;
  _Filter _filter = _Filter.semua;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    setState(() {
      _memuat = true;
      _error = null;
    });
    try {
      final k = await _service.ambilKasus();
      final h = await _service.ambilHasilSaya();
      if (!mounted) return;
      setState(() {
        _kasus = k;
        _hasil = h;
        _memuat = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = BlackBoxService.pesanError(e);
        _memuat = false;
      });
    }
  }

  int get _berhasil =>
      _kasus.where((k) => _hasil[k.id]?.status == 'berhasil').length;
  int get _gagal =>
      _kasus.where((k) => _hasil[k.id]?.status == 'gagal').length;
  int get _belum => _kasus.length - _berhasil - _gagal;

  bool _lolos(KasusUji k) {
    final s = _hasil[k.id]?.status;
    return switch (_filter) {
      _Filter.semua => true,
      _Filter.belum => s == null,
      _Filter.berhasil => s == 'berhasil',
      _Filter.gagal => s == 'gagal',
    };
  }

  void _snack(String teks) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks)));
  }

  Future<void> _buka(KasusUji k) async {
    final hasil = await showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _SheetHasil(kasus: k, awal: _hasil[k.id]),
    );
    if (hasil == null || !mounted) return;

    try {
      await _service.simpan(
        kasusId: k.id,
        status: hasil.$1,
        catatan: hasil.$2,
      );
      if (!mounted) return;
      setState(() {
        _hasil[k.id] = HasilUji(
          kasusId: k.id,
          status: hasil.$1,
          catatan: hasil.$2,
        );
      });
      _snack('Hasil ${k.kode} tersimpan');
    } catch (e) {
      if (!mounted) return;
      _snack(BlackBoxService.pesanError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Black Box Testing'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _memuat ? null : _muat,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _memuat
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _galat()
              : _isi(),
    );
  }

  Widget _galat() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 80,
              color: Color(0xFFD97706),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, height: 1.5),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _muat, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }

  Widget _isi() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = dark ? const Color(0xFF16231F) : Colors.white;

    final total = _kasus.length;
    final persen = total == 0 ? 0.0 : _berhasil / total * 100;

    final kelompok = <String, List<KasusUji>>{};
    for (final k in _kasus.where(_lolos)) {
      kelompok.putIfAbsent(k.fitur, () => []).add(k);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.teal, AppColors.tealLight],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Skor Black Box',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                '${persen.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$_berhasil berhasil dari $total kasus uji',
                style: const TextStyle(color: Colors.white70, fontSize: 12.5),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : (_berhasil + _gagal) / total,
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_berhasil + _gagal} dari $total sudah diuji',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _stat('$_berhasil', 'Berhasil', _hijau, cardColor),
            const SizedBox(width: 10),
            _stat('$_gagal', 'Gagal', _merah, cardColor),
            const SizedBox(width: 10),
            _stat('$_belum', 'Belum', AppColors.muted, cardColor),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          children: [
            for (final f in _Filter.values)
              ChoiceChip(
                label: Text(switch (f) {
                  _Filter.semua => 'Semua',
                  _Filter.belum => 'Belum',
                  _Filter.berhasil => 'Berhasil',
                  _Filter.gagal => 'Gagal',
                }),
                selected: _filter == f,
                onSelected: (_) => setState(() => _filter = f),
              ),
          ],
        ),
        if (kelompok.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'Tidak ada kasus uji pada filter ini.',
                style: TextStyle(color: AppColors.muted),
              ),
            ),
          ),
        for (final e in kelompok.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 8),
            child: Text(
              e.key,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
          for (final k in e.value) _kartuKasus(k, cardColor),
        ],
      ],
    );
  }

  Widget _stat(String nilai, String label, Color warna, Color cardColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              nilai,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: warna,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kartuKasus(KasusUji k, Color cardColor) {
    final s = _hasil[k.id]?.status;
    final (ikon, warna) = switch (s) {
      'berhasil' => (Icons.check_circle_rounded, _hijau),
      'gagal' => (Icons.cancel_rounded, _merah),
      _ => (Icons.radio_button_unchecked_rounded, AppColors.muted),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _buka(k),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(ikon, color: warna),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        k.kode,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        k.skenario,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetHasil extends StatefulWidget {
  const _SheetHasil({required this.kasus, required this.awal});

  final KasusUji kasus;
  final HasilUji? awal;

  @override
  State<_SheetHasil> createState() => _SheetHasilState();
}

class _SheetHasilState extends State<_SheetHasil> {
  late String? _status = widget.awal?.status;
  late final TextEditingController _catatanC = TextEditingController(
    text: widget.awal?.catatan ?? '',
  );
  String? _error;

  @override
  void dispose() {
    _catatanC.dispose();
    super.dispose();
  }

  void _simpan() {
    if (_status == null) {
      setState(() => _error = 'Pilih hasil pengujian dulu.');
      return;
    }
    final catatan = _catatanC.text.trim();
    if (_status == 'gagal' && catatan.isEmpty) {
      setState(() => _error = 'Tuliskan apa yang tidak sesuai.');
      return;
    }
    Navigator.of(context).pop((_status!, catatan));
  }

  Widget _blok(String judul, String isi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(isi, style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }

  Widget _pilih(String nilai, String label, IconData ikon, Color warna) {
    final aktif = _status == nilai;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _status = nilai;
          _error = null;
        }),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: aktif ? warna : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: aktif
                  ? warna
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(ikon, size: 20, color: aktif ? Colors.white : warna),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: aktif ? Colors.white : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.kasus;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    k.kode,
                    style: const TextStyle(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    k.fitur,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              k.skenario,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            _blok('Karakteristik ISO 25010', k.karakteristik),
            _blok('Langkah pengujian', k.langkah),
            _blok('Hasil yang diharapkan', k.hasilDiharapkan),
            const Text(
              'Hasil pengujianmu',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _pilih('berhasil', 'Berhasil', Icons.check_circle_rounded,
                    _hijau),
                _pilih('gagal', 'Gagal', Icons.cancel_rounded, _merah),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _catatanC,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Catatan (wajib jika gagal)',
                alignLabelWithHint: true,
                errorText: _error,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _simpan,
              child: const Text('Simpan hasil'),
            ),
          ],
        ),
      ),
    );
  }
}
