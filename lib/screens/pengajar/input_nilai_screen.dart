import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

const _komponen = ['Tugas', 'UTS', 'UAS'];

class InputNilaiScreen extends StatefulWidget {
  const InputNilaiScreen({super.key});

  @override
  State<InputNilaiScreen> createState() => _InputNilaiScreenState();
}

class _InputNilaiScreenState extends State<InputNilaiScreen> {
  String _pilih = _kelas.keys.first;
  String _jenis = _komponen.first;

  // Kunci: 'kelas|nama|komponen' -> teks yang diketik.
  final Map<String, String> _isi = {};

  String _kunci(String nama) => '$_pilih|$nama|$_jenis';

  /// Kembalikan nilai valid (0-100) atau null kalau kosong / tidak valid.
  int? _angka(String nama) {
    final n = int.tryParse(_isi[_kunci(nama)] ?? '');
    if (n == null || n < 0 || n > 100) return null;
    return n;
  }

  bool _salah(String nama) {
    final t = _isi[_kunci(nama)] ?? '';
    if (t.isEmpty) return false;
    final n = int.tryParse(t);
    return n == null || n < 0 || n > 100;
  }

  void _simpan() {
    final siswa = _kelas[_pilih]!;

    if (siswa.any(_salah)) {
      _toast('Ada nilai yang tidak valid. Isi angka 0 sampai 100.');
      return;
    }

    final terisi = siswa.map(_angka).whereType<int>().toList();
    if (terisi.isEmpty) {
      _toast('Belum ada nilai yang diisi.');
      return;
    }

    final rata = terisi.reduce((a, b) => a + b) / terisi.length;
    _toast(
      '${terisi.length} nilai $_jenis $_pilih tersimpan. '
          'Rata-rata ${rata.toStringAsFixed(1)}',
    );
  }

  void _toast(String teks) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks)));
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = dark ? const Color(0xFF16231F) : Colors.white;
    final siswa = _kelas[_pilih]!;

    final terisi = siswa.map(_angka).whereType<int>().toList();
    final rata = terisi.isEmpty
        ? null
        : terisi.reduce((a, b) => a + b) / terisi.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Nilai'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
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
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: [
                  for (final k in _komponen)
                    ButtonSegment(value: k, label: Text(k)),
                ],
                selected: {_jenis},
                onSelectionChanged: (s) => setState(() => _jenis = s.first),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
            child: Row(
              children: [
                Text(
                  'Terisi ${terisi.length} dari ${siswa.length}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                const Spacer(),
                Text(
                  rata == null
                      ? 'Rata-rata -'
                      : 'Rata-rata ${rata.toStringAsFixed(1)}',
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              itemCount: siswa.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final nama = siswa[i];
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${i + 1}. $nama',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        width: 96,
                        child: TextFormField(
                          key: ValueKey(_kunci(nama)),
                          initialValue: _isi[_kunci(nama)] ?? '',
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 3,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            hintText: '0-100',
                            counterText: '',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
                            errorText: _salah(nama) ? 'Maks 100' : null,
                          ),
                          onChanged: (v) =>
                              setState(() => _isi[_kunci(nama)] = v),
                        ),
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
                child: Text('Simpan Nilai $_jenis'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}