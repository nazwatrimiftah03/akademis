import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/pengumuman_store.dart';
import '../../widgets/pengumuman_section.dart';

const _merahPenting = Color(0xFFE11D48);

class PengumumanAdminScreen extends StatefulWidget {
  const PengumumanAdminScreen({super.key});

  @override
  State<PengumumanAdminScreen> createState() => _PengumumanAdminScreenState();
}

class _PengumumanAdminScreenState extends State<PengumumanAdminScreen> {
  String _filter = 'Semua';

  void _toast(String teks, {SnackBarAction? aksi}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks), action: aksi));
  }

  Future<void> _buka({Pengumuman? awal}) async {
    final hasil = await showModalBottomSheet<Pengumuman>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FormPengumuman(awal: awal),
    );
    if (hasil == null || !mounted) return;

    try {
      if (awal == null) {
        await PengumumanStore.tambah(hasil);
        if (!mounted) return;
        _toast('Pengumuman dikirim ke ${hasil.untuk.toLowerCase()}');
      } else {
        await PengumumanStore.ubah(hasil);
        if (!mounted) return;
        _toast('Pengumuman diperbarui');
      }
    } catch (e) {
      if (!mounted) return;
      _toast(PengumumanStore.pesanError(e));
    }
  }

  Future<void> _hapus(Pengumuman p) async {
    try {
      await PengumumanStore.hapus(p.id);
    } catch (e) {
      if (!mounted) return;
      _toast(PengumumanStore.pesanError(e));
      return;
    }
    if (!mounted) return;
    _toast(
      'Pengumuman dihapus',
      aksi: SnackBarAction(
        label: 'Urungkan',
        onPressed: () async {
          try {
            await PengumumanStore.tambah(p);
          } catch (e) {
            if (!mounted) return;
            _toast(PengumumanStore.pesanError(e));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = dark ? const Color(0xFF16231F) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _buka(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Buat pengumuman'),
      ),
      body: ValueListenableBuilder<List<Pengumuman>>(
        valueListenable: PengumumanStore.daftar,
        builder: (context, semua, _) {
          final items = semua
              .where((p) => _filter == 'Semua' || p.untuk == _filter)
              .toList();

          return RefreshIndicator(
            onRefresh: PengumumanStore.segarkan,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
              children: [
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: sasaranPengumuman.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final s = sasaranPengumuman[i];
                      return ChoiceChip(
                        label: Text(s),
                        selected: _filter == s,
                        onSelected: (_) => setState(() => _filter = s),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        Icon(
                          Icons.campaign_outlined,
                          size: 56,
                          color: AppColors.muted,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Belum ada pengumuman',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  )
                else
                  for (final p in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: ValueKey(p.id),
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
                        onDismissed: (_) => _hapus(p),
                        child: Material(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _buka(awal: p),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (p.penting) ...[
                                        const LabelPengumuman(
                                          'Penting',
                                          _merahPenting,
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      LabelPengumuman(
                                        'Untuk ${p.untuk}',
                                        AppColors.teal,
                                      ),
                                      const Spacer(),
                                      Text(
                                        waktuRelatif(p.waktu),
                                        style: const TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    p.judul,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    p.isi,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
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
        },
      ),
    );
  }
}

class _FormPengumuman extends StatefulWidget {
  const _FormPengumuman({this.awal});

  final Pengumuman? awal;

  @override
  State<_FormPengumuman> createState() => _FormPengumumanState();
}

class _FormPengumumanState extends State<_FormPengumuman> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulC;
  late final TextEditingController _isiC;
  late String _untuk;
  late bool _penting;

  @override
  void initState() {
    super.initState();
    final a = widget.awal;
    _judulC = TextEditingController(text: a?.judul ?? '');
    _isiC = TextEditingController(text: a?.isi ?? '');
    _untuk = a?.untuk ?? 'Semua';
    _penting = a?.penting ?? false;
  }

  @override
  void dispose() {
    _judulC.dispose();
    _isiC.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final a = widget.awal;
    Navigator.of(context).pop(
      Pengumuman(
        id: a?.id ?? 0,
        judul: _judulC.text.trim(),
        isi: _isiC.text.trim(),
        untuk: _untuk,
        waktu: a?.waktu ?? DateTime.now(),
        penting: _penting,
      ),
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
                edit ? 'Ubah pengumuman' : 'Buat pengumuman',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _judulC,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (v) => (v == null || v.trim().length < 5)
                    ? 'Judul minimal 5 karakter'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _isiC,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Isi pengumuman',
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.trim().length < 10)
                    ? 'Isi minimal 10 karakter'
                    : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Ditujukan untuk',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final s in sasaranPengumuman)
                    ChoiceChip(
                      label: Text(s),
                      selected: _untuk == s,
                      onSelected: (_) => setState(() => _untuk = s),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tandai penting'),
                subtitle: const Text('Ditampilkan dengan ikon merah'),
                value: _penting,
                onChanged: (v) => setState(() => _penting = v),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _simpan,
                child: Text(edit ? 'Simpan perubahan' : 'Kirim pengumuman'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}