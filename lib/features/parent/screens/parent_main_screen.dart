import 'package:flutter/material.dart';
import 'package:bus_track_app/features/parent/screens/parent_dashboard_screen.dart';
import 'package:bus_track_app/features/history/screens/trip_history_screen.dart';
import 'package:bus_track_app/features/profile/screens/profile_screen.dart';
import 'package:bus_track_app/features/settings/screens/settings_screen.dart';

class ParentMainScreen extends StatefulWidget {
  const ParentMainScreen({super.key});

  @override
  State<ParentMainScreen> createState() => _ParentMainScreenState();
}

class _ParentMainScreenState extends State<ParentMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    ParentDashboardScreen(),
    TripHistoryScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Children',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        selectedItemColor: const Color(0xFF1A237E),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}