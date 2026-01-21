import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/presets/presentation/presets_screen.dart';
import '../../features/roulette/presentation/roulette_screen.dart';
import '../../features/rng/presentation/rng_screen.dart';
import '../../features/teams/presentation/team_picker_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/dice/presentation/dice_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      if (state.uri.toString() == '/home') {
        return '/';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => _TabsShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
          GoRoute(path: '/presets', builder: (c, s) => const PresetsScreen()),
          GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
        ],
      ),
      GoRoute(
        path: '/dice',
        builder: (context, state) => const DiceScreen(),
      ),
      GoRoute(
        path: '/roulette',
        builder: (context, state) => const RouletteScreen(),
      ),
      GoRoute(
        path: '/rng',
        builder: (context, state) => const RngScreen(),
      ),
      GoRoute(
        path: '/teams',
        builder: (context, state) => const TeamPickerScreen(),
      ),
    ],
  );
}

class _TabsShell extends StatefulWidget {
  final Widget child;
  const _TabsShell({required this.child});

  @override
  State<_TabsShell> createState() => _TabsShellState();
}

class _TabsShellState extends State<_TabsShell> {
  int _indexFromLocation(String location) {
    if (location.startsWith('/presets')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/presets');
              break;
            case 2:
              context.go('/settings');
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Hub'),
          NavigationDestination(icon: Icon(Icons.bookmark_rounded), label: 'Presets'),
          NavigationDestination(icon: Icon(Icons.tune_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}
