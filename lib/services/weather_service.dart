import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/weather_response.dart';

class WeatherService {
  static const String weatherKey = 'weather_data';

  static Future<WeatherResponse> getWeather() async {
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

    final api_json = jsonDecode(response.body);

    final weather = WeatherResponse.fromAPIJson(api_json);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      weatherKey,
      jsonEncode(weather.toInternalJson()),
    );

    return weather;
  }

  static Future<WeatherResponse?> _getSavedWeather() async {
    final prefs = await SharedPreferences.getInstance();

    final weatherString = prefs.getString(weatherKey);

    if (weatherString == null) {
      return null;
    }

    return WeatherResponse.fromInternalJson(
      jsonDecode(weatherString),
    );
  }
}