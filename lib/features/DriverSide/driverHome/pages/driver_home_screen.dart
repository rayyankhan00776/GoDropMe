// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/features/driverSide/driverHome/pages/driver_requests_screen.dart';
import 'package:godropme/features/driverSide/driverHome/pages/driver_orders_screen.dart';
import 'package:godropme/features/driverSide/driverHome/pages/driver_map_screen.dart';
import 'package:godropme/features/driverSide/driverHome/pages/driver_chat_screen.dart';
import 'package:godropme/constants/app_strings.dart';

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
    // Read optional deep-link argument to select a tab (0..3). Fallback to Maps (2).
    try {
      final args = Get.arguments;
      int initialIndex = 2;
      if (args is Map) {
        final t = args['tab'];
        if (t is int && t >= 0 && t <= 3) {
          initialIndex = t;
        }
      }
      _currentIndex = initialIndex;
    } catch (_) {
      _currentIndex = 2;
    }
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
              label: AppStrings.driverTabRequests,
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment),
              label: AppStrings.driverTabOrders,
            ),
            NavigationDestination(
              icon: Icon(Icons.map),
              label: AppStrings.driverTabMaps,
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              label: AppStrings.driverTabChat,
            ),
          ],
        ),
      ),
    );
  }
}
