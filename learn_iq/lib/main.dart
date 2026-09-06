import 'package:flutter/material.dart';
import 'core/services/learning_state_manager.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/splash_screen.dart';
import 'features/home/home_screen.dart';
import 'features/course_map/course_map_screen.dart';
import 'features/practice/practice_screen.dart';
import 'features/league/league_screen.dart';
import 'features/profile/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LearnIQApp());
}

class LearnIQApp extends StatefulWidget {
  const LearnIQApp({super.key});

  @override
  State<LearnIQApp> createState() => _LearnIQAppState();
}

class _LearnIQAppState extends State<LearnIQApp> {
  final LearningStateManager _stateManager = LearningStateManager();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LearnIQ: The Duolingo for Programming',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: SplashScreen(stateManager: _stateManager),
    );
  }
}

class MainNavigationHost extends StatefulWidget {
  final LearningStateManager? stateManager;

  const MainNavigationHost({super.key, this.stateManager});

  @override
  State<MainNavigationHost> createState() => _MainNavigationHostState();
}

class _MainNavigationHostState extends State<MainNavigationHost> {
  int _selectedTabIndex = 0;
  late final LearningStateManager _stateManager;

  @override
  void initState() {
    super.initState();
    _stateManager = widget.stateManager ?? LearningStateManager();
    _stateManager.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _stateManager.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        stateManager: _stateManager,
        onTabChange: (index) => setState(() => _selectedTabIndex = index),
      ),
      CourseMapScreen(stateManager: _stateManager),
      PracticeScreen(stateManager: _stateManager),
      LeagueScreen(stateManager: _stateManager),
      ProfileScreen(stateManager: _stateManager),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedTabIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedTabIndex,
          onTap: (index) => setState(() => _selectedTabIndex = index),
          backgroundColor: AppColors.surface,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.iqooCyan,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Learn',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pest_control_outlined),
              activeIcon: Icon(Icons.pest_control),
              label: 'Practice',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              activeIcon: Icon(Icons.emoji_events),
              label: 'League',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
