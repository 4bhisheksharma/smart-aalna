import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_aalna/features/home/screens/home_screen.dart';
import 'package:smart_aalna/features/home/screens/add_clothes_screen.dart';
import 'package:smart_aalna/features/home/screens/added_clothes_screen.dart';
import 'package:smart_aalna/features/chat/screens/chat_screen.dart';
import 'package:smart_aalna/features/profile/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const AddClothesScreen(),
    const AddedClothesScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Needed to ensure content goes behind floating bar
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
                    _buildNavItem(
                      1,
                      Icons.add_photo_alternate_outlined,
                      Icons.add_photo_alternate,
                      'Add',
                    ),
                    _buildNavItem(
                      2,
                      Icons.checkroom_outlined,
                      Icons.checkroom,
                      'Aalna',
                    ),
                    _buildNavItem(
                      3,
                      Icons.chat_bubble_outline,
                      Icons.chat_bubble,
                      'Chat',
                    ),
                    _buildNavItem(
                      4,
                      Icons.person_outline,
                      Icons.person,
                      'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey<bool>(isSelected),
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
                size: 24,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
