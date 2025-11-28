import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godropme/constants/app_strings.dart';
import 'map_view.dart';
import 'search_panel.dart';
import 'confirm_bar.dart';
import 'location_services.dart';
import 'snack.dart';

class LocationSelection {
  final LatLng position;
  final String address;
  const LocationSelection({required this.position, required this.address});
}

class LocationPickerSheet extends StatefulWidget {
  final LatLng? initial;
  final bool returnAddress;
  const LocationPickerSheet({
    super.key,
    this.initial,
    required this.returnAddress,
  });

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  late LatLng _selected;
  bool _locating = false;
  bool _hasPermission = false;
  bool _userChangedSelection =
      false; // prevent auto-recenter after user interaction
  String? _address; // resolved address for the selected coordinate
  bool _resolving = false; // throttle reverse geocoding

  static const LatLng _fallback = LatLng(34.0151, 71.5249); // Peshawar default

  @override
  void initState() {
    super.initState();
    _selected = widget.initial ?? _fallback;
    if (widget.initial == null) {
      _initLocation();
    }
    _resolveAddress(_selected);
  }

  Future<void> _initLocation() async {
    try {
      final granted = await LocationServices.ensurePermission();
      if (!granted) return;
      if (mounted) setState(() => _hasPermission = true);
      final latLng = await LocationServices.currentPosition();
      if (!mounted) return;
      if (!_userChangedSelection) {
        setState(() => _selected = latLng);
        _resolveAddress(latLng);
      }
    } catch (_) {}
  }

  Future<void> _locateMe() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final granted = await LocationServices.ensurePermission();
      if (!granted) {
        showLocationSnack(
          'Location permission permanently denied. Open app settings to enable.',
          actionLabel: AppStrings.settings,
        );
        return;
      }
      if (mounted) setState(() => _hasPermission = true);
      final latLng = await LocationServices.currentPosition();
      if (!mounted) return;
      // Reset userChangedSelection so map will animate to the new location
      setState(() {
        _selected = latLng;
        _userChangedSelection = false;
      });
      _resolveAddress(latLng);
    } catch (_) {
      showLocationSnack('Unable to fetch current location.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _resolveAddress(LatLng p) async {
    if (_resolving) return;
    setState(() => _resolving = true);
    try {
      final addr = await LocationServices.reverseAddress(p);
      if (!mounted) return;
      setState(() => _address = addr);
    } catch (_) {
      if (mounted) {
        setState(
          () => _address =
              '${p.latitude.toStringAsFixed(6)}, ${p.longitude.toStringAsFixed(6)}',
        );
      }
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return SizedBox(
      height: height * 0.8,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),
          LocationSearchPanel(
            title: 'Select Location',
            addressText: _address == null
                ? '${_selected.latitude.toStringAsFixed(6)}, ${_selected.longitude.toStringAsFixed(6)}'
                : _address!,
            onCopy: () async {
              final textToCopy = _address == null
                  ? '${_selected.latitude.toStringAsFixed(6)}, ${_selected.longitude.toStringAsFixed(6)}'
                  : _address!;
              await Clipboard.setData(const ClipboardData(text: ''));
              await Clipboard.setData(ClipboardData(text: textToCopy));
              if (mounted) showLocationSnack('Copied: $textToCopy');
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: LocationMapView(
              initial: _selected,
              myLocationEnabled: _hasPermission,
              locating: _locating,
              onLocateMe: _locateMe,
              userChangedUpstream: _userChangedSelection,
              onPositionChanged: (pos, {bool userGesture = false}) {
                setState(() {
                  _selected = pos;
                  if (userGesture) _userChangedSelection = true;
                });
                _resolveAddress(pos);
              },
            ),
          ),
          LocationConfirmBar(
            onCancel: () => Navigator.of(context).pop(null),
            onConfirm: () {
              if (widget.returnAddress) {
                final addr =
                    _address ??
                    '${_selected.latitude.toStringAsFixed(6)}, ${_selected.longitude.toStringAsFixed(6)}';
                Navigator.of(
                  context,
                ).pop(LocationSelection(position: _selected, address: addr));
              } else {
                Navigator.of(context).pop(_selected);
              }
            },
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }
}
