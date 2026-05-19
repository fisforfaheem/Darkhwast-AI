import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/case_tracker/screens/case_tracker_screen.dart';
import 'about_screen.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CaseTrackerScreen(),
    const AboutScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync index with route path
    final path = GoRouterState.of(context).uri.path;
    if (path == '/home') _selectedIndex = 0;
    if (path == '/cases') _selectedIndex = 1;
    if (path == '/about') _selectedIndex = 2;
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    // Sync route with index
    if (index == 0) context.go('/home');
    if (index == 1) context.go('/cases');
    if (index == 2) context.go('/about');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            _buildNavItem(Icons.home_rounded, "Home", 0),
            _buildNavItem(Icons.folder_rounded, "Cases", 1),
            _buildNavItem(Icons.info_rounded, "About", 2),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    final isActive = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          if (isActive)
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      label: label,
    );
  }
}
