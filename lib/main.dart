import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
            GoRoute(path: '/', builder: (context, state) => const MyHomePage()),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/modes',
              builder: (context, state) => const ModesPage(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
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

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.brand,
    unselectedItemColor: AppColors.brandTint,
    selectedLabelStyle: GoogleFonts.montserrat(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: GoogleFonts.montserrat(fontSize: 12),
    elevation: 0,
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

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).bottomAppBarTheme.color,
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.wb_sunny_outlined),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'Modes'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
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

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Today', style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}

class ModesPage extends StatelessWidget {
  const ModesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.work_outline),
                Text('Focus'),
                Icon(Icons.keyboard_arrow_right),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.school_outlined),
                Text('Reading'),
                Icon(Icons.keyboard_arrow_right),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.sunny),
                Text('Evening'),
                Icon(Icons.keyboard_arrow_right),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.sunny),
                Text('Morning'),
                Icon(Icons.keyboard_arrow_right),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

        ],
      ),
    );
  }
}
