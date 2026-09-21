import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/modes.dart';
import 'screens/settings.dart';
import 'screens/today.dart';

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

class AppColors {
  // Backgrounds
  static const surface = Color(0xFFFAF8F4);
  static const surfaceMuted = Color(0xFFEBE6DA);

  // Brand
  static const brand = Color(0xFF7B563D);
  static const brandTint = Color(0xFF9F755C);

  // Dark
  static const ink = Color(0xFF4E3B31);

  // Accent
  static const accent = Color(0xFFFFB60A);

  // Text
  static const textPrimary = ink;
  static const textSecondary = brandTint;
  static const textOnBrand = surface;

  // Borders
  static const border = Color(0x1A4E3B31);
}

ThemeData appTheme = ThemeData(
  useMaterial3: true,

  scaffoldBackgroundColor: AppColors.surface,

  colorScheme: const ColorScheme.light(
    primary: AppColors.brand,
    secondary: AppColors.brandTint,
    surface: AppColors.surface,
    onPrimary: AppColors.textOnBrand,
    onSurface: AppColors.textPrimary,
  ),

  textTheme: TextTheme(
    displayLarge: GoogleFonts.cormorantGaramond(
      fontSize: 40,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),

    headlineMedium: GoogleFonts.cormorantGaramond(
      fontSize: 30,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),

    titleMedium: GoogleFonts.montserrat(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),

    bodyMedium: GoogleFonts.montserrat(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),

    bodySmall: GoogleFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.brand,
      foregroundColor: AppColors.textOnBrand,
      minimumSize: const Size.fromHeight(54),
      textStyle: GoogleFonts.montserrat(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.brand,
      minimumSize: const Size.fromHeight(54),
      side: const BorderSide(color: AppColors.brandTint),
      textStyle: GoogleFonts.montserrat(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  ),

  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.surface,
    indicatorColor: AppColors.surfaceMuted,
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      final isSelected = states.contains(WidgetState.selected);

      return GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? AppColors.brand : AppColors.brandTint,
      );
    }),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      final isSelected = states.contains(WidgetState.selected);

      return IconThemeData(
        color: isSelected ? AppColors.brand : AppColors.brandTint,
      );
    }),
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.surface,
    elevation: 0,
    centerTitle: false,
    foregroundColor: AppColors.textPrimary,
    titleTextStyle: GoogleFonts.montserrat(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  ),
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
