import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

typedef LatLngChanged = void Function(LatLng value, {bool userGesture});

class LocationMapView extends StatefulWidget {
  final LatLng initial;
  final LatLngChanged onPositionChanged;
  final Future<void> Function()? onLocateMe;
  final bool myLocationEnabled;
  final bool locating;
  const LocationMapView({
    super.key,
    required this.initial,
    required this.onPositionChanged,
    this.onLocateMe,
    this.myLocationEnabled = false,
    this.locating = false,
  });

  @override
  State<LocationMapView> createState() => _LocationMapViewState();
}

class _LocationMapViewState extends State<LocationMapView> {
  final Completer<GoogleMapController> _controller = Completer();
  late LatLng _selected;
  bool _userChanged = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  CameraPosition get _initialCamera =>
      CameraPosition(target: _selected, zoom: 14);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _initialCamera,
          onMapCreated: (c) async {
            _controller.complete(c);
            await c.moveCamera(CameraUpdate.newCameraPosition(_initialCamera));
          },
          myLocationButtonEnabled: true,
          myLocationEnabled: widget.myLocationEnabled,
          onCameraMoveStarted: () {
            if (!_userChanged) setState(() => _userChanged = true);
          },
          onCameraMove: (pos) {
            setState(() => _selected = pos.target);
          },
          onCameraIdle: () {
            widget.onPositionChanged(_selected, userGesture: _userChanged);
          },
          gestureRecognizers: {
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: true,
          padding: const EdgeInsets.only(bottom: 72, right: 12),
          zoomControlsEnabled: false,
          onTap: (pos) {
            setState(() {
              _selected = pos;
              _userChanged = true;
            });
            widget.onPositionChanged(pos, userGesture: true);
          },
          markers: {
            Marker(
              markerId: const MarkerId('selected'),
              position: _selected,
              draggable: true,
              onDragEnd: (pos) {
                setState(() => _selected = pos);
                widget.onPositionChanged(pos, userGesture: true);
              },
            ),
          },
        ),
        if (widget.onLocateMe != null)
          Positioned(
            left: 16,
            bottom: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Material(
                color: Colors.white,
                elevation: 3,
                child: InkWell(
                  onTap: widget.onLocateMe,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: widget.locating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location, size: 22),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
