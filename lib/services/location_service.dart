import 'package:geolocator/geolocator.dart';

class LocationService {

  static Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    
    if (permission == LocationPermission.deniedForever) return false;
    
    return true;
  }

  static Stream<Position> getLiveLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high, 
        distanceFilter: 3, 
      ),
    );
  }
  static Future<Position?> getCurrentLocation() async {
    bool hasPermission = await checkAndRequestPermissions();
    if (!hasPermission) {
      return null;
    }
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
  static double calculateDistance(Position start, Position end) {
    return Geolocator.distanceBetween(
      start.latitude, start.longitude, 
      end.latitude, end.longitude
    );
  }
}