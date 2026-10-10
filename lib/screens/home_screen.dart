import 'package:flutter/material.dart';
import 'package:starter_flutter/models/weather_response.dart';
import 'package:starter_flutter/services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {

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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: SafeArea(
        child:
        Padding(
          padding: EdgeInsetsGeometry.only(left: 10, right: 10, top: 20),
          child: 
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                weatherCard(),
                Card(
                  elevation: 6,
                  child: Text("yo"),
                )
            ])
        ),
      ),
    );
  }
  Card weatherCard(){
      final nextTemperatures = _weather?.minutely15.entries.take(4).toList() ?? List.empty();
  
      return Card(
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

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

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      for(final entry in nextTemperatures)
                        Column(
                          children: [
                            Text(
                              entry.key.substring(11, 16),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              '${entry.value.temperature.toStringAsFixed(1)}°C',
                              style: const TextStyle(
                                fontSize: 11,
                              ),
                            ),
                             Text(
                              '${entry.value.precipitation}%',
                              style: const TextStyle(
                                fontSize: 11,
                              )
                             )
                          ],
                        ),
                  ],
                ),
                ],
            ),
          ),
        );
  }
  
}