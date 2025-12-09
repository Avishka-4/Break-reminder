import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'ui/screens/home_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/timer_screen.dart';
import 'ui/screens/summary_screen.dart';
import 'ui/screens/pairing_screen.dart';
import 'ui/theme.dart';
import 'logic/break_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BreakReminderApp());
}

class BreakReminderApp extends StatelessWidget {
  const BreakReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/timer', builder: (_, __) => const TimerScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        GoRoute(path: '/summary', builder: (_, __) => const SummaryScreen()),
        GoRoute(path: '/pair', builder: (_, __) => const PairingScreen()),
      ],
    );

    return ChangeNotifierProvider(
      create: (_) => BreakController(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Break Reminder',
        themeMode: ThemeMode.system,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        routerConfig: router,
      ),
    );
  }
}
