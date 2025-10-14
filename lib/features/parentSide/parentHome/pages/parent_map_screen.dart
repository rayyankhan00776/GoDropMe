// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godropme/features/parentSide/common widgets/parent_drawer_shell.dart';

class ParentMapScreen extends StatefulWidget {
  const ParentMapScreen({super.key});

  @override
  State<ParentMapScreen> createState() => _ParentMapScreenState();
}

class _ParentMapScreenState extends State<ParentMapScreen> {
  static const LatLng _target = LatLng(32.462074, 74.529802);
  // static const CameraPosition _initialCameraPosition = CameraPosition(
  // target: _target,
  // zoom: 14.5,
  // );

  GoogleMapController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ParentDrawerShell(
      body: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(34.0000, 71.57849),
                zoom: 15,
              ),
              zoomControlsEnabled: false,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              onMapCreated: (c) => _controller = c,
              mapType: MapType.normal,
              markers: <Marker>{
                Marker(
                  markerId: const MarkerId('target'),
                  position: _target,
                  infoWindow: const InfoWindow(title: 'Target Location'),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}
