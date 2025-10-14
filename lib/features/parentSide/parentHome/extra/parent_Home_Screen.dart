// // ignore_for_file: file_names, deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:google_nav_bar/google_nav_bar.dart';

// import 'package:godropme/features/parentSide/parentHome/pages/map_tab.dart';
// import 'package:godropme/features/parentSide/parentHome/pages/search_tab.dart';
// import 'package:godropme/features/parentSide/parentHome/pages/chat_tab.dart';
// import 'package:godropme/theme/colors.dart';

// class ParentHomeScreen extends StatefulWidget {
//   const ParentHomeScreen({super.key});

//   @override
//   State<ParentHomeScreen> createState() => _ParentHomeScreenState();
// }

// class _ParentHomeScreenState extends State<ParentHomeScreen> {
//   int _currentIndex = 0;

//   static const List<Widget> _pages = <Widget>[MapTab(), SearchTab(), ChatTab()];

// ignore_for_file: file_names

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(child: _pages[_currentIndex]),
//       bottomNavigationBar: SafeArea(
//         top: false,
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
//           child: Container(
//             decoration: BoxDecoration(
//               color: AppColors.primary,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: AppColors.primary.withOpacity(0.25),
//                   blurRadius: 18,
//                   offset: const Offset(0, 8),
//                 ),
//               ],
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//             child: GNav(
//               haptic: true,
//               gap: 10,
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//               backgroundColor: Colors.transparent,
//               rippleColor: Colors.white.withOpacity(0.2),
//               hoverColor: Colors.white.withOpacity(0.1),
//               color: Colors.white.withOpacity(0.8),
//               activeColor: Colors.white,
//               tabBackgroundColor: Colors.white.withOpacity(0.12),
//               duration: const Duration(milliseconds: 220),
//               selectedIndex: _currentIndex,
//               onTabChange: (i) => setState(() => _currentIndex = i),
//               tabs: const [
//                 GButton(
//                   icon: Icons.map,
//                   text: 'Maps',
//                   leading: Image(
//                     image: AssetImage('assets/icons/navBarIcons/maps.png'),
//                     width: 26,
//                     height: 26,
//                   ),
//                 ),
//                 GButton(
//                   icon: Icons.search,
//                   text: 'Search',
//                   leading: Image(
//                     image: AssetImage('assets/icons/navBarIcons/browsing.png'),
//                     width: 26,
//                     height: 26,
//                   ),
//                 ),
//                 GButton(
//                   icon: Icons.chat_bubble_outline,
//                   text: 'Chat',
//                   leading: Image(
//                     image: AssetImage('assets/icons/navBarIcons/chat.png'),
//                     width: 26,
//                     height: 26,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
