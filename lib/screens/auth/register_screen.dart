import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _confirmC = TextEditingController();

  // Admin tidak bisa daftar sendiri, hanya Siswa dan Pengajar.
  String _role = 'siswa';
  bool _hide = true;
  bool _loading = false;

  String get _roleLabel => _role == 'pengajar' ? 'Pengajar' : 'Siswa';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final auth = AuthService();

    try {
      await auth.signUp(
        email: _emailC.text.trim(),
        password: _passC.text,
        fullName: _nameC.text.trim(),
        role: _role,
      );
      await auth.signOut(); // supaya pengguna masuk lewat halaman login
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Pendaftaran berhasil'),
          content: Text(
            _role == 'pengajar'
                ? 'Akun Pengajar dibuat. Akun baru bisa dipakai setelah '
                'disetujui admin sekolah.'
                : 'Akun Siswa dibuat. Sekarang kamu bisa masuk.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(AuthService.friendlyError(e))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _passC.dispose();
    _confirmC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buat akun baru',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Daftar sebagai siapa?',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 'siswa', label: Text('Siswa')),
                      ButtonSegment(value: 'pengajar', label: Text('Pengajar')),
                    ],
                    selected: {_role},
                    onSelectionChanged: (s) => setState(() => _role = s.first),
                  ),
                ),
                if (_role == 'pengajar') ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Akun Pengajar perlu disetujui admin sebelum bisa dipakai.',
                    style: TextStyle(color: AppColors.muted, fontSize: 12.5),
                  ),
                ],
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameC,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nama lengkap',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) => (v == null || v.trim().length < 3)
                      ? 'Nama minimal 3 karakter'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailC,
                  keyboardType: TextInputType.emailAddress,
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
                const SizedBox(height: 14),
                TextFormField(
                  controller: _confirmC,
                  obscureText: _hide,
                  decoration: const InputDecoration(
                    labelText: 'Ulangi kata sandi',
                    prefixIcon: Icon(Icons.lock_reset_rounded),
                  ),
                  validator: (v) =>
                  v != _passC.text ? 'Kata sandi tidak sama' : null,
                ),
                const SizedBox(height: 24),
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
                      : Text('Daftar sebagai $_roleLabel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}