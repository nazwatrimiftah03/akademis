import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/jadwal.dart';
import '../../services/auth_service.dart';
import '../../services/jadwal_service.dart';

const _hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

class JadwalMengajarScreen extends StatefulWidget {
  const JadwalMengajarScreen({super.key});

  @override
  State<JadwalMengajarScreen> createState() => _JadwalMengajarScreenState();
}

class _JadwalMengajarScreenState extends State<JadwalMengajarScreen> {
  final _service = JadwalService();

  List<Jadwal> _data = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  String _norm(String s) => s.trim().toLowerCase();

  Future<void> _muat({bool diam = false}) async {
    if (!diam) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final profil = await AuthService().fetchProfile();
      final semua = await _service.ambilSemua();
      if (!mounted) return;
      final nama = _norm(profil?.fullName ?? '');
      setState(() {
        // Jadwal dicocokkan lewat nama pengajar yang dipilih admin.
        _data = nama.isEmpty
            ? []
            : semua.where((j) => _norm(j.guru) == nama).toList();
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

  List<Jadwal> _untukHari(String hari) {
    final hasil = _data.where((j) => j.hari == hari).toList();
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
          title: const Text('Jadwal Mengajar'),
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
    return TabBarView(
      children: [
        for (final h in _hari)
          _DayList(items: _untukHari(h), onRefresh: () => _muat(diam: true)),
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
              'Tidak ada jadwal mengajar',
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
          final s = items[i];
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
                        'Kelas ${s.kelas}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${s.mapel}  •  ${s.ruang}',
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