import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/pengumuman_store.dart';
import '../../core/session.dart';
import '../../services/auth_service.dart';
import '../../widgets/pengumuman_section.dart';
import '../auth/login_screen.dart';
import '../menu_router.dart';

class MenuItem {
  const MenuItem(this.icon, this.label);

  final IconData icon;
  final String label;
}

/// Daftar menu beranda untuk tiap peran.
List<MenuItem> menusForRole(String roleLabel) => switch (roleLabel) {
  'Pengajar' => const [
    MenuItem(Icons.calendar_month_rounded, 'Jadwal Mengajar'),
    MenuItem(Icons.fact_check_rounded, 'Absensi Kelas'),
    MenuItem(Icons.menu_book_rounded, 'Materi'),
    MenuItem(Icons.assignment_rounded, 'Tugas'),
    MenuItem(Icons.quiz_rounded, 'Ujian'),
    MenuItem(Icons.grade_rounded, 'Input Nilai'),
    MenuItem(Icons.bug_report_rounded, 'Black Box Testing'),
    MenuItem(Icons.rate_review_rounded, 'Evaluasi'),
  ],
  'Admin' => const [
    MenuItem(Icons.groups_rounded, 'Data Siswa'),
    MenuItem(Icons.co_present_rounded, 'Data Pengajar'),
    MenuItem(Icons.class_rounded, 'Kelas'),
    MenuItem(Icons.library_books_rounded, 'Mata Pelajaran'),
    MenuItem(Icons.calendar_month_rounded, 'Jadwal'),
    MenuItem(Icons.campaign_rounded, 'Pengumuman'),
    MenuItem(Icons.insights_rounded, 'Laporan & Evaluasi'),
    MenuItem(Icons.bug_report_rounded, 'Black Box Testing'),
  ],
  _ => const [
    MenuItem(Icons.calendar_month_rounded, 'Jadwal'),
    MenuItem(Icons.fact_check_rounded, 'Absensi'),
    MenuItem(Icons.menu_book_rounded, 'Materi'),
    MenuItem(Icons.assignment_rounded, 'Tugas'),
    MenuItem(Icons.quiz_rounded, 'Ujian'),
    MenuItem(Icons.grade_rounded, 'Nilai'),
    MenuItem(Icons.rate_review_rounded, 'Evaluasi'),
  ],
};

const _namaHari = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];
const _namaBulan = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

/// Warna ikon menu, dipakai bergantian supaya beranda tidak monoton.
const _warnaMenu = [
  Color(0xFF0F766E), // teal
  Color(0xFF2563EB), // biru
  Color(0xFFD97706), // jingga
  Color(0xFFE11D48), // merah muda
  Color(0xFF7C3AED), // ungu
  Color(0xFF16A34A), // hijau
  Color(0xFF0891B2), // cyan
  Color(0xFFEA580C), // oranye
];

String _sapaan() {
  final jam = DateTime.now().hour;
  if (jam < 11) return 'Selamat pagi';
  if (jam < 15) return 'Selamat siang';
  if (jam < 18) return 'Selamat sore';
  return 'Selamat malam';
}

String _tanggalHariIni() {
  final d = DateTime.now();
  return '${_namaHari[d.weekday - 1]}, ${d.day} ${_namaBulan[d.month - 1]} ${d.year}';
}

IconData _ikonPeran(String roleLabel) => switch (roleLabel) {
  'Pengajar' => Icons.co_present_rounded,
  'Admin' => Icons.admin_panel_settings_rounded,
  _ => Icons.school_rounded,
};

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.name,
    required this.roleLabel,
    required this.menus,
  });

  final String name;
  final String roleLabel;
  final List<MenuItem> menus;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;
  late String _name = widget.name;

  @override
  void initState() {
    super.initState();
    PengumumanStore.segarkan();
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _ubahNama() async {
    final baru = await showDialog<String>(
      context: context,
      builder: (_) => _DialogNama(awal: _name),
    );
    if (baru == null || !mounted) return;

    try {
      await AuthService().updateNama(baru);
    } catch (e) {
      _snack(AuthService.friendlyError(e));
      return;
    }

    await Session.save(name: baru, role: widget.roleLabel);
    if (!mounted) return;
    setState(() => _name = baru);
    _snack('Nama diperbarui');
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    // Kalau sedang offline, tetap keluar dari aplikasi.
    try {
      await AuthService().signOut();
    } catch (_) {}
    await Session.clear();
    await PengumumanStore.bersihkan();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
    );
  }

  // ---------------------------------------------------------------------------
  // BAGIAN TAMPILAN
  // ---------------------------------------------------------------------------

  Widget _lingkaran(double ukuran, double alpha) {
    return Container(
      width: ukuran,
      height: ukuran,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }

  Widget _chipPeran() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_ikonPeran(widget.roleLabel), size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            widget.roleLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartuSapaan() {
    final inisial = _name.isEmpty ? '?' : _name[0].toUpperCase();
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.tealLight, AppColors.teal],
          ),
        ),
        child: Stack(
          children: [
            Positioned(right: -40, top: -40, child: _lingkaran(140, 0.10)),
            Positioned(right: 40, bottom: -50, child: _lingkaran(100, 0.08)),
            Positioned(
              right: 4,
              bottom: 0,
              child: Icon(
                _ikonPeran(widget.roleLabel),
                size: 64,
                color: Colors.white.withValues(alpha: 0.28),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.22),
                  child: Text(
                    inisial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
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
                        _sapaan(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        _name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _tanggalHariIni(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _chipPeran(),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tileMenu(MenuItem m, int index, Color tileColor, Color garis) {
    final warna = _warnaMenu[index % _warnaMenu.length];
    return Material(
      color: tileColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: garis),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          final page = screenForMenu(widget.roleLabel, m.label);
          if (page == null) {
            _snack('${m.label} segera hadir');
            return;
          }
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: warna.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(m.icon, size: 26, color: warna),
              ),
              const SizedBox(height: 8),
              Text(
                m.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabBeranda(Color tileColor, Color garis) {
    return RefreshIndicator(
      onRefresh: PengumumanStore.segarkan,
      child: _isiBeranda(tileColor, garis),
    );
  }

  Widget _isiBeranda(Color tileColor, Color garis) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        _kartuSapaan(),
        const SizedBox(height: 26),
        Row(
          children: [
            Text(
              'Menu',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              '${widget.menus.length} fitur',
              style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.92,
          children: [
            for (var i = 0; i < widget.menus.length; i++)
              _tileMenu(widget.menus[i], i, tileColor, garis),
          ],
        ),
        PengumumanSection(peran: widget.roleLabel),
      ],
    );
  }

  Widget _tabProfil(Color tileColor, Color garis) {
    final inisial = _name.isEmpty ? '?' : _name[0].toUpperCase();
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.tealLight, AppColors.teal],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.teal,
                      child: Text(
                        inisial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _chipPeran(),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Akun',
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Material(
                color: tileColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: garis),
                ),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  onTap: _ubahNama,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.edit_rounded, color: scheme.primary),
                  ),
                  title: const Text(
                    'Ubah nama',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    _name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tampilan',
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: Session.themeMode,
                builder: (context, mode, _) => SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_rounded),
                        label: Text('Sistem'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_rounded),
                        label: Text('Terang'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_rounded),
                        label: Text('Gelap'),
                      ),
                    ],
                    selected: {mode},
                    onSelectionChanged: (s) => Session.setTheme(s.first),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Keluar'),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Akademis v1.0.0',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tileColor = dark ? const Color(0xFF16231F) : Colors.white;
    final garis = dark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);

    return Scaffold(
      body: _tab == 0
          ? SafeArea(child: _tabBeranda(tileColor, garis))
          : _tabProfil(tileColor, garis),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

/// Dialog ubah nama. Controller-nya dimiliki dialog sendiri supaya aman
/// dibuang saat dialog tertutup.
class _DialogNama extends StatefulWidget {
  const _DialogNama({required this.awal});

  final String awal;

  @override
  State<_DialogNama> createState() => _DialogNamaState();
}

class _DialogNamaState extends State<_DialogNama> {
  late final TextEditingController _c = TextEditingController(
    text: widget.awal,
  );
  String? _error;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _simpan() {
    final v = _c.text.trim();
    if (v.length < 3) {
      setState(() => _error = 'Nama minimal 3 karakter');
      return;
    }
    Navigator.of(context).pop(v);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ubah nama'),
      content: TextField(
        controller: _c,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(labelText: 'Nama', errorText: _error),
        onSubmitted: (_) => _simpan(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        TextButton(onPressed: _simpan, child: const Text('Simpan')),
      ],
    );
  }
}