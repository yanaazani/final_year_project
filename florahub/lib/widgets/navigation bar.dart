import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  CustomBottomNavigationBar({required this.selectedIndex, required this.onItemTapped, required Color selectedItemColor, required Color backgroundColor, required onTap, required Color unselectedItemColor, required int selectedFontSize, required int unselectedFontSize, required BottomNavigationBarType type, required List<BottomNavigationBarItem> items});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.compost_outlined),
          label: 'Plants',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          label: 'Notification',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_people),
          label: 'Profile',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: const Color.fromARGB(255, 54, 51, 51),
      unselectedItemColor: Color.fromARGB(255, 165, 173, 165),
      backgroundColor: Color.fromARGB(255, 200, 230, 201),
      onTap: onItemTapped,
      selectedFontSize: 14,
      unselectedFontSize: 14,
      type: BottomNavigationBarType.fixed,
    );
  }
}
