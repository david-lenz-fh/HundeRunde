import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:starter_flutter/controllers/location_controller.dart';
import 'package:starter_flutter/models/gps_status.dart';
import '../controllers/dogwalk_recorder.dart';

class DogwalkScreen extends StatelessWidget {
  const DogwalkScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final recorder = context.watch<DogWalkRecorder>();
    final locationController = context.watch<LocationController>();
    LatLng? currentPosition;
    if(recorder.routeCoordinates.isNotEmpty && recorder.isWalking){
        currentPosition = recorder.routeCoordinates.last;
    }
    else if(locationController.gpsStatus==GPSStatus.success){
      currentPosition = locationController.initialLocation;
    }

    if(currentPosition==null){
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 100),
              if(locationController.gpsStatus==GPSStatus.loading || locationController.gpsStatus==GPSStatus.idle)...[
                CircularProgressIndicator(),
                SizedBox(height: 40),
                Text("Suche GPS-Signal..."),
              ],
              if(locationController.gpsStatus==GPSStatus.error || locationController.gpsStatus==GPSStatus.fallback)
                Text("Kein GPS-Signal"),
              Spacer(),
              getRecordingWidget(recorder)
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: currentPosition,
              initialZoom: 19.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'hunderunde',
              ),
              
              PolylineLayer(
                polylines: [
                  if (recorder.routeCoordinates.length > 1)
                  Polyline(
                    points: recorder.routeCoordinates,
                    color: Colors.redAccent,
                    strokeWidth: 8.0,
                  ),
                ],
              ),
              
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentPosition,
                    width: 20,
                    height: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26, 
                            blurRadius: 4, 
                            spreadRadius: 1
                          )
                        ]
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          getRecordingWidget(recorder)
          
        ],
      ),
    );    
  }
  Widget getRecordingWidget(DogWalkRecorder recorder){
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Dauer: ${recorder.durationText}", 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 5),
              Text("Distanz: ${recorder.distanceText}", 
                style: const TextStyle(fontSize: 16, color: Colors.grey)
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: recorder.isWalking ? Colors.red : Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15)
                  ),
                  onPressed: () {
                    if (recorder.isWalking) {
                      recorder.stopWalk();
                    } else {
                      recorder.startWalk();
                    }
                  },
                  child: Text(
                    recorder.isWalking ? 'Beenden & Speichern' : 'Starten',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
