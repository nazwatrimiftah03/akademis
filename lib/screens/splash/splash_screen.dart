import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_theme.dart';
import '../../core/session.dart';
import '../../widgets/brand_logo.dart';
import '../auth/login_screen.dart';
import '../home/home_shell.dart';
import '../onboarding/onboarding_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goNext();
  }

  Future<void> _goNext() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('onboarding_done') ?? false;
    final sesi = await Session.load();
    final punyaSesiServer =
        Supabase.instance.client.auth.currentSession != null;
    if (sesi != null && !punyaSesiServer) await Session.clear();
    if (!mounted) return;

    final Widget tujuan;
    if (sesi != null && punyaSesiServer) {
      tujuan = HomeShell(
        name: sesi.$1,
        roleLabel: sesi.$2,
        menus: menusForRole(sesi.$2),
      );
    } else {
      tujuan = done ? const LoginScreen() : const OnboardingScreen();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => tujuan),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.teal, AppColors.tealLight],
          ),
        ),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 900),
            builder: (context, t, child) {
              final scale = 0.8 + 0.2 * Curves.easeOutBack.transform(t);
              return Opacity(
                opacity: t.clamp(0.0, 1.0),
                child: Transform.scale(scale: scale, child: child),
              );
            },
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BrandLogo(size: 110),
                SizedBox(height: 20),
                Text(
                  'Akademis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Belajar, hadir, dan berkembang',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}