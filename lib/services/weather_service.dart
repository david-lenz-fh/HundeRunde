import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/weather_response.dart';

class WeatherService {
  static const String weatherKey = 'weather_data';
  static const String weatherTimeKey = 'weather_timestamp';

  static Future<WeatherResponse> getWeather({bool forceRefresh=false}) async {
      if(forceRefresh){        
        return await _fetchWeather();
      }

      final saved = await _getSavedWeather();
      if (saved != null) {
        return saved;
      }

      return await _fetchWeather();
  }

  static Future<WeatherResponse> _fetchWeather() async {
    final response = await http.get(
      Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&current=temperature_2m,precipitation&minutely_15=temperature_2m,precipitation&forecast_minutely_15=5')
    );

    if (response.statusCode != 200) {
      throw Exception('Weather API request failed');
    }

    final apiJson = jsonDecode(response.body);

    final weather = WeatherResponse.fromAPIJson(apiJson);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      weatherKey,
      jsonEncode(weather.toInternalJson()),
    );
    await prefs.setString(
      weatherTimeKey, 
      DateTime.now().toIso8601String()
    );

    return weather;
  }


  static Future<WeatherResponse?> _getSavedWeather() async {
    final prefs = await SharedPreferences.getInstance();

    final weatherDataString = prefs.getString(weatherKey);
    final weatherTimeString = prefs.getString(weatherTimeKey);

    if (weatherDataString == null || weatherTimeString == null) {
      return null;
    }

    final difference = DateTime.now().difference(DateTime.parse(weatherTimeString));
    if (difference.inMinutes >= 15) {
      return null;
    }
    return WeatherResponse.fromInternalJson(
      jsonDecode(weatherDataString),
    );
  }
}