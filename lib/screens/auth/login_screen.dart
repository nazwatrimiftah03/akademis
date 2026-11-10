import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/session.dart';
import '../../services/auth_service.dart';
import '../../widgets/brand_logo.dart';
import '../home/home_shell.dart';
import 'register_screen.dart';

/// Pilihan peran di layar login.
class _RoleOption {
  const _RoleOption(this.value, this.label, this.icon, this.deskripsi);

  final String value;
  final String label;
  final IconData icon;
  final String deskripsi;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _roles = [
    _RoleOption(
      'siswa',
      'Siswa',
      Icons.school_rounded,
      'Lihat jadwal, materi, tugas, ujian, dan nilaimu.',
    ),
    _RoleOption(
      'pengajar',
      'Pengajar',
      Icons.co_present_rounded,
      'Kelola kelas, absensi, materi, tugas, ujian, dan nilai.',
    ),
    _RoleOption(
      'admin',
      'Admin',
      Icons.admin_panel_settings_rounded,
      'Kelola data sekolah, pengumuman, dan laporan evaluasi.',
    ),
  ];

  final _formKey = GlobalKey<FormState>();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();

  String _role = 'siswa';
  bool _hide = true;
  bool _loading = false;

  String get _roleLabel => switch (_role) {
    'pengajar' => 'Pengajar',
    'admin' => 'Admin',
    _ => 'Siswa',
  };

  String get _roleDeskripsi =>
      _roles.firstWhere((r) => r.value == _role).deskripsi;

  void _pesan(String teks) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final auth = AuthService();

    try {
      await auth.signIn(email: _emailC.text.trim(), password: _passC.text);
      final profile = await auth.fetchProfile();

      if (profile == null) {
        await auth.signOut();
        _pesan('Profil akun tidak ditemukan. Hubungi admin sekolah.');
        return;
      }
      if (profile.role != _role) {
        await auth.signOut();
        _pesan(
          'Akun ini terdaftar sebagai ${profile.roleLabel}. '
              'Pilih peran "${profile.roleLabel}" lalu coba lagi.',
        );
        return;
      }
      if (!profile.aktif) {
        await auth.signOut();
        _pesan('Akunmu belum disetujui admin sekolah.');
        return;
      }

      final nama = profile.fullName.isEmpty
          ? _emailC.text.trim().split('@').first
          : profile.fullName;
      await Session.save(name: nama, role: profile.roleLabel);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => HomeShell(
            name: nama,
            roleLabel: profile.roleLabel,
            menus: menusForRole(profile.roleLabel),
          ),
        ),
            (_) => false,
      );
    } catch (e) {
      _pesan(AuthService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // BAGIAN TAMPILAN
  // ---------------------------------------------------------------------------

  Widget _lingkaranDekorasi(double ukuran, double alpha) {
    return Container(
      width: ukuran,
      height: ukuran,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.tealLight, AppColors.teal],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(44),
          bottomRight: Radius.circular(44),
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -50, right: -40, child: _lingkaranDekorasi(180, 0.10)),
          Positioned(top: 90, left: -60, child: _lingkaranDekorasi(150, 0.07)),
          Positioned(
              bottom: 40, right: 30, child: _lingkaranDekorasi(60, 0.08)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  BrandLogo(size: 84),
                  SizedBox(height: 14),
                  Text(
                    'Akademis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Belajar, hadir, dan berkembang',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartuPeran(_RoleOption r, ColorScheme scheme) {
    final dipilih = _role == r.value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = r.value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: dipilih
                ? scheme.primary
                : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: dipilih ? scheme.primary : scheme.outlineVariant,
            ),
            boxShadow: dipilih
                ? [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ]
                : const [],
          ),
          child: Column(
            children: [
              Icon(
                r.icon,
                size: 28,
                color: dipilih ? scheme.onPrimary : scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              Text(
                r.label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: dipilih ? scheme.onPrimary : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pilihPeran(ColorScheme scheme) {
    final isi = <Widget>[];
    for (var i = 0; i < _roles.length; i++) {
      if (i > 0) isi.add(const SizedBox(width: 10));
      isi.add(_kartuPeran(_roles[i], scheme));
    }
    return Row(children: isi);
  }

  Widget _formKartu(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final gelap = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: gelap ? const Color(0xFF16231F) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: gelap ? 0.35 : 0.10),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat datang 👋',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'Masuk sebagai siapa hari ini?',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            _pilihPeran(scheme),
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _roleDeskripsi,
                key: ValueKey(_role),
                style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailC,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Email wajib diisi';
                }
                if (!v.contains('@')) return 'Format email belum benar';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passC,
              obscureText: _hide,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (!_loading) _submit();
              },
              decoration: InputDecoration(
                labelText: 'Kata sandi',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    _hide
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => setState(() => _hide = !_hide),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Kata sandi wajib diisi';
                }
                if (v.length < 6) return 'Minimal 6 karakter';
                return null;
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _pesan(
                  'Untuk mengatur ulang kata sandi, hubungi admin sekolah.',
                ),
                child: const Text('Lupa kata sandi?'),
              ),
            ),
            const SizedBox(height: 4),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Masuk sebagai $_roleLabel'),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Belum punya akun?',
                  style: TextStyle(color: AppColors.muted),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RegisterScreen(),
                    ),
                  ),
                  child: const Text('Daftar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _header(),
            // Kartu form dinaikkan sedikit supaya menumpuk di atas header.
            Transform.translate(
              offset: const Offset(0, -44),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _formKartu(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}