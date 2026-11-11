import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:starter_flutter/services/dogwalk_service.dart';
import 'package:starter_flutter/services/location_service.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

class DogWalkRecorder extends ChangeNotifier {
  
  static final DogWalkRecorder _instance = DogWalkRecorder._internal();
  factory DogWalkRecorder() => _instance;
  
  DogWalkRecorder._internal();

  bool _isWalking = false;
  Future<String>? currentWalkId;
  int _secondsElapsed = 0;
  int get secondsElapsed => _secondsElapsed;
  double _distanceInM = 0.0;
  final DogWalkService _dogWalkService = DogWalkService();

  Timer? _timer;
  DateTime? _startTime;

  StreamSubscription<Position>? _positionStream;
  final List<LatLng> _routeCoordinates = [];
  Position? _lastPosition;

  bool get isWalking => _isWalking;
  DateTime? get startTime => _startTime;
  int get distance => _distanceInM.toInt();
  List<LatLng> get routeCoordinates => _routeCoordinates;
  
  String getPolylineString() {
    final mappedCoords = _routeCoordinates
        .map((point) => [point.latitude, point.longitude])
        .toList();

    final polylineString = encodePolyline(mappedCoords);
    
    return polylineString;
  }

  String get durationText {
    if (!_isWalking && _secondsElapsed == 0) return '00:00 min';
    
    final minutes = (_secondsElapsed / 60).floor();
    final seconds = _secondsElapsed % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} min';
  }

  String get distanceText => '${_distanceInM.toInt()} m';

  

  void toggleWalk() {
    if (_isWalking) {
      stopWalkFromUI();
      stopWalk();
    } else {
      startWalk();
    }
  }

  Future<void> startWalk() async {
    final hasPermission = await LocationService.checkAndRequestPermissions();
    if (!hasPermission || _isWalking) {
      return;
    }
    
    currentWalkId = _dogWalkService.startWalk("This does not matter until App supports multiple dogs");
    final walkId = await currentWalkId!;
    if (walkId.isEmpty) {
      currentWalkId = null;
      return;
    }

    _isWalking = true;
    _secondsElapsed = 0;
    _distanceInM = 0.0;
    _routeCoordinates.clear();
    _lastPosition = null;
    _startTime = DateTime.now();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsElapsed++;
      notifyListeners(); 
    });
    


    _positionStream = LocationService.getLiveLocationStream().listen((Position newPosition) {
    _routeCoordinates.add(LatLng(newPosition.latitude, newPosition.longitude));

      if (_lastPosition != null) {
        _distanceInM += LocationService.calculateDistance(_lastPosition!, newPosition);
      }
      
      _lastPosition = newPosition;
      notifyListeners(); 
    });
    
    notifyListeners();
  }

  Future<void> stopWalk() async {
    if (!_isWalking && currentWalkId == null) return;
    _timer?.cancel();
    await _positionStream?.cancel();
    _positionStream = null;
    _isWalking = false;

    final walkIdFuture = currentWalkId;
    currentWalkId = null;
    if (walkIdFuture != null) {
      final walkId = await walkIdFuture;
      if (walkId.isNotEmpty) {
        await _dogWalkService.finishWalk(walkId, distance, getPolylineString());
      }
    }
    notifyListeners();
  }

  void initUICommunication() {
  FlutterForegroundTask.initCommunicationPort();
  FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
}

void _onReceiveTaskData(Object data) {
  if (data is Map) {
    _isWalking = data['walking'] as bool;
    _distanceInM = (data['distance'] as num).toDouble();
    
    if (data['duration'] != null) {
      _secondsElapsed = data['duration'];
    }
    notifyListeners();
  }
}
void stopWalkFromUI() {
  FlutterForegroundTask.sendDataToTask({'command': 'stop'});
}
@override
void dispose() {
  FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
  super.dispose();
}
}
