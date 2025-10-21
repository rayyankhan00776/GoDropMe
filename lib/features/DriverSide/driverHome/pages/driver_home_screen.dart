// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/features/driverSide/driverHome/pages/driver_requests_screen.dart';
import 'package:godropme/features/driverSide/driverHome/pages/driver_orders_screen.dart';
import 'package:godropme/features/driverSide/driverHome/pages/driver_map_screen.dart';
import 'package:godropme/features/driverSide/driverHome/pages/driver_chat_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  int _currentIndex = 2; // Default to Maps tab

  late final List<Widget> _pages;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      DriverRequestsScreen(),
      DriverOrdersScreen(),
      DriverMapScreen(),
      DriverChatScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primary,
          indicatorShape: const StadiumBorder(),
          elevation: 8,
          iconTheme: MaterialStateProperty.resolveWith((states) {
            final selected = states.contains(MaterialState.selected);
            return IconThemeData(color: selected ? Colors.white : Colors.black);
          }),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            final selected = states.contains(MaterialState.selected);
            return TextStyle(
              color: selected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          surfaceTintColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.list_alt),
              label: 'Requests',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment),
              label: 'My Orders',
            ),
            NavigationDestination(icon: Icon(Icons.map), label: 'Maps'),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Chat',
            ),
          ],
        ),
      ),
    );
  }
}
