import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:starter_flutter/models/gps_status.dart';
import 'package:starter_flutter/services/location_service.dart';

class LocationController extends ChangeNotifier {

    GPSStatus gpsStatus = GPSStatus.idle;
    LatLng? _initialLocation; 
    LatLng? get initialLocation => _initialLocation;
    DateTime? _lastFetchTime;
    Timer? _timer;

    LocationController() {
      fetchLocation();
      _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
        fetchLocation();
      });
    }
    Future<void> fetchLocation() async {
    if (_lastFetchTime != null) {
      if (DateTime.now().difference(_lastFetchTime!).inSeconds < 60) {
        return;
      }
    }
  
    gpsStatus = GPSStatus.loading;
    _lastFetchTime = DateTime.now();
    final pos = await LocationService.getCurrentLocation();
    
    if (pos != null) {
      _initialLocation = LatLng(pos.latitude, pos.longitude);
      _lastFetchTime = DateTime.now();
      gpsStatus = GPSStatus.success;
    }
    else{      
      _lastFetchTime = null;
      gpsStatus = GPSStatus.error;
      _fallBackLocation();
    }
    
    notifyListeners(); 
  }

  Future<void> _fallBackLocation() async{
    _initialLocation = LatLng(48.210033, 16.363449);
    gpsStatus = GPSStatus.fallback;
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}