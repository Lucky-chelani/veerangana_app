import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veerangana/screens/contacts.dart';
import 'package:veerangana/screens/details.dart';
import 'package:veerangana/screens/home_screen.dart';
import 'package:veerangana/screens/map_screen.dart';
import 'package:veerangana/ui/colors.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex;
  const BottomNavBar({super.key, required this.initialIndex});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  String userPhone = '';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final List<Widget> screens = [
    const HomeScreen(),
    MapScreen(),
    EmergencyContactScreen(),
    DetailsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(1),
            topRight: Radius.circular(1),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.raspberry,
            unselectedItemColor: AppColors.salmonPink.withOpacity(0.7),
            selectedFontSize: 12,
            unselectedFontSize: 11,
            selectedIconTheme: const IconThemeData(size: 28),
            unselectedIconTheme: const IconThemeData(size: 24),
            elevation: 0,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                _animationController.reset();
                _animationController.forward();
              });
            },
            items: [
              _buildNavItem(Icons.home_rounded, 'Home', 0),
              _buildNavItem(Icons.map_rounded, 'Map', 1),
              _buildNavItem(Icons.contacts_rounded, 'Contacts', 2),
              _buildNavItem(Icons.person_rounded, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            Icon(icon, 
              color: _currentIndex == index 
                ? AppColors.raspberry 
                : AppColors.salmonPink.withOpacity(0.7),
            ),
            const SizedBox(height: 4),
            _currentIndex == index
              ? AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return SizedBox(
                      width: 20 * _animationController.value,
                      height: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.raspberry,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                )
              : const SizedBox(height: 3),
          ],
        ),
      ),
      label: label,
      activeIcon: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            Icon(icon, color: AppColors.raspberry),
            const SizedBox(height: 4),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return SizedBox(
                  width: 20 * _animationController.value,
                  height: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.raspberry,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}