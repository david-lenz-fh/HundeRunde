import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/weather_controller.dart';
import '../controllers/dogwalk_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Hole dir die Daten aus den Controllern
    final weatherController = context.watch<WeatherController>();
    final dogWalkCtrl = context.watch<DogWalkController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Wenn das Wetter noch lädt, zeige einen Ladekringel ansonsten die Karte
              weatherController.isLoading 
                  ? const Center(child: CircularProgressIndicator()) 
                  : weatherCard(weatherController),
                  
              const SizedBox(height: 10),
              
              // Übergib den DogWalkController an die Karte
              dogWalkOverviewCard(dogWalkCtrl),
            ],
          ),
        ),
      ),
    );
  }

  Card weatherCard(WeatherController weatherController) {

    final weather = weatherController.weather;
    final nextTemperatures = weather?.minutely15.entries.take(4).toList() ?? [];

    return Card(
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${weather?.current.temperature.toStringAsFixed(1) ?? '--'} °C',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Niederschlag: ${weather?.current.precipitation ?? '--'} mm'),
            Text('Luftfeuchtigkeit: ${weather?.current.humidity ?? '--'} %'),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final entry in nextTemperatures)
                  Column(
                    children: [
                      Text(
                        entry.key.substring(11, 16),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text('${entry.value.temperature.toStringAsFixed(1)}°C', style: const TextStyle(fontSize: 11)),
                      Text('${entry.value.precipitation}%', style: const TextStyle(fontSize: 11)),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Card dogWalkOverviewCard(DogWalkController dogWalkCtrl) {
    return Card(
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Wir greifen auf lastWalks des übergebenen Controllers zu
            for (var walk in dogWalkCtrl.lastWalks)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  title: walk.endedAt==null?Text("Spaziergang läuft..."):Text('Spaziergang am ${walk.endedAt?.day}.${walk.endedAt?.month}.${walk.endedAt?.year}'),
                  subtitle: Text('Distanz: ${walk.distanceInM}m'), // 'distance' statt 'distanceInM'
                ),
              ),
          ],
        ),
      ),
    );
  }
}