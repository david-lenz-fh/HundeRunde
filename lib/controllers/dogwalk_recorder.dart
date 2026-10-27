import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:starter_flutter/services/dogwalk_service.dart';
import 'package:starter_flutter/services/location_service.dart';

class DogWalkRecorder extends ChangeNotifier {
  
  static final DogWalkRecorder _instance = DogWalkRecorder._internal();
  factory DogWalkRecorder() => _instance;
  
  DogWalkRecorder._internal();

  bool _isWalking = false;
  Future<String>? currentWalkId;
  int _secondsElapsed = 0;
  double _distanceInM = 0.0;
  DogWalkService dogWalkService = DogWalkService();

  Timer? _timer;
  DateTime? _startTime;

  StreamSubscription<Position>? _positionStream;
  final List<LatLng> _routeCoordinates = [];
  Position? _lastPosition;

  bool get isWalking => _isWalking;
  DateTime? get startTime => _startTime;
  int get distance => _distanceInM.toInt();
  List<LatLng> get routeCoordinates => _routeCoordinates;
  


  String get durationText {
    if (!_isWalking && _secondsElapsed == 0) return '00:00 min';
    
    final minutes = (_secondsElapsed / 60).floor();
    final seconds = _secondsElapsed % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} min';
  }

  String get distanceText => '${_distanceInM.toInt()} m';

  

  void toggleWalk() {
    if (_isWalking) {
      stopWalk();
    } else {
      startWalk();
    }
  }

  Future<void> startWalk() async {

    //zur Sicherheit
    stopWalk();

    final hasPermission = await LocationService.checkAndRequestPermissions();
    
    currentWalkId = dogWalkService.startWalk("a");
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
    


    if (!hasPermission) {
      return;
    }
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

  void stopWalk() async{
    _timer?.cancel();
    _positionStream?.cancel();
    _isWalking = false;

    final walkId=await currentWalkId;
    if(walkId!=null){
      saveWalk(walkId);
    }
    notifyListeners();
  }

  void saveWalk(String walkId){
    dogWalkService.finishWalk(walkId);
  }
}