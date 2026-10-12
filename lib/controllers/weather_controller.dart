import 'dart:async';

import 'package:flutter/material.dart';
import '../models/weather_response.dart';
import '../services/weather_service.dart';

class WeatherController extends ChangeNotifier {
  WeatherResponse? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _timer;

  WeatherResponse? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  WeatherController() {
    loadWeather();

    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      loadWeather();
    });
  }

  Future<void> loadWeather({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _weather = await WeatherService.getWeather(forceRefresh: forceRefresh);
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