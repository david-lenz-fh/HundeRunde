import 'package:flutter/material.dart';
import 'package:starter_flutter/models/weather_response.dart';
import 'package:starter_flutter/services/weather_service.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hunde Runde',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: const StartScreen(),
    );
  }
}

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreen();
}

class _StartScreen extends State<StartScreen> {

  WeatherResponse? _weather;
   @override
    void initState(){
      super.initState();
      _loadWeather();
  }
  Future<void> _loadWeather() async {
  final weather = await WeatherService.getWeather();

  setState(() {
    _weather = weather;
  });
}

  @override
  Widget build(BuildContext context) {
    final nextTemperatures = _weather?.minutely15.entries.take(4).toList() ?? List.empty();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: Center(
        child:Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aktuelles Wetter',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  '${_weather?.current.temperature.toStringAsFixed(1)} °C',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Niederschlag: ${_weather?.current.precipitation} mm',
                ),

                Text(
                  'Luftfeuchtigkeit: ${_weather?.current.humidity} %',
                ),

                const SizedBox(height: 20),

                const Text(
                  'Nächste 60 Minuten',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      for(final entry in nextTemperatures)
                        Column(
                          children: [
                            Text(
                              entry.key.substring(11, 16),
                              style: const TextStyle(
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '${entry.value.temperature.toStringAsFixed(1)} °C - ${entry.value.precipitation}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
