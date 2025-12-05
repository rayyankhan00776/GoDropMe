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
  // Indicates if the user has manually interacted (pan/zoom/tap) upstream.
  // When true we suppress automatic recenter animations on didUpdateWidget
  // to avoid the "snap back" zoom behavior.
  final bool userChangedUpstream;
  const LocationMapView({
    super.key,
    required this.initial,
    required this.onPositionChanged,
    this.onLocateMe,
    this.myLocationEnabled = false,
    this.locating = false,
    this.userChangedUpstream = false,
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

  @override
  void didUpdateWidget(LocationMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the parent updated the initial position (e.g., got current location)
    // animate to the new position. When user clicks locate-me, the parent
    // updates `initial` which triggers this.
    if (oldWidget.initial != widget.initial && !widget.userChangedUpstream) {
      _selected = widget.initial;
      _userChanged = false; // Reset so marker follows the new location
      _animateToSelected();
    }
  }

  Future<void> _animateToSelected() async {
    if (_controller.isCompleted) {
      final c = await _controller.future;
      await c.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _selected, zoom: 16),
        ),
      );
    }
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
          myLocationButtonEnabled: false,
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
