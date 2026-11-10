import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class MasterDataScreen extends StatefulWidget {
  const MasterDataScreen({
    super.key,
    required this.judul,
    required this.ikon,
    required this.label,
    required this.hint,
    required this.awal,
  });

  final String judul; // judul halaman, mis. "Kelas"
  final IconData ikon;
  final String label; // untuk dialog, mis. "kelas"
  final String hint;
  final List<String> awal;

  @override
  State<MasterDataScreen> createState() => _MasterDataScreenState();
}

class _MasterDataScreenState extends State<MasterDataScreen> {
  final _inputC = TextEditingController();
  late final List<String> _items = [...widget.awal];

  @override
  void dispose() {
    _inputC.dispose();
    super.dispose();
  }

  void _toast(String teks) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks)));
  }

  Future<void> _tambah() async {
    _inputC.clear();
    String? error;

    final hasil = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text('Tambah ${widget.label}'),
          content: TextField(
            controller: _inputC,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: widget.hint,
              errorText: error,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                final v = _inputC.text.trim();
                if (v.isEmpty) {
                  setDialog(() => error = 'Tidak boleh kosong');
                  return;
                }
                if (_items.any((e) => e.toLowerCase() == v.toLowerCase())) {
                  setDialog(() => error = 'Sudah ada');
                  return;
                }
                Navigator.of(ctx).pop(v);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    if (hasil == null || !mounted) return;
    setState(() => _items.add(hasil));
    _toast('"$hasil" ditambahkan');
  }

  Future<void> _hapus(String nama) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus "$nama"?'),
        content: const Text('Data yang dihapus tidak bisa dikembalikan.'),
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
    setState(() => _items.remove(nama));
    _toast('"$nama" dihapus');
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = dark ? const Color(0xFF16231F) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.judul),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambah,
        icon: const Icon(Icons.add_rounded),
        label: Text('Tambah ${widget.label}'),
      ),
      body: _items.isEmpty
          ? Center(
        child: Text(
          'Belum ada ${widget.label}',
          style: const TextStyle(color: AppColors.muted),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final nama = _items[i];
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.ikon, color: AppColors.teal),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    nama,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Hapus',
                  onPressed: () => _hapus(nama),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFDC2626),
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