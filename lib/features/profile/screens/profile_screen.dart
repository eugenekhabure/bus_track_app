import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bus_track_app/features/auth/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Generate a consistent color from a string
  Color _getColorFromName(String name) {
    final List<Color> colors = const [
      Color(0xFFE57373), // red
      Color(0xFF81C784), // green
      Color(0xFF64B5F6), // blue
      Color(0xFFFFD54F), // yellow
      Color(0xFFCE93D8), // purple
      Color(0xFFFF8A65), // orange
      Color(0xFF4DD0E1), // cyan
      Color(0xFFA1887F), // brown
    ];
    int index = name.isEmpty ? 0 : name.hashCode.abs() % colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final String userName = user?.name ?? 'User';
    final String initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar with initial
            CircleAvatar(
              radius: 70,
              backgroundColor: _getColorFromName(userName),
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? 'No email',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(
                user?.roleId == 3
                    ? 'Driver'
                    : user?.roleId == 4 || user?.roleId == 5
                        ? 'Parent'
                        : 'User',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF1A237E),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await authProvider.logout();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}