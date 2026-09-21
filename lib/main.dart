import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/modes.dart';
import 'screens/settings.dart';
import 'screens/today.dart';
import 'theme/app_theme.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },

      navigatorContainerBuilder: (context, navigationShell, children) {
        return SwipePageContainer(
          navigationShell: navigationShell,
          children: children,
        );
      },

      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const TodayScreen(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/modes',
              builder: (context, state) => const ModesScreen(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      theme: appTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: navigationShell,

      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Modes',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class SwipePageContainer extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  const SwipePageContainer({
    super.key,
    required this.navigationShell,
    required this.children,
  });

  @override
  State<SwipePageContainer> createState() => _SwipePageContainerState();
}

class _SwipePageContainerState extends State<SwipePageContainer> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      initialPage: widget.navigationShell.currentIndex,
    );
  }

  @override
  void didUpdateWidget(covariant SwipePageContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_pageController.hasClients) return;

      final currentPage = _pageController.page?.round();
      final targetPage = widget.navigationShell.currentIndex;

      if (currentPage != targetPage) {
        _pageController.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,

      onPageChanged: (index) {
        if (index != widget.navigationShell.currentIndex) {
          widget.navigationShell.goBranch(index);
        }
      },

      children: widget.children,
    );
  }
}
