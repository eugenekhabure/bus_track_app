import 'package:geolocator/geolocator.dart';
import 'package:bus_track_app/core/api/dio_client.dart';
import 'dart:async';

class LocationService {
  static const int updateIntervalSeconds = 10;
  Timer? _timer;
  bool _isTracking = false;
  int? _plannedTripId;

  void startTracking(int plannedTripId) {
    if (_isTracking) return;
    _plannedTripId = plannedTripId;
    _isTracking = true;
    _sendLocation();
    _timer = Timer.periodic(Duration(seconds: updateIntervalSeconds), (timer) {
      _sendLocation();
    });
  }

  void stopTracking() {
    _timer?.cancel();
    _timer = null;
    _isTracking = false;
    _plannedTripId = null;
  }

  Future<void> _sendLocation() async {
    if (_plannedTripId == null) return;
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: Duration(seconds: 5),
      );
      final dio = DioClient().dio;
      await dio.post(
        '/planned-trips/set-last-position',
        data: {
          'planned_trip_id': _plannedTripId,
          'lat': position.latitude,
          'lng': position.longitude,
        },
      );
    } catch (e) {
      // silently ignore errors (e.g., no GPS, network issues)
    }
  }

  bool get isTracking => _isTracking;
}