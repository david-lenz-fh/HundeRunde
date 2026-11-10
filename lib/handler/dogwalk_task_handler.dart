import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:starter_flutter/controllers/dogwalk_recorder.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(DogWalkTaskHandler());
}

class DogWalkTaskHandler extends TaskHandler {
  final recorder = DogWalkRecorder(); 

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    WidgetsFlutterBinding.ensureInitialized();
    await recorder.startWalk();
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    recorder.stopWalk();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    FlutterForegroundTask.updateService(
      notificationTitle: 'Spaziergang läuft',
      notificationText: 'Dauer: ${recorder.durationText} | Distanz: ${recorder.distanceText}',
    );

    FlutterForegroundTask.sendDataToMain({
      'walking': true,
      'distance': recorder.distance,
      'duration': recorder.durationText,
    });
  }
  
}