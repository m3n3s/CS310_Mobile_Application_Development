import 'package:flutter/material.dart';
import 'package:cs310_project/utils/colors.dart';

class BottomNavigation extends StatefulWidget {
  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.popAndPushNamed(context, '/feed');
    } else if (index == 1) {
      Navigator.popAndPushNamed(context, '/newpost');
    } else if (index == 2) {
      Navigator.popAndPushNamed(context, '/chats');
    } else if (index == 3) {
      Navigator.popAndPushNamed(context, '/notifications');
    } else if (index == 4) {
      Navigator.popAndPushNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.backgroundColor,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: AppColors.primary),
          label: 'Feed',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle, color: AppColors.primary),
          label: 'Post',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat, color: AppColors.primary),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications, color: AppColors.primary),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: AppColors.primary),
          label: 'Profile',
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }
}
