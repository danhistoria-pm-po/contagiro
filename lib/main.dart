import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'modules/auth/views/login_page.dart';
import 'modules/dashboard/views/dashboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vinedptivxwlaskeraqo.supabase.co',
    anonKey: 'sb_publishable_-38Rpr0sjdAa-QjdrIb6qw_81zxMTcR',
  );

  runApp(const ContaGiroApp());
}

class ContaGiroApp extends StatelessWidget {
  const ContaGiroApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Verifica se já existe um usuário autenticado na sessão atual
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      title: 'ContaGiro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: session == null ? const LoginPage() : const DashboardPage(),
    );
  }
}