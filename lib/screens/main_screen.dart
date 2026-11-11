import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starter_flutter/controllers/navigation_controller.dart';
import 'package:starter_flutter/screens/dogwalk_screen.dart';
import 'package:starter_flutter/screens/home_screen.dart';
import 'package:starter_flutter/screens/settings_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  final List<Widget> _screens = const [
    HomeScreen(),
    DogwalkScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Hört auf Änderungen des Tabs
    final navController = context.watch<NavigationController>();

    return Scaffold(
      body: IndexedStack(
        index: navController.selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navController.selectedIndex,
        onTap: (index) {
          // Aktualisiert den Provider beim Tippen
          context.read<NavigationController>().setTab(index);
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Gassi gehen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Einstellungen',
          ),
        ],
      ),
    );
  }
}