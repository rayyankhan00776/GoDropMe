import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:godropme/services/appwrite/trip_service.dart';

/// Driver Location Service for GoDropMe
///
/// Handles real-time location streaming from the driver app:
/// - Start/stop GPS tracking for active trips
/// - Stream location updates to the trips collection
/// - Configurable update interval and distance filter
class DriverLocationService {
  static DriverLocationService? _instance;
  static DriverLocationService get instance =>
      _instance ??= DriverLocationService._();

  DriverLocationService._();

  StreamSubscription<Position>? _positionSubscription;
  Timer? _updateTimer;
  Position? _lastPosition;
  String? _activeTripId;
  bool _isTracking = false;

  /// Default update interval in seconds
  static const int defaultIntervalSeconds = 5;

  /// Minimum distance (meters) before triggering a new position event
  static const int defaultDistanceFilter = 10;

  /// Check if currently tracking
  bool get isTracking => _isTracking;

  /// Get the active trip ID being tracked
  String? get activeTripId => _activeTripId;

  // ═══════════════════════════════════════════════════════════════════════════
  // TRACKING CONTROL
  // ═══════════════════════════════════════════════════════════════════════════

  /// Start broadcasting location for an active trip
  ///
  /// Call this when driver starts a trip or goes online.
  /// [tripId] is required to update the correct trip document.
  ///
  /// ```dart
  /// await DriverLocationService.instance.startTracking(tripId: 'trip_123');
  /// ```
  Future<bool> startTracking({
    required String tripId,
    int intervalSeconds = defaultIntervalSeconds,
    int distanceFilter = defaultDistanceFilter,
  }) async {
    // Check and request permissions
    final hasPermission = await _checkAndRequestPermission();
    if (!hasPermission) {
      debugPrint('❌ Location permission denied');
      return false;
    }

    // Stop any existing tracking
    stopTracking();

    _activeTripId = tripId;
    _isTracking = true;

    debugPrint('📍 Starting location tracking for trip: $tripId');

    // Configure location settings
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: defaultDistanceFilter,
    );

    // Listen to position stream
    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            _lastPosition = position;
            debugPrint(
              '📍 Position: ${position.latitude}, ${position.longitude}',
            );
          },
          onError: (error) {
            debugPrint('❌ Position stream error: $error');
          },
        );

    // Set up periodic updates to Appwrite
    _updateTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) => _pushLocationUpdate(),
    );

    // Push initial location immediately
    _pushLocationUpdate();

    return true;
  }

  /// Stop broadcasting location
  ///
  /// Call this when driver completes a trip or goes offline.
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _updateTimer?.cancel();
    _updateTimer = null;
    _lastPosition = null;
    _isTracking = false;

    final tripId = _activeTripId;
    _activeTripId = null;

    if (tripId != null) {
      debugPrint('📍 Stopped location tracking for trip: $tripId');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIVATE METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Push the latest position to Appwrite
  Future<void> _pushLocationUpdate() async {
    if (_lastPosition == null || _activeTripId == null) return;

    try {
      final location = [_lastPosition!.longitude, _lastPosition!.latitude];

      final result = await TripService.instance.updateDriverLocation(
        _activeTripId!,
        location,
      );

      if (result.success) {
        debugPrint('✅ Location pushed: $location');
      } else {
        debugPrint('⚠️ Failed to push location: ${result.message}');
      }
    } catch (e) {
      debugPrint('❌ Push location error: $e');
    }
  }

  /// Check and request location permission
  Future<bool> _checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied');
      return false;
    }

    return true;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UTILITY METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get current position once (not streaming)
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await _checkAndRequestPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      debugPrint('❌ Get current position error: $e');
      return null;
    }
  }

  /// Get current position as [longitude, latitude] array
  Future<List<double>?> getCurrentLocationPoint() async {
    final position = await getCurrentPosition();
    if (position == null) return null;
    return [position.longitude, position.latitude];
  }
}
