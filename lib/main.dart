import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/notification_service.dart';
import 'core/router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/services/alert_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Ignore error if Firebase is not yet configured with google-services.json
  }
  // Load .env (if present) so dotenv values are available at runtime.
  try {
    await dotenv.load();
  } catch (_) {}

  // Initialize Supabase - prefer --dart-define values, otherwise fallback to .env
  final supabaseUrl =
      const String.fromEnvironment('SUPABASE_URL', defaultValue: '').isNotEmpty
          ? const String.fromEnvironment('SUPABASE_URL')
          : (dotenv.env['SUPABASE_URL'] ?? '');
  final supabaseAnon =
      const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '')
              .isNotEmpty
          ? const String.fromEnvironment('SUPABASE_ANON_KEY')
          : (dotenv.env['SUPABASE_ANON_KEY'] ?? '');

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnon);
  await NotificationService.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Sercio',
          scaffoldMessengerKey: AlertService.messengerKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          themeMode: ThemeMode.light,
          routerConfig: appRouter,
        );
      },
    );
  }
}
