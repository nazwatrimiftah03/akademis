import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_theme.dart';
import '../../models/jadwal.dart';
import '../../services/jadwal_service.dart';

const _hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
const _kKelas = 'jadwal_kelas_siswa';

class JadwalSiswaScreen extends StatefulWidget {
  const JadwalSiswaScreen({super.key});

  @override
  State<JadwalSiswaScreen> createState() => _JadwalSiswaScreenState();
}

class _JadwalSiswaScreenState extends State<JadwalSiswaScreen> {
  final _service = JadwalService();

  List<Jadwal> _data = [];
  String? _kelas;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  List<String> get _daftarKelas {
    final set = _data.map((j) => j.kelas).toSet().toList()..sort();
    return set;
  }

  Future<void> _muat({bool diam = false}) async {
    if (!diam) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final hasil = await _service.ambilSemua();
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final kelasAda = hasil.map((j) => j.kelas).toSet();
      final tersimpan = prefs.getString(_kKelas);
      setState(() {
        _data = hasil;
        _kelas = (tersimpan != null && kelasAda.contains(tersimpan))
            ? tersimpan
            : (_kelas != null && kelasAda.contains(_kelas))
            ? _kelas
            : (kelasAda.isEmpty ? null : (kelasAda.toList()..sort()).first);
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

  Future<void> _pilihKelas(String k) async {
    setState(() => _kelas = k);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKelas, k);
  }

  List<Jadwal> _untukHari(String hari) {
    final hasil = _data
        .where((j) => j.hari == hari && j.kelas == _kelas)
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
            tabs: [for (final h in _hari) Tab(text: h)],
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

    final kelasList = _daftarKelas;
    return Column(
      children: [
        if (kelasList.isNotEmpty)
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              itemCount: kelasList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) => ChoiceChip(
                label: Text(kelasList[i]),
                selected: _kelas == kelasList[i],
                onSelected: (_) => _pilihKelas(kelasList[i]),
              ),
            ),
          ),
        Expanded(
          child: TabBarView(
            children: [
              for (final h in _hari)
                _DayList(
                  items: _untukHari(h),
                  onRefresh: () => _muat(diam: true),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DayList extends StatelessWidget {
  const _DayList({required this.items, required this.onRefresh});

  final List<Jadwal> items;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = dark ? const Color(0xFF16231F) : Colors.white;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: items.isEmpty
          ? ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(
            child: Text(
              'Tidak ada pelajaran',
              style: TextStyle(color: AppColors.muted),
            ),
          ),
        ],
      )
          : ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final p = items[i];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
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
                    p.jam,
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
                        p.mapel,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${p.guru}  •  ${p.ruang}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
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