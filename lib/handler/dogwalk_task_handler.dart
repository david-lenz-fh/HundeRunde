import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:starter_flutter/controllers/dogwalk_recorder.dart';
import 'package:starter_flutter/services/pocketbase_service.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(DogWalkTaskHandler());
}

class DogWalkTaskHandler extends TaskHandler {
  late final DogWalkRecorder recorder;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    await PocketBaseService.instance.init();
    recorder = DogWalkRecorder();
    await recorder.startWalk();
    if (!recorder.isWalking) {
      await FlutterForegroundTask.stopService();
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await recorder.stopWalk();
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
      'duration': recorder.secondsElapsed,
    });
  }

  @override
  void onNotificationButtonPressed(String id) async{
    if (id == 'stop_walk') {
      await recorder.stopWalk();
      FlutterForegroundTask.sendDataToMain({
      'walking': false,
      'distance': recorder.distance,
      'duration': recorder.secondsElapsed,
    });
      await FlutterForegroundTask.stopService();
    }
  }
  @override
  void onReceiveData(Object data) {
    if (data is Map && data['command'] == 'stop') {      
      stopWalk();
    }
  }
  void stopWalk(){
    recorder.stopWalk();
    FlutterForegroundTask.sendDataToMain({
      'walking': false,
      'distance': recorder.distance,
      'duration': recorder.secondsElapsed, 
    });
    FlutterForegroundTask.stopService();
  }
}
