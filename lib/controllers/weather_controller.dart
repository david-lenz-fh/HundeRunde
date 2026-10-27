import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:starter_flutter/controllers/location_controller.dart';
import 'package:starter_flutter/models/gps_status.dart';
import '../models/weather_response.dart';
import '../services/weather_service.dart';

class WeatherController extends ChangeNotifier {
  WeatherResponse? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _timer;
  GPSStatus lastGPSStatus = GPSStatus.idle;

  WeatherResponse? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final LocationController _locationController;
  
  WeatherController(this._locationController) {
    _locationController.addListener(_refreshIfValid);
    _refreshIfValid();
    
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _refreshIfValid();
    });
  }

  void _refreshIfValid(){    
    var location =_locationController.initialLocation;
    var status = _locationController.gpsStatus;
    if(location==null){
      return;
    }
    if(lastGPSStatus==_locationController.gpsStatus){
      loadWeather(location);
    }
    if (status == GPSStatus.success || status == GPSStatus.fallback) {
        loadWeather(location, forceRefresh: true); 
    }
    lastGPSStatus = status;
  }

  Future<void> loadWeather(LatLng location, {bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  
    try {
      _weather = await WeatherService.getWeather(location, forceRefresh: forceRefresh);
    } catch (e) {
      _errorMessage = 'Wetter konnte nicht geladen werden.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}