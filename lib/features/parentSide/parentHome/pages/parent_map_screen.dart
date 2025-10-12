// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ParentMapScreen extends StatefulWidget {
  const ParentMapScreen({super.key});

  @override
  State<ParentMapScreen> createState() => _ParentMapScreenState();
}

class _ParentMapScreenState extends State<ParentMapScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const LatLng _target = LatLng(32.462074, 74.529802);
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: _target,
    zoom: 14.5,
  );

  GoogleMapController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const Drawer(),
      body: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: (c) => _controller = c,
      ),

      // Glassy Drawer Button ✨
      floatingActionButton: ClipRRect(
        // borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 1),
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color: Colors.black.withOpacity(0.4),
                width: 0.6,
              ),

              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.black, size: 28),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    );
  }
}
