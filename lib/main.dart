import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;

import 'core/app_theme.dart';
import 'core/pengumuman_store.dart';
import 'core/session.dart';
import 'core/supabase_config.dart';
import 'screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SupabaseConfig.url.isEmpty || SupabaseConfig.publishableKey.isEmpty) {
    throw Exception(
      'Kunci Supabase kosong. '
          'SUPABASE_URL: ${SupabaseConfig.url.length} karakter, '
          'SUPABASE_PUBLISHABLE_KEY: ${SupabaseConfig.publishableKey.length} karakter. '
          'Jalankan dengan: flutter run --dart-define-from-file=env.json',
    );
  }

  debugPrint('ALAMAT SUPABASE DIPAKAI: ${SupabaseConfig.url}');
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );
  await Session.loadTheme();
  await PengumumanStore.load();
  runApp(const AkademisApp());
}

class AkademisApp extends StatelessWidget {
  const AkademisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: Session.themeMode,
      builder: (context, mode, _) => MaterialApp(
        title: 'Akademis',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: mode,
        home: const SplashScreen(),
      ),
    );
  }
}