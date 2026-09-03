import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/lock_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/settings/lock_screen.dart';
import 'presentation/screens/transactions/transactions_screen.dart';
import 'presentation/screens/statistics/statistics_screen.dart';
import 'presentation/screens/budget/budget_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';

class MoneyTrackerApp extends ConsumerWidget {
  const MoneyTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final settings = ref.watch(settingsStreamProvider).valueOrNull;
    final locked = ref.watch(appLockedProvider);
    final pinHash = settings?.pinHash ?? '';

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(routes: [GoRoute(path: '/', builder: (c, s) => const DashboardScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/transactions', builder: (c, s) => const TransactionsScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/statistics', builder: (c, s) => const StatisticsScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/budget', builder: (c, s) => const BudgetScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen())]),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Money Tracker Personal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      // v1.1: kunci PIN — tutupi seluruh app bila terkunci
      builder: (context, child) {
        if (pinHash.isNotEmpty && locked) {
          return LockScreen(pinHash: pinHash, onUnlocked: () {});
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.list_outlined), selectedIcon: Icon(Icons.list), label: 'Riwayat'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Statistik'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Anggaran'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
      ),
    );
  }
}
