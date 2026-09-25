import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: AppTheme.primaryColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            alignment: Alignment.centerLeft,
            child: const Row(
              children: [
                Icon(Icons.local_hospital, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(
                  'MedCore OS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
          _buildNavItem(1, Icons.people_outline, Icons.people, 'Patients'),
          _buildNavItem(2, Icons.medical_services_outlined, Icons.medical_services, 'Doctors'),
          _buildNavItem(3, Icons.calendar_today_outlined, Icons.calendar_today, 'Appointments'),
          const Spacer(),
          const Divider(color: Colors.white24, height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white70),
            title: const Text('Logout', style: TextStyle(color: Colors.white70)),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData unselectedIcon, IconData selectedIcon, String label) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          leading: Icon(
            isSelected ? selectedIcon : unselectedIcon,
            color: Colors.white,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: () => onDestinationSelected(index),
        ),
      ),
    );
  }
}
