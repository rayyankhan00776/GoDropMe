import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godropme/features/driverSide/common widgets/driver_drawer_shell.dart';

class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({super.key});

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DriverDrawerShell(
        body: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(34.0000, 71.57849),
            zoom: 14,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          onMapCreated: (c) => _mapController = c,
        ),
      ),
    );
  }
}
